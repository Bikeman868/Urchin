using System;
using System.Collections.Generic;
using System.Linq;
using Newtonsoft.Json.Linq;
using Stockhouse.Shared.Contracts.Interfaces.DataTransformation;
using Urchin.Server.Shared.DataContracts;
using Urchin.Server.Shared.Interfaces;

namespace Urchin.Server.Shared.Rules
{
    public class ConfigRules: IConfigRules
    {
        private readonly IMapper _mapper;

        private RuleSetDto _ruleSet;

        public ConfigRules(IMapper mapper)
        {
            _mapper = mapper;

            _ruleSet = new RuleSetDto
            {
                DefaultEnvironmentName = "Development",
                Environments = new List<EnvironmentDto> 
                { 
                    new EnvironmentDto { EnvironmentName = "Production", Machines = new List<string>() },
                    new EnvironmentDto { EnvironmentName = "Staging", Machines = new List<string>() },
                    new EnvironmentDto { EnvironmentName = "Integration", Machines = new List<string>() },
                    new EnvironmentDto { EnvironmentName = "Test", Machines = new List<string>() }
                },
                Rules = new List<RuleDto> 
                {
                    new RuleDto
                    {
                        ConfigurationData = new JObject(new JProperty("environment", "($environment$)"))
                    }
                }
            };
        }

        public JToken GetConfig(string environment, string machine, string application, string instance)
        {
            var config = JToken.Parse("null");

            if (string.IsNullOrWhiteSpace(machine) || string.IsNullOrWhiteSpace(application))
                return config;

            var ruleSet = _ruleSet;
            if (ruleSet == null) 
                return config;

            if (string.IsNullOrWhiteSpace(environment))
            {
                environment = ruleSet.DefaultEnvironmentName;
                if (ruleSet.Environments != null)
                {
                    foreach (var environmentRule in ruleSet.Environments)
                    {
                        if (environmentRule.Machines != null)
                        {
                            if (environmentRule.Machines.Any(machineRule => string.Compare(machineRule, machine, StringComparison.InvariantCultureIgnoreCase) == 0))
                            {
                                environment = environmentRule.EnvironmentName;
                                break;
                            }
                        }
                    }
                }
            }

            foreach (var rule in ruleSet.Rules)
            {
                if (RuleApplies(rule, environment, machine, application, instance))
                {
                    if (rule.ConfigurationData != null)
                    {
                        if (rule.ConfigurationData.Type == JTokenType.Object)
                        {
                            if (config.Type == JTokenType.Object)
                            {
                                ((JObject)config).Merge(rule.ConfigurationData);
                            }
                            else
                            {
                                config = rule.ConfigurationData;
                            }
                        }
                        else if (rule.ConfigurationData.Type == JTokenType.Array)
                        {
                            if (config.Type == JTokenType.Array)
                            {
                                ((JArray)config).Merge(rule.ConfigurationData);
                            }
                            else
                            {
                                config = rule.ConfigurationData;
                            }
                        }
                        else
                        {
                            config = rule.ConfigurationData;
                        }
                    }
                }
            }
            return config;
        }

        public JToken TraceConfig(string environment, string machine, string application, string instance)
        {
            return GetConfig(environment, machine, application, instance);
        }

        private bool RuleApplies(RuleDto rule, string environment, string machine, string application, string instance)
        {
            if (!string.IsNullOrEmpty(rule.Application))
            {
                if (string.Compare(application, rule.Application, StringComparison.InvariantCultureIgnoreCase) != 0)
                    return false;
            }
            if (!string.IsNullOrEmpty(rule.Machine))
            {
                if (string.Compare(application, rule.Application, StringComparison.InvariantCultureIgnoreCase) != 0)
                    return false;
            }
            if (!string.IsNullOrEmpty(rule.Environment))
            {
                if (string.Compare(environment, rule.Environment, StringComparison.InvariantCultureIgnoreCase) != 0)
                    return false;
            }
            if (!string.IsNullOrEmpty(rule.Instance))
            {
                if (string.Compare(instance, rule.Instance, StringComparison.InvariantCultureIgnoreCase) != 0)
                    return false;
            }
            return true;
        }

        public RuleSetDto GetRules()
        {
            // Return a deep copy of the rule set
            return _mapper.Map<RuleSetDto, RuleSetDto>(_ruleSet);
        }

        public void SetRules(RuleSetDto rules)
        {
            // TODO: Order the rules by precedence so that they can be executed linearly
            _ruleSet = rules;
        }

        public void SetDefaultEnvironment(string environmentName)
        {
            var ruleSet = _ruleSet;
            if (ruleSet == null) return;

            ruleSet.DefaultEnvironmentName = environmentName;
        }

        public void SetEnvironments(List<EnvironmentDto> environments)
        {
            var ruleSet = _ruleSet;
            if (ruleSet == null) return;

            ruleSet.Environments = environments;
        }

        public void AddRules(List<RuleDto> newRules)
        {
            var ruleSet = _ruleSet;
            if (ruleSet == null) return;

            // Make a deep copy of the rule set
            ruleSet = _mapper.Map<RuleSetDto, RuleSetDto>(ruleSet);

            foreach (var newRule in newRules)
            {
                if (ruleSet.Rules.Exists(r => string.Compare(r.RuleName, newRule.RuleName, StringComparison.InvariantCultureIgnoreCase) == 0))
                    throw new Exception("There is already a rule with the name " + newRule.RuleName);
                ruleSet.Rules.Add(newRule);
            }

            // Replace the rules with a new set
            SetRules(ruleSet);
        }

        public void UpdateRule(string oldName, RuleDto rule)
        {
            var ruleSet = _ruleSet;
            if (ruleSet == null) return;

            // Make a deep copy of the rule set
            ruleSet = _mapper.Map<RuleSetDto, RuleSetDto>(ruleSet);

            DeleteRule(ruleSet, oldName);
            ruleSet.Rules.Add(rule);

            // Replace the rules with a new set
            SetRules(ruleSet);
        }

        public void DeleteRule(string name)
        {
            DeleteRule(_ruleSet, name);
        }

        private void DeleteRule(RuleSetDto ruleSet, string name)
        {
            if (ruleSet != null)
            {
                var rules = ruleSet.Rules;
                lock (rules)
                {
                    rules.RemoveAll(r => string.Compare(r.RuleName, name, StringComparison.InvariantCultureIgnoreCase) == 0);
                }
            }
        }

    }
}
