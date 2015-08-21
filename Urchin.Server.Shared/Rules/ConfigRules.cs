using System;
using System.Collections.Generic;
using System.Linq;
using System.Text.RegularExpressions;
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

            var defaultRuleSet = new RuleSetDto
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
                        RuleName = "DevelopmentEnvironment",
                        Environment = "Development",
                        ConfigurationData = "{\"debug\":true}"
                    },
                    new RuleDto
                    {
                        RuleName = "Root",
                        ConfigurationData = "{\"environment\":\"($environment$)\",\"machine\":\"($machine$)\",\"application\":\"($application$)\",\"debug\":false}"
                    }
                }
            };

            SetRules(defaultRuleSet);
        }

        public void Clear()
        {
            SetRules(new RuleSetDto());
        }

        public JObject GetConfig(string environment, string machine, string application, string instance)
        {
            var config = new JObject();

            if (string.IsNullOrWhiteSpace(machine) || string.IsNullOrWhiteSpace(application))
                return config;

            var ruleSet = _ruleSet;
            if (ruleSet == null || ruleSet.Rules == null || ruleSet.Rules.Count == 0) 
                return config;

            environment = LookupEnvironment(environment, machine, ruleSet);

            var variables = new Dictionary<string, string>
            {
                {"environment", environment},
                {"machine", machine},
                {"application", application},
                {"instance", instance}
            };

            foreach (var rule in ruleSet.Rules)
            {
                if (RuleApplies(rule, environment, machine, application, instance))
                {
                    if (rule.Variables != null)
                    {
                        foreach (var variable in rule.Variables)
                        {
                            variables[variable.VariableName.ToLower()] = variable.SubstitutionValue;
                        }
                    }
                    if (!string.IsNullOrWhiteSpace(rule.ConfigurationData))
                    {
                        var json = ParseJson(rule.ConfigurationData, variables);
                        config.Merge(json);
                    }
                }
            }
            return config;
        }

        private readonly Regex _substitutionRegex = new Regex(@"\(\$(.+?)\$\)", RegexOptions.Compiled | RegexOptions.IgnoreCase | RegexOptions.Singleline);

        private JToken ParseJson(string json, Dictionary<string, string> variables)
        {
            Func<Match, string> substitutionFunction = 
                m =>
                {
                    var variableName = m.Groups[1].Value;
                    string value;
                    return variables.TryGetValue(variableName.ToLower(), out value) 
                        ? value 
                        : string.Empty;
                };
            var matchEvaluator = new MatchEvaluator(substitutionFunction);
            json = _substitutionRegex.Replace(json, matchEvaluator);
            return JToken.Parse(json);
        }

        private static string LookupEnvironment(string environment, string machine, RuleSetDto ruleSet)
        {
            if (!string.IsNullOrWhiteSpace(environment)) return environment;

            if (ruleSet.Environments != null)
            {
                foreach (var environmentRule in ruleSet.Environments)
                {
                    if (environmentRule.Machines != null)
                    {
                        if (
                            environmentRule.Machines.Any(
                                machineRule =>
                                    string.Compare(machineRule, machine, StringComparison.InvariantCultureIgnoreCase) == 0))
                        {
                            return environmentRule.EnvironmentName;
                        }
                    }
                }
            }

            return ruleSet.DefaultEnvironmentName;
        }

        public JObject TraceConfig(string environment, string machine, string application, string instance)
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
                if (string.Compare(machine, rule.Machine, StringComparison.InvariantCultureIgnoreCase) != 0)
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

        public void SetRules(RuleSetDto ruleSet)
        {
            if (ruleSet.Rules != null)
            {
                foreach (var rule in ruleSet.Rules)
                {
                    rule.EvaluationOrder = string.Empty;
                    if (!string.IsNullOrWhiteSpace(rule.Instance)) rule.EvaluationOrder += 'D';
                    if (!string.IsNullOrWhiteSpace(rule.Machine)) rule.EvaluationOrder += 'C';
                    if (!string.IsNullOrWhiteSpace(rule.Application)) rule.EvaluationOrder += 'B';
                    if (!string.IsNullOrWhiteSpace(rule.Environment)) rule.EvaluationOrder += 'A';
                }
                ruleSet.Rules.Sort(new RuleComparer());
            }

            _ruleSet = ruleSet;
        }

        private class RuleComparer: IComparer<RuleDto>
        {
            public int Compare(RuleDto x, RuleDto y)
            {
                if (x.EvaluationOrder.Length < y.EvaluationOrder.Length) return -1;
                if (x.EvaluationOrder.Length > y.EvaluationOrder.Length) return 1;
                return string.Compare(x.EvaluationOrder, y.EvaluationOrder, StringComparison.Ordinal);
            }
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
