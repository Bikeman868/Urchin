﻿using System;
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
            CheckForUpdate();
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
                fileContents = LoadFileAs<FileContents>(fileInfo);
            }

            if (fileContents == null)
            {
                SetupDefaultRules();
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
                    MigrateToVersions(fileContents);
                }
                else
                {
                    _ruleVersions = fileContents.RuleVersions;

                    foreach (var ruleVersion in _ruleVersions)
                        if (string.IsNullOrEmpty(ruleVersion.Name))
                            ruleVersion.Name = "Version " + ruleVersion.Version;

                    if (fileContents.FileFormatVersion == 0 && _ruleVersions.Count > 1)
                    {
                        // There was a bug in this version where new versions of the rules only
                        // contain changed rules, not copies of the unchanged rules!!

                        var orderedVersions = _ruleVersions.OrderBy(rv => rv.Version).ToList();
                        for (var i = 1; i < orderedVersions.Count; i++)
                        {
                            var priorVersion = orderedVersions[i - 1];
                            var currentVersion = orderedVersions[i];
                            foreach (var priorRule in priorVersion.Rules)
                            {
                                if (currentVersion.Rules.Any(r => string.Equals(r.RuleName, priorRule.RuleName, StringComparison.OrdinalIgnoreCase)))
                                    continue;
                                currentVersion.Rules.Add(priorRule);
                            }
                        }

                        SaveChanges();
                    }

                    // Rule versions are stored in separate files when fileContents.FileFormatVersion > 1
                    foreach (var ruleVersion in _ruleVersions)
                    {
                        var versionFileName = GetVersionFileName(ruleVersion.Version);
                        var versionFileInfo = new FileInfo(versionFileName);
                        if (versionFileInfo.Exists)
                        {
                            var versionFileContents = LoadFileAs<VersionFileContents>(versionFileInfo);
                            if (versionFileContents != null && versionFileContents.RuleVersion != null)
                            {
                                ruleVersion.Rules = versionFileContents.RuleVersion.Rules;
                            }
                        }
                    }
                }
            }
        }

        private void MigrateToVersions(FileContents fileContents)
        {
            _ruleVersions = new List<RuleVersionDto>();
            if (fileContents.Rules != null && fileContents.Rules.Count > 0)
            {
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

        private T LoadFileAs<T>(FileInfo fileInfo)
        {
            string content;
            using (var stream = fileInfo.Open(FileMode.Open, FileAccess.Read, FileShare.Read))
            {
                using (var streamReader = new StreamReader(stream))
                {
                    content = streamReader.ReadToEnd();
                }
            }

            return JsonConvert.DeserializeObject<T>(content);
        }

        private string GetVersionFileName(int version)
        {
            var fileName = Path.GetFileNameWithoutExtension(_filePath) + version.ToString("D5") + Path.GetExtension(_filePath);
            var path = Path.GetDirectoryName(_filePath);
            var fullPath = Path.Combine(path, fileName);
            return fullPath;
        }

        private void SetupDefaultRules()
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
                FileFormatVersion = 2,
                DefaultEnvironmentName = _defaultEnvironmentName,
                Environments = _environments,
                RuleVersions = _ruleVersions
                    .Select(
                        rv => new RuleVersionDto 
                        { 
                            Version = rv.Version, 
                            Name = rv.Name
                        })
                    .OrderBy(rv => rv.Version)
                    .ToList(),
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

            foreach (var ruleVersion in _ruleVersions)
            {
                var versionFileContent = new VersionFileContents
                {
                    FileFormatVersion = 1,
                    RuleVersion = new RuleVersionDto
                    {
                        Version = ruleVersion.Version,
                        Name = ruleVersion.Name,
                        Rules = ruleVersion.Rules.OrderBy(r => r.RuleName).ToList()
                    }
                };

                var versionContent = JsonConvert.SerializeObject(versionFileContent, Formatting.Indented);

                try
                {
                    var fileName = GetVersionFileName(ruleVersion.Version);
                    var fileInfo = new FileInfo(fileName);
                    using (var stream = fileInfo.Open(FileMode.Create, FileAccess.Write, FileShare.None))
                    {
                        using (var streamWriter = new StreamWriter(stream))
                        {
                            streamWriter.Write(versionContent);
                        }
                    }
                }
                catch
                {
                }

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
                    List<RuleDto> newRules;
                    if (_ruleVersions.Count > 0)
                    {
                        var latestVersionNumber = _ruleVersions.Max(rv => rv.Version);
                        var latestVersion = _ruleVersions.First(r => r.Version == latestVersionNumber);
                        newRules = latestVersion.Rules.ToList();
                    }
                    else
                    {
                        newRules = new List<RuleDto>();
                    }

                    ruleVersion = new RuleVersionDto
                    {
                        Name = "Version " + version,
                        Version = version,
                        Rules = newRules
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

        /// <summary>
        /// This is serialized intoa file to save the rules
        /// </summary>
        private class FileContents
        {
            /// <summary>
            /// When the structure of the file changes this number is incremented
            /// </summary>
            public int FileFormatVersion { get; set; }

            /// <summary>
            /// The name of the environment to use for machines that do not match
            /// any of the environment rules
            /// </summary>
            public string DefaultEnvironmentName { get; set; }

            /// <summary>
            /// A list of the environments used within this organization
            /// </summary>
            public List<EnvironmentDto> Environments { get; set; }

            /// <summary>
            /// Depreciated - used to contain all of the rules for all
            /// of the versions. Now the versions are stored in separate files
            /// </summary>
            public List<RuleVersionDto> RuleVersions { get; set; }

            /// <summary>
            /// This is a list of the versions. Each version is stored in a
            /// separate file an deserialized into a VersionFileContents instance
            /// </summary>
            public List<VersionNameDto> Versions { get; set; }

            /// <summary>
            /// Deprciated - this used to be in the file format before versioning
            /// was introduced.
            /// </summary>
            public List<RuleDto> Rules { get; set; }

            /// <summary>
            /// A list of the applications that this orginization needs to manage
            /// configuration data for
            /// </summary>
            public List<ApplicationDto> Applications { get; set; }

            /// <summary>
            /// A list of this organizations datacenters
            /// </summary>
            public List<DatacenterDto> Datacenters { get; set; }

            /// <summary>
            /// Rules to determine which datacenter a machine runs in
            /// </summary>
            public List<DatacenterRuleDto> DatacenterRules { get; set; }
        }

        /// <summary>
        /// This is serialized into a file for a specific version of the rules
        /// </summary>
        private class VersionFileContents
        {
            /// <summary>
            /// When the structure of the file changes this number is incremented
            /// </summary>
            public int FileFormatVersion { get; set; }

            /// <summary>
            /// A specific version of the rules
            /// </summary>
            public RuleVersionDto RuleVersion { get; set; }
        }
    }
}
