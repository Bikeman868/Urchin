using System;
using System.Collections.Generic;
using System.Linq;
using Urchin.Server.Shared.DataContracts;
using Urchin.Server.Shared.Interfaces;

namespace Urchin.Server.Shared.Rules
{
    public class TestDataPersister: IPersister
    {
        private readonly string _defaultEnvironment;
        private readonly List<RuleDto> _rules;
        private readonly List<EnvironmentDto> _environments;

        public TestDataPersister()
        {
            _defaultEnvironment = "Development";

            _rules = new List<RuleDto>
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
            };

            _environments = new List<EnvironmentDto>
            {
                new EnvironmentDto {EnvironmentName = "Production", Machines = new List<string>()},
                new EnvironmentDto {EnvironmentName = "Staging", Machines = new List<string>()},
                new EnvironmentDto {EnvironmentName = "Integration", Machines = new List<string>()},
                new EnvironmentDto {EnvironmentName = "Test", Machines = new List<string>()}
            };
        }

        public string GetDefaultEnvironment()
        {
            return _defaultEnvironment;
        }

        public void SetDefaultEnvironment(string name)
        {
        }

        public IEnumerable<string> GetRuleNames()
        {
            return _rules.Select(r => r.RuleName);
        }

        public RuleDto GetRule(string name)
        {
            return _rules.FirstOrDefault(r => string.Equals(r.RuleName, name, StringComparison.InvariantCultureIgnoreCase));
        }

        public IEnumerable<RuleDto> GetAllRules()
        {
            return _rules;
        }

        public void DeleteRule(string name)
        {
        }

        public void InsertOrUpdateRule(RuleDto rule)
        {
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
        }

        public void InsertOrUpdateEnvironment(EnvironmentDto environment)
        {
        }
    }
}
