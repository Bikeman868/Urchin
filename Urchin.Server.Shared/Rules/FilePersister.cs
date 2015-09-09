using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using Newtonsoft.Json;
using Urchin.Client.Interfaces;
using Urchin.Server.Shared.DataContracts;
using Urchin.Server.Shared.Interfaces;

namespace Urchin.Server.Shared.Rules
{
    public class FilePersister: IPersister
    {
        private readonly IDisposable _configNotifier;
        private string _filePath;
        private DateTime _lastFileTime;
        private string _defaultEnvironmentName;
        private List<EnvironmentDto> _environments;
        private List<RuleVersionDto> _ruleVersions;

        public FilePersister(IConfigurationStore configurationStore)
        {
            _defaultEnvironmentName = "Development";
            _environments = new List<EnvironmentDto>();
            _ruleVersions = new List<RuleVersionDto>();

            _configNotifier = configurationStore.Register("/urchin/server/persister/filePath", SetFilePath, "rules.txt");
        }

        public string GetDefaultEnvironment()
        {
            CheckForUpdate();
            return _defaultEnvironmentName;
        }

        public void SetDefaultEnvironment(string name)
        {
            CheckForUpdate();
            _defaultEnvironmentName = name;
            SaveChanges();
        }

        public bool SupportsVersioning { get { return true; } }

        public List<int> GetVersionNumbers()
        {
            CheckForUpdate();

            if (_ruleVersions == null)
                return new List<int>();

            return _ruleVersions.Select(r => r.Version).ToList();
        }

        public IEnumerable<string> GetRuleNames(int version)
        {
            CheckForUpdate();

            var ruleVersion = GetVersion(version);
            return ruleVersion == null ? new List<string>() : ruleVersion.Rules.Select(r => r.RuleName);
        }

        public RuleDto GetRule(int version, string name)
        {
            CheckForUpdate();

            var ruleVersion = GetVersion(version);
            if (ruleVersion == null) return null;

            return ruleVersion.Rules.FirstOrDefault(r => string.Equals(r.RuleName, name, StringComparison.InvariantCultureIgnoreCase));
        }

        public IEnumerable<RuleDto> GetAllRules(int version)
        {
            CheckForUpdate();

            var ruleVersion = GetVersion(version);
            if (ruleVersion == null) return null;

            return ruleVersion.Rules;
        }

        public void DeleteRule(int version, string name)
        {
            CheckForUpdate();

            var ruleVersion = GetVersion(version);
            if (ruleVersion == null) return;

            ruleVersion.Rules.RemoveAll(r => string.Equals(r.RuleName, name, StringComparison.InvariantCultureIgnoreCase));
            SaveChanges();
        }

        public void InsertOrUpdateRule(int version, RuleDto rule)
        {
            CheckForUpdate();

            var ruleVersion = GetVersion(version);
            if (ruleVersion == null) return;

            ruleVersion.Rules.RemoveAll(r => string.Equals(r.RuleName, rule.RuleName, StringComparison.InvariantCultureIgnoreCase));
            ruleVersion.Rules.Add(rule);

            SaveChanges();
        }

        public IEnumerable<string> GetEnvironmentNames()
        {
            CheckForUpdate();
            return _environments.Select(e => e.EnvironmentName);
        }

        public EnvironmentDto GetEnvironment(string name)
        {
            CheckForUpdate();
            return _environments.FirstOrDefault(e => string.Equals(e.EnvironmentName, name, StringComparison.InvariantCultureIgnoreCase));
        }

        public IEnumerable<EnvironmentDto> GetAllEnvironments()
        {
            CheckForUpdate();
            return _environments;
        }

        public void DeleteEnvironment(string name)
        {
            _environments.RemoveAll(e => string.Equals(e.EnvironmentName, name, StringComparison.InvariantCultureIgnoreCase));
            SaveChanges();
        }

        public void InsertOrUpdateEnvironment(EnvironmentDto environment)
        {
            CheckForUpdate();
            _environments.RemoveAll(e => string.Equals(e.EnvironmentName, environment.EnvironmentName, StringComparison.InvariantCultureIgnoreCase));
            _environments.Add(environment);
            SaveChanges();
        }
        
        #region Private methods

        private void SetFilePath(string filePath)
        {
            _filePath = filePath;

            var fileInfo = new FileInfo(filePath);
            if (fileInfo.Exists)
            {
                Reload();
            }
            else
            {
                SaveChanges();
            }
        }

        private void Reload()
        {
            var fileInfo = new FileInfo(_filePath);

            FileContents fileContents = null;
            if (fileInfo.Exists)
            {
                _lastFileTime = fileInfo.LastWriteTimeUtc;

                string content;
                using (var stream = fileInfo.Open(FileMode.Open, FileAccess.Read, FileShare.Read))
                {
                    using (var streamReader = new StreamReader(stream))
                    {
                        content = streamReader.ReadToEnd();
                    }
                }

                fileContents = JsonConvert.DeserializeObject<FileContents>(content);
            }

            if (fileContents == null)
            {
                _defaultEnvironmentName = "Development";
                _environments = new List<EnvironmentDto>();
                _ruleVersions = new List<RuleVersionDto>();
            }
            else
            {
                if (fileContents.RuleVersions == null || fileContents.RuleVersions.Count == 0)
                {
                    _ruleVersions = new List<RuleVersionDto>();
                    if (fileContents.Rules != null && fileContents.Rules.Count > 0)
                    {
                        // This is here for backward compatibility with old file format before versioning
                        _ruleVersions.Add(new RuleVersionDto
                        {
                            Version = 1,
                            Rules = fileContents.Rules
                        });
                    }
                }
                else
                {
                    _ruleVersions = fileContents.RuleVersions;
                }
                _defaultEnvironmentName = fileContents.DefaultEnvironmentName;
                _environments = fileContents.Environments ?? new List<EnvironmentDto>();
            }
        }

        private void CheckForUpdate()
        {
            if (_filePath == null) return;

            var fileInfo = new FileInfo(_filePath);
            if (fileInfo.Exists && fileInfo.LastWriteTimeUtc > _lastFileTime)
                Reload();
        }

        private void SaveChanges()
        {
            if (_filePath == null) return;

            var fileContents = new FileContents
            {
                DefaultEnvironmentName = _defaultEnvironmentName,
                Environments = _environments,
                RuleVersions = _ruleVersions
            };
            var content = JsonConvert.SerializeObject(fileContents, Formatting.Indented);

            try
            {
                var fileInfo = new FileInfo(_filePath);
                using (var stream = fileInfo.Open(FileMode.Create, FileAccess.Write, FileShare.None))
                {
                    using (var streamWriter = new StreamWriter(stream))
                    {
                        streamWriter.Write(content);
                    }
                }
                _lastFileTime = fileInfo.LastWriteTimeUtc;
            }
            catch
            {
            }
        }

        private RuleVersionDto GetVersion(int version)
        {
            if (_ruleVersions == null) return null;
            return _ruleVersions.FirstOrDefault(r => r.Version == version);
        }

        #endregion

        private class FileContents
        {
            public string DefaultEnvironmentName { get; set; }
            public List<EnvironmentDto> Environments { get; set; }
            public List<RuleVersionDto> RuleVersions { get; set; }
            public List<RuleDto> Rules { get; set; }
        }

    }
}
