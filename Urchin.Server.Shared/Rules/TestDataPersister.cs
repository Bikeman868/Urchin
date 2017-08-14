using System;
using System.Collections.Generic;
using System.Linq;
using Urchin.Server.Shared.DataContracts;
using Urchin.Server.Shared.Interfaces;

namespace Urchin.Server.Shared.Rules
{
    public class TestDataPersister: IPersister
    {
        private readonly List<EnvironmentDto> _environments;
        private readonly List<RuleVersionDto> _rules;
        private readonly List<ApplicationDto> _applications;
        private readonly List<DatacenterDto> _datacenters;
        private readonly List<DatacenterRuleDto> _datacenterRules; 

        private string _defaultEnvironment;

        public TestDataPersister()
        {
            _defaultEnvironment = "Development";

            _rules = new List<RuleVersionDto>
            {
                new RuleVersionDto
                {
                    Name = "Version 1",
                    Version = 1,
                    Rules = new List<RuleDto>
                    {
                        new RuleDto
                        {
                            RuleName = "DevelopmentEnvironment",
                            Environment = "Development",
                            ConfigurationData = "{\"debug\":true}"
                        },
                        new RuleDto
                        {
                            RuleName = "Root",
                            ConfigurationData =
                                "{\"environment\":\"($environment$)\",\"machine\":\"($machine$)\",\"application\":\"($application$)\",\"debug\":false}"
                        }
                    }
                },
                new RuleVersionDto
                {
                    Name = "Version 2",
                    Version = 2,
                    Rules = new List<RuleDto>
                    {
                        new RuleDto
                        {
                            RuleName = "DevelopmentEnvironment",
                            Environment = "Development",
                            ConfigurationData = "{\"debug\":true, \"test\":\"($test$)\"}"
                        },
                        new RuleDto
                        {
                            RuleName = "Root",
                            ConfigurationData =
                                "{\"environment\":\"($environment$)\",\"machine\":\"($machine$)\",\"application\":\"($application$)\",\"debug\":false}",
                            Variables = new List<VariableDeclarationDto>
                            {
                                new VariableDeclarationDto {VariableName = "test", SubstitutionValue = "This is a test"}
                            }
                        }
                    }
                }
            };

            _environments = new List<EnvironmentDto>
            {
                new EnvironmentDto 
                {
                    EnvironmentName = "Production", 
                    Version = 1,
                    Machines = new List<MachineDto>(),
                    SecurityRules = new List<SecurityRuleDto>
                    {
                        new SecurityRuleDto
                        {
                            AllowedIpStart = "192.168.0.1",
                            AllowedIpEnd = "192.168.0.4"
                        }
                    }
                },
                new EnvironmentDto 
                {
                    EnvironmentName = "Staging",
                    Version = 1,
                    Machines = new List<MachineDto>(),
                    SecurityRules = new List<SecurityRuleDto>{}
                },
                new EnvironmentDto 
                {
                    EnvironmentName = "Integration", 
                    Version = 2,
                    Machines = new List<MachineDto>(),
                    SecurityRules = new List<SecurityRuleDto>{}
                },
                new EnvironmentDto 
                {
                    EnvironmentName = "Test", 
                    Version = 2,
                    Machines = new List<MachineDto>(),
                    SecurityRules = new List<SecurityRuleDto>{}
                },
                new EnvironmentDto 
                {
                    EnvironmentName = "Development", 
                    Version = 2,
                    Machines = new List<MachineDto>(),
                    SecurityRules = new List<SecurityRuleDto>{}
                }
            };

            _applications = new List<ApplicationDto>
            {
                new ApplicationDto { Name = "Application-1" },
                new ApplicationDto { Name = "Application-2" },
                new ApplicationDto { Name = "Application-3" }
            };

            _datacenters = new List<DatacenterDto>
            {
                new DatacenterDto { Name = "localhost" },
                new DatacenterDto { Name = "mycompany:london" },
                new DatacenterDto { Name = "mycompany:new-york" },
                new DatacenterDto { Name = "aws:us-east-1" },
                new DatacenterDto { Name = "aws:us-west-1" }
            };

            _datacenterRules = new List<DatacenterRuleDto>
            {
                new DatacenterRuleDto
                {
                    DatacenterName = "mycompany:new-york"
                },
                new DatacenterRuleDto
                {
                    Environment = "Development",
                    DatacenterName = "localhost"
                },
                new DatacenterRuleDto
                {
                    Environment = "Production",
                    Application = "Application-1",
                    DatacenterName = "mycompany:london"
                },
                new DatacenterRuleDto
                {
                    Environment = "Production",
                    Application = "Application-2",
                    Instance = "east",
                    DatacenterName = "aws:us-east-1"
                },
                new DatacenterRuleDto
                {
                    Environment = "Production",
                    Application = "Application-2",
                    Instance = "west",
                    DatacenterName = "aws:us-west-1"
                }
            };
        }

        public string CheckHealth()
        {
            return "Test data persister";
        }

        public List<int> GetVersionNumbers()
        {
            return _rules.Select(r => r.Version).ToList();
        }

        public string GetDefaultEnvironment()
        {
            return _defaultEnvironment;
        }

        public void SetDefaultEnvironment(string name)
        {
            _defaultEnvironment = name;
        }

        public IEnumerable<string> GetRuleNames(int version)
        {
            var ruleVersion = _rules.FirstOrDefault(r => r.Version == version);
            if (ruleVersion == null) return null;
            return ruleVersion.Rules.Select(r => r.RuleName);
        }

        public RuleDto GetRule(int version, string name)
        {
            var ruleVersion = _rules.FirstOrDefault(r => r.Version == version);
            if (ruleVersion == null) return null;

            return ruleVersion.Rules.FirstOrDefault(r => string.Equals(r.RuleName, name, StringComparison.InvariantCultureIgnoreCase));
        }

        public IEnumerable<RuleDto> GetAllRules(int version)
        {
            var ruleVersion = _rules.FirstOrDefault(r => r.Version == version);
            if (ruleVersion == null) return null;

            return ruleVersion.Rules;
        }

        public void DeleteRule(int version, string name)
        {
            var ruleVersion = _rules.FirstOrDefault(r => r.Version == version);
            if (ruleVersion == null) return;

            ruleVersion.Rules.RemoveAll(r => string.Equals(r.RuleName, name, StringComparison.InvariantCultureIgnoreCase));
        }

        public void InsertOrUpdateRule(int version, RuleDto rule)
        {
            var ruleVersion = _rules.FirstOrDefault(r => r.Version == version);
            if (ruleVersion == null) return;

            ruleVersion.Rules.RemoveAll(r => string.Equals(r.RuleName, rule.RuleName, StringComparison.InvariantCultureIgnoreCase));
            ruleVersion.Rules.Add(rule);
        }

        public IEnumerable<string> GetEnvironmentNames()
        {
            return _environments.Select(r => r.EnvironmentName);
        }

        public EnvironmentDto GetEnvironment(string name)
        {
            return _environments.FirstOrDefault(e => string.Equals(e.EnvironmentName, name, StringComparison.InvariantCultureIgnoreCase));
        }

        public IEnumerable<EnvironmentDto> GetAllEnvironments()
        {
            return _environments;
        }

        public void DeleteEnvironment(string name)
        {
            _environments.RemoveAll(e => string.Equals(e.EnvironmentName, name, StringComparison.InvariantCultureIgnoreCase));
        }

        public void InsertOrUpdateEnvironment(EnvironmentDto environment)
        {
            DeleteEnvironment(environment.EnvironmentName);
            _environments.Add(environment);
        }

        public void SetVersionName(int version, string newName)
        {
            var ruleVersion = _rules.FirstOrDefault(r => r.Version == version);
            if (ruleVersion == null) return;

            ruleVersion.Name = newName;
        }

        public string GetVersionName(int version)
        {
            var ruleVersion = _rules.FirstOrDefault(r => r.Version == version);
            return ruleVersion == null ? null : ruleVersion.Name;
        }

        public void DeleteVersion(int version)
        {
            _rules.RemoveAll(r => r.Version == version);
        }

        public IEnumerable<string> GetApplicationNames()
        {
            return _applications.Select(a => a.Name);
        }

        public IEnumerable<ApplicationDto> GetApplications()
        {
            return _applications;
        }

        public void ReplaceApplications(IEnumerable<ApplicationDto> applications)
        {
            _applications.Clear();
            _applications.AddRange(applications);
        }

        public IEnumerable<string> GetDatacenterNames()
        {
            return _datacenters.Select(a => a.Name);
        }

        public IEnumerable<DatacenterDto> GetDatacenters()
        {
            return _datacenters;
        }

        public void ReplaceDatacenters(IEnumerable<DatacenterDto> datacenters)
        {
            _datacenters.Clear();
            _datacenters.AddRange(datacenters);
        }

        public IEnumerable<DatacenterRuleDto> GetDatacenterRules()
        {
            return _datacenterRules;
        }

        public void ReplaceDatacenterRules(IEnumerable<DatacenterRuleDto> datacenterRules)
        {
            _datacenterRules.Clear();
            _datacenterRules.AddRange(datacenterRules);
        }
    }
}
