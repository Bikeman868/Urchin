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
        private FileInfo _fileInfo;
        private DateTime _lastFileTime;
        private RuleSetDto _ruleSet;

        public FilePersister(IConfigurationStore configurationStore)
        {
            _ruleSet = new RuleSetDto
            {
                Environments = new List<EnvironmentDto>(), 
                Rules = new List<RuleDto>()
            };

            _configNotifier = configurationStore.Register("/urchin/server/persister/filePath", SetFilePath, "rules.txt");
        }

        private void SetFilePath(string filePath)
        {
            _fileInfo = new FileInfo(filePath);
            if (_fileInfo.Exists)
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
            _lastFileTime = _fileInfo.LastWriteTimeUtc;

            string content;
            using (var stream = _fileInfo.Open(FileMode.Open, FileAccess.Read, FileShare.Read))
            {
                using (var streamReader = new StreamReader(stream))
                {
                    content = streamReader.ReadToEnd();
                }
            }

            var ruleSet = JsonConvert.DeserializeObject<RuleSetDto>(content);

            if (ruleSet.Environments == null) ruleSet.Environments = new List<EnvironmentDto>();
            if (ruleSet.Rules == null) ruleSet.Rules = new List<RuleDto>();

            _ruleSet = ruleSet;
        }

        private void CheckForUpdate()
        {
            if (_fileInfo != null && _fileInfo.Exists && _fileInfo.LastWriteTimeUtc > _lastFileTime)
                Reload();
        }

        private void SaveChanges()
        {
            if (_fileInfo == null) return;

            var content = JsonConvert.SerializeObject(_ruleSet, Formatting.Indented);

            try
            {
                using (var stream = _fileInfo.Open(FileMode.Create, FileAccess.Write, FileShare.None))
                {
                    using (var streamWriter = new StreamWriter(stream))
                    {
                        streamWriter.Write(content);
                    }
                }
                _lastFileTime = _fileInfo.LastWriteTimeUtc;
            }
            catch
            {
            }
        }

        public string GetDefaultEnvironment()
        {
            CheckForUpdate();
            return _ruleSet.DefaultEnvironmentName;
        }

        public void SetDefaultEnvironment(string name)
        {
            CheckForUpdate();
            _ruleSet.DefaultEnvironmentName = name;
            SaveChanges();
        }

        public IEnumerable<string> GetRuleNames()
        {
            CheckForUpdate();
            return _ruleSet.Rules.Select(r => r.RuleName);
        }

        public RuleDto GetRule(string name)
        {
            CheckForUpdate();
            return _ruleSet.Rules.FirstOrDefault(r => string.Equals(r.RuleName, name, StringComparison.InvariantCultureIgnoreCase));
        }

        public IEnumerable<RuleDto> GetAllRules()
        {
            CheckForUpdate();
            return _ruleSet.Rules;
        }

        public void DeleteRule(string name)
        {
            CheckForUpdate();
            _ruleSet.Rules.RemoveAll(r => string.Equals(r.RuleName, name, StringComparison.InvariantCultureIgnoreCase));
            SaveChanges();
        }

        public void InsertOrUpdateRule(RuleDto rule)
        {
            CheckForUpdate();
            _ruleSet.Rules.RemoveAll(r => string.Equals(r.RuleName, rule.RuleName, StringComparison.InvariantCultureIgnoreCase));
            _ruleSet.Rules.Add(rule);
            SaveChanges();
        }

        public IEnumerable<string> GetEnvironmentNames()
        {
            CheckForUpdate();
            return _ruleSet.Environments.Select(e => e.EnvironmentName);
        }

        public EnvironmentDto GetEnvironment(string name)
        {
            CheckForUpdate();
            return _ruleSet.Environments.FirstOrDefault(e => string.Equals(e.EnvironmentName, name, StringComparison.InvariantCultureIgnoreCase));
        }

        public IEnumerable<EnvironmentDto> GetAllEnvironments()
        {
            CheckForUpdate();
            return _ruleSet.Environments;
        }

        public void DeleteEnvironment(string name)
        {
            _ruleSet.Environments.RemoveAll(e => string.Equals(e.EnvironmentName, name, StringComparison.InvariantCultureIgnoreCase));
            SaveChanges();
        }

        public void InsertOrUpdateEnvironment(EnvironmentDto environment)
        {
            CheckForUpdate();
            _ruleSet.Environments.RemoveAll(e => string.Equals(e.EnvironmentName, environment.EnvironmentName, StringComparison.InvariantCultureIgnoreCase));
            _ruleSet.Environments.Add(environment);
            SaveChanges();
        }
    }
}
