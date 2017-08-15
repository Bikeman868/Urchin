using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
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
        private bool _initialLoad = true;

        private string _defaultEnvironmentName;
        private List<EnvironmentDto> _environments;
        private List<RuleVersionDto> _ruleVersions;
        private List<ApplicationDto> _applications;
        private List<DatacenterDto> _datacenters;
        private List<DatacenterRuleDto> _datacenterRules;

        public FilePersister(IConfigurationStore configurationStore)
        {
            _defaultEnvironmentName = "Development";
            _environments = new List<EnvironmentDto>();
            _ruleVersions = new List<RuleVersionDto>();
            _applications = new List<ApplicationDto>();
            _datacenters = new List<DatacenterDto>();
            _datacenterRules = new List<DatacenterRuleDto>();

            _configNotifier = configurationStore.Register("/urchin/server/persister/filePath", SetFilePath, "rules.txt");
        }

        public string CheckHealth()
        {
            var content = new StringBuilder();
            content.AppendLine("File persister using file '" + _filePath + "'.");
            content.AppendLine("File contains " + GetVersionNumbers().Count + " versions of the rules.");
            content.AppendLine("File defines " + String.Join(", ", GetEnvironmentNames()) + " environments.");
            content.AppendLine("File defines " + String.Join(", ", GetApplicationNames()) + " applications.");
            content.AppendLine("File defines " + String.Join(", ", GetDatacenterNames()) + " datacenters.");
            return content.ToString();
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

            var ruleVersion = GetVersion(version, false);
            return ruleVersion == null ? new List<string>() : ruleVersion.Rules.Select(r => r.RuleName);
        }

        public RuleDto GetRule(int version, string name)
        {
            CheckForUpdate();

            var ruleVersion = GetVersion(version, false);
            if (ruleVersion == null) return null;

            return ruleVersion.Rules.FirstOrDefault(r => string.Equals(r.RuleName, name, StringComparison.InvariantCultureIgnoreCase));
        }

        public IEnumerable<RuleDto> GetAllRules(int version)
        {
            CheckForUpdate();

            var ruleVersion = GetVersion(version, false);
            if (ruleVersion == null) return null;

            return ruleVersion.Rules;
        }

        public void DeleteRule(int version, string name)
        {
            CheckForUpdate();

            var ruleVersion = GetVersion(version, false);
            if (ruleVersion == null) return;

            ruleVersion.Rules.RemoveAll(r => string.Equals(r.RuleName, name, StringComparison.InvariantCultureIgnoreCase));
            SaveChanges();
        }

        public void InsertOrUpdateRule(int version, RuleDto rule)
        {
            CheckForUpdate();

            var ruleVersion = GetVersion(version, true);
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

        public void SetVersionName(int version, string newName)
        {
            CheckForUpdate();

            var ruleVersion = GetVersion(version, true);
            ruleVersion.Name = newName;

            SaveChanges();
        }

        public string GetVersionName(int version)
        {
            CheckForUpdate();

            var ruleVersion = GetVersion(version, false);
            return ruleVersion == null ? null : ruleVersion.Name;
        }

        public void DeleteVersion(int version)
        {
            CheckForUpdate();

            _ruleVersions.RemoveAll(r => r.Version == version);

            SaveChanges();
        }
        
        #region Applications

        public IEnumerable<string> GetApplicationNames()
        {
            CheckForUpdate();

            return _applications.Select(a => a.Name).ToList();
        }

        public IEnumerable<ApplicationDto> GetApplications()
        {
            CheckForUpdate();

            return _applications.ToList();
        }

        public void ReplaceApplications(IEnumerable<ApplicationDto> applications)
        {
            CheckForUpdate();

            _applications = applications.ToList();

            SaveChanges();
        }

        #endregion

        #region Datacenters

        public IEnumerable<string> GetDatacenterNames()
        {
            CheckForUpdate();

            return _datacenters.Select(a => a.Name).ToList();
        }

        public IEnumerable<DatacenterDto> GetDatacenters()
        {
            CheckForUpdate();

            return _datacenters.ToList();
        }

        public void ReplaceDatacenters(IEnumerable<DatacenterDto> datacenters)
        {
            CheckForUpdate();

            _datacenters = datacenters.ToList();

            SaveChanges();
        }

        public IEnumerable<DatacenterRuleDto> GetDatacenterRules()
        {
            CheckForUpdate();

            return _datacenterRules.ToList();
        }

        public void ReplaceDatacenterRules(IEnumerable<DatacenterRuleDto> datacenterRules)
        {
            CheckForUpdate();

            _datacenterRules = datacenterRules.ToList();

            SaveChanges();
        }

        #endregion

        #region Private methods

        private void SetFilePath(string filePath)
        {
            _filePath = filePath;

            var fileInfo = new FileInfo(filePath);
            if (fileInfo.Exists || _initialLoad)
            {
                Reload();
                _initialLoad = false;
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
                _environments = new List<EnvironmentDto>
                {
                    new EnvironmentDto
                    {
                        EnvironmentName = "Development",
                        Version = 1
                    },
                    new EnvironmentDto
                    {
                        EnvironmentName = "Production",
                        Version = 1
                    },
                };
                _ruleVersions = new List<RuleVersionDto>
                {
                    new RuleVersionDto
                    {
                        Name = "Initial version",
                        Version = 1,
                        Rules = new List<RuleDto>
                        {
                            new RuleDto
                            {
                                RuleName = "root",
                                ConfigurationData = 
                                    "{\n" +
                                    "  \"environment\":\"($environment$)\",\n" + 
                                    "  \"datacenter\":\"($datacenter$)\",\n" + 
                                    "  \"application\":\"($application$)\",\n" + 
                                    "  \"instance\":\"($instance$)\",\n" + 
                                    "  \"machine\":\"($machine$)\",\n" + 
                                    "  \"myCompany\":{\n" +
                                    "    \"myApplication\":{\n" +
                                    "      \"appSetting1\":\"value1\",\n" +
                                    "      \"appSetting2\":\"value2\"\n" +
                                    "    }\n" +
                                    "  }\n" +
                                    "}",
                                Variables = new List<VariableDeclarationDto>()
                            }
                        }
                    }
                };
                _datacenters = new List<DatacenterDto>();
                _applications = new List<ApplicationDto>();
                _datacenterRules = new List<DatacenterRuleDto>();
            }
            else
            {
                _defaultEnvironmentName = fileContents.DefaultEnvironmentName;
                _environments = fileContents.Environments ?? new List<EnvironmentDto>();
                _applications = fileContents.Applications ?? new List<ApplicationDto>();
                _datacenters = fileContents.Datacenters ?? new List<DatacenterDto>();
                _datacenterRules = fileContents.DatacenterRules ?? new List<DatacenterRuleDto>();

                if (fileContents.RuleVersions == null || fileContents.RuleVersions.Count == 0)
                {
                    _ruleVersions = new List<RuleVersionDto>();
                    if (fileContents.Rules != null && fileContents.Rules.Count > 0)
                    {
                        // This is here for backward compatibility with old file format before versioning
                        _ruleVersions.Add(new RuleVersionDto
                        {
                            Version = 1,
                            Name = "First version",
                            Rules = fileContents.Rules
                        });
                        foreach (var environment in _environments)
                            environment.Version = 1;
                    }
                }
                else
                {
                    _ruleVersions = fileContents.RuleVersions;
                    foreach (var ruleVersion in _ruleVersions)
                        if (string.IsNullOrEmpty(ruleVersion.Name))
                            ruleVersion.Name = "Version " + ruleVersion.Version;
                }
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
                RuleVersions = _ruleVersions,
                Applications = _applications,
                Datacenters = _datacenters,
                DatacenterRules = _datacenterRules
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

        private RuleVersionDto GetVersion(int version, bool createIfMissing)
        {
            RuleVersionDto ruleVersion = null;
            if (createIfMissing)
            {
                if (_ruleVersions == null)
                    _ruleVersions = new List<RuleVersionDto>();

                ruleVersion = _ruleVersions.FirstOrDefault(r => r.Version == version);
                if (ruleVersion == null)
                {
                    ruleVersion = new RuleVersionDto
                    {
                        Name = "Version " + version,
                        Version = version,
                        Rules = new List<RuleDto>()
                    };
                    _ruleVersions.Add(ruleVersion);
                }
            }
            else
            {
                if (_ruleVersions != null)
                    ruleVersion = _ruleVersions.FirstOrDefault(r => r.Version == version);
            }
            return ruleVersion;
        }

        #endregion

        private class FileContents
        {
            public string DefaultEnvironmentName { get; set; }
            public List<EnvironmentDto> Environments { get; set; }
            public List<RuleVersionDto> RuleVersions { get; set; }
            public List<RuleDto> Rules { get; set; }
            public List<ApplicationDto> Applications { get; set; }
            public List<DatacenterDto> Datacenters { get; set; }
            public List<DatacenterRuleDto> DatacenterRules { get; set; }
        }
    }
}
