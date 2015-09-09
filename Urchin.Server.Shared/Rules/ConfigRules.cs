using System;
using System.Collections.Generic;
using System.Linq;
using System.Text.RegularExpressions;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using Urchin.Server.Shared.DataContracts;
using Urchin.Server.Shared.Interfaces;

namespace Urchin.Server.Shared.Rules
{
    public class ConfigRules: IConfigRules
    {
        private readonly IMapper _mapper;
        private readonly IPersister _persister;

        private string _defaultEnvironmentName;
        private List<EnvironmentDto> _environments;
        private List<RuleVersionDto> _rules;
        private int _highestVersionNumber;

        public ConfigRules(IMapper mapper, IPersister persister)
        {
            _mapper = mapper;
            _persister = persister;

            ReloadFromPersister();
        }

        public void Clear(IClientCredentials clientCredentials)
        {
            _defaultEnvironmentName = "Development";
            _environments = new List<EnvironmentDto>();
            _rules = new List<RuleVersionDto>();
        }

        public JObject GetCurrentConfig(IClientCredentials clientCredentials, string environment, string machine, string application, string instance)
        {
            if (string.IsNullOrWhiteSpace(machine) || string.IsNullOrWhiteSpace(application))
                return new JObject();

            var environmentDto = LookupEnvironment(environment, machine);
            var ruleVersion = EnsureVersion(environmentDto.Version);

            if (ruleVersion == null || ruleVersion.Rules == null || ruleVersion.Rules.Count == 0)
                return new JObject();

            var blockedEnvironments = GetBlockedEnvironments(clientCredentials);
            if (blockedEnvironments != null)
            {
                if (blockedEnvironments.Any(e => String.Equals(e.EnvironmentName, environmentDto.EnvironmentName, StringComparison.InvariantCultureIgnoreCase)))
                    return new JObject();
            }

            var applicableRules = GetApplicableRules(ruleVersion, environmentDto, machine, application, instance);
            return MergeRules(applicableRules, environmentDto, machine, application, instance);
        }

        public JObject TraceConfig(IClientCredentials clientCredentials, string environment, string machine, string application, string instance)
        {
            var response = new JObject();

            if (string.IsNullOrWhiteSpace(machine) || string.IsNullOrWhiteSpace(application))
                return response;

            var environmentDto = LookupEnvironment(environment, machine);
            var ruleVersion = EnsureVersion(environmentDto.Version);

            if (ruleVersion == null || ruleVersion.Rules == null || ruleVersion.Rules.Count == 0)
                return response;

            var blockedEnvironments = GetBlockedEnvironments(clientCredentials);
            if (blockedEnvironments != null)
            {
                if (blockedEnvironments.Any(e => String.Equals(e.EnvironmentName, environmentDto.EnvironmentName, StringComparison.InvariantCultureIgnoreCase)))
                {
                    response["error"] = "You do not have permission to retrieve config for this machine";
                    return response;
                }
            }

            var applicableRules = GetApplicableRules(ruleVersion, environmentDto, machine, application, instance);
            var serializedRules = JsonConvert.SerializeObject(applicableRules);

            var variables = MergeVariables(applicableRules, environment, machine, application, instance);
            var serializedVariables = JsonConvert.SerializeObject(variables);

            response["config"] = MergeRules(applicableRules, environmentDto, machine, application, instance);
            response["variables"] = JToken.Parse(serializedVariables);
            response["matchingRules"] = JToken.Parse(serializedRules);

            return response;
        }

        public JObject TestConfig(RuleSetDto ruleSet, string environment, string machine, string application, string instance)
        {
            if (string.IsNullOrWhiteSpace(machine) || string.IsNullOrWhiteSpace(application))
                return new JObject();

            if (ruleSet == null || ruleSet.Rules == null || ruleSet.Rules.Rules == null || ruleSet.Rules.Rules.Count == 0)
                return new JObject();

            // Note that since the entire rule set is provided by the caller, no credentials check is needed here

            var environmentDto = LookupEnvironment(environment, machine);
            var applicableRules = GetApplicableRules(ruleSet.Rules, environmentDto, machine, application, instance);
            return MergeRules(applicableRules, environmentDto, machine, application, instance);
        }

        public RuleSetDto GetRuleSet(IClientCredentials clientCredentials, int? version)
        {
            if (!version.HasValue) version = _highestVersionNumber;
            var ruleVersion = EnsureVersion(version.Value);

            if (ruleVersion == null) return null;

            // Make a deep copy of the rule set
            var ruleSet = _mapper.Map<RuleSetDto, RuleSetDto>(_ruleSet);

            // Get the environments and machines that this client does not have access to
            var blockedEnvironments = GetBlockedEnvironments(ruleSet.Environments, clientCredentials);
            if (blockedEnvironments == null || blockedEnvironments.Count == 0)
                return ruleSet;

            var blockedMachineNemes = GetBlockedMachines(blockedEnvironments);
            var blockedEnvironmentNames = blockedEnvironments.Select(e => e.EnvironmentName.ToLower()).ToList();

            Func<RuleDto, int, bool> isAllowed = (r, i) =>
            {
                if (!string.IsNullOrEmpty(r.Environment))
                    if (blockedEnvironmentNames.Contains(r.Environment.ToLower())) return false;

                if (!string.IsNullOrEmpty(r.Machine))
                    if (blockedMachineNemes.Contains(r.Machine.ToLower())) return false;

                return true;
            };

            // Remove the blocked content from the data
            ruleSet.Rules = ruleSet.Rules.Where(isAllowed).ToList();

            return ruleSet;
        }

        public void SetRuleSet(IClientCredentials clientCredentials, RuleSetDto ruleSet, bool asNewVersion)
        {
            var currentRuleSet = _ruleSet;
            var blockedEnvironments = currentRuleSet == null
                ? null
                : GetBlockedEnvironments(currentRuleSet.Environments, clientCredentials);

            if (blockedEnvironments != null && blockedEnvironments.Count > 0)
                throw new Exception("You do not have permission to replace the entire rule set");

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

        public void SetEvaluationOrder(RuleVersionDto ruleVersion)
        {
            if (ruleVersion.Rules != null)
            {
                foreach (var rule in ruleVersion.Rules)
                {
                    rule.EvaluationOrder = string.Empty;
                    if (!string.IsNullOrWhiteSpace(rule.Instance)) rule.EvaluationOrder += 'D';
                    if (!string.IsNullOrWhiteSpace(rule.Machine)) rule.EvaluationOrder += 'C';
                    if (!string.IsNullOrWhiteSpace(rule.Application)) rule.EvaluationOrder += 'B';
                    if (!string.IsNullOrWhiteSpace(rule.Environment)) rule.EvaluationOrder += 'A';
                }
                ruleVersion.Rules.Sort(new RuleComparer());
            }
        }

        public void SetDefaultEnvironment(IClientCredentials clientCredentials, string environmentName)
        {
            var ruleSet = _ruleSet;
            if (ruleSet == null) return;

            var blockedEnvironments = GetBlockedEnvironments(ruleSet.Environments, clientCredentials);

            if (blockedEnvironments != null && blockedEnvironments.Any(e => string.Equals(e.EnvironmentName, environmentName, StringComparison.InvariantCultureIgnoreCase)))
                throw new Exception("You do not have permission to set " + environmentName + " as the default environment");

            if (blockedEnvironments != null && blockedEnvironments.Any(e => string.Equals(e.EnvironmentName, ruleSet.DefaultEnvironmentName, StringComparison.InvariantCultureIgnoreCase)))
                throw new Exception("You do not have permission to make " + ruleSet.DefaultEnvironmentName + " no longer the default environment");

            _persister.SetDefaultEnvironment(environmentName);

            ruleSet.DefaultEnvironmentName = environmentName;
        }

        public void SetEnvironments(IClientCredentials clientCredentials, List<EnvironmentDto> environments)
        {
            var ruleSet = _ruleSet;
            if (ruleSet == null) return;
            if (ruleSet.Environments == null) ruleSet.Environments = new List<EnvironmentDto>();

            var blockedEnvironments = GetBlockedEnvironments(ruleSet.Environments, clientCredentials);

            var toDelete = new List<string>();
            var toAdd = new List<EnvironmentDto>();

            Func<EnvironmentDto, EnvironmentDto, bool> eq =
                (e1, e2) => string.Equals(e1.EnvironmentName, e2.EnvironmentName, StringComparison.InvariantCultureIgnoreCase);

            if (environments == null || environments.Count == 0)
            {
                if (ruleSet.Environments != null)
                {
                    foreach (var environment in ruleSet.Environments)
                    {
                        if (!blockedEnvironments.Any(e => eq(e, environment)))
                            toDelete.Add(environment.EnvironmentName);
                    }
                }
            }
            else
            {
                foreach (var environment in ruleSet.Environments)
                {
                    if (!blockedEnvironments.Any(e => eq(e, environment)))
                        toDelete.Add(environment.EnvironmentName);
                }

                foreach (var environment in environments)
                {
                    if (!blockedEnvironments.Any(e => eq(e, environment)))
                        toAdd.Add(environment);
                }
            }

            foreach (var environment in toDelete)
                _persister.DeleteEnvironment(environment);

            ruleSet.Environments = ruleSet.Environments
                .Where(e => !toDelete.Any(d => string.Equals(d, e.EnvironmentName, StringComparison.InvariantCultureIgnoreCase)))
                .ToList();

            foreach (var environment in toAdd)
            {
                _persister.InsertOrUpdateEnvironment(environment);
                lock(ruleSet.Environments)
                    ruleSet.Environments.Add(environment);
            }
        }

        public void AddRules(IClientCredentials clientCredentials, List<RuleDto> newRules)
        {
            if (newRules == null) return;

            var ruleSet = _ruleSet;
            if (ruleSet == null) return;

            // Make a deep copy of the rule set in a thread-safe way
            ruleSet = _mapper.Map<RuleSetDto, RuleSetDto>(ruleSet);

            // Get the environments and machines that this client does not have access to
            var blockedEnvironments = GetBlockedEnvironments(ruleSet.Environments, clientCredentials);
            var blockedMachineNemes = GetBlockedMachines(blockedEnvironments);
            var blockedEnvironmentNames = blockedEnvironments.Select(e => e.EnvironmentName.ToLower()).ToList();

            // Add the new rules
            foreach (var newRule in newRules)
            {
                if (ruleSet.Rules.Exists(r => string.Equals(r.RuleName, newRule.RuleName, StringComparison.InvariantCultureIgnoreCase)))
                    throw new Exception("There is already a rule with the name " + newRule.RuleName);
                if (!string.IsNullOrEmpty(newRule.Environment))
                {
                    if (blockedEnvironmentNames.Contains(newRule.Environment.ToLower()))
                        throw new Exception("You do not have permission to add rules for the " + newRule.Environment + " environment");
                }
                if (!string.IsNullOrEmpty(newRule.Machine))
                {
                    if (blockedMachineNemes.Contains(newRule.Machine.ToLower()))
                        throw new Exception("You do not have permission to add rules for the " + newRule.Machine + " machine");
                }
                _persister.InsertOrUpdateRule(newRule);
                ruleSet.Rules.Add(newRule);
            }

            // Replace the rules with a new set
            SetRuleSet(null, ruleSet);
        }

        public void UpdateRule(IClientCredentials clientCredentials, string oldName, RuleDto rule)
        {
            var ruleSet = _ruleSet;
            if (ruleSet == null) return;

            // Make a deep copy of the rule set in a thread-safe way
            ruleSet = _mapper.Map<RuleSetDto, RuleSetDto>(ruleSet);

            // Get the environments and machines that this client does not have access to
            var blockedEnvironments = GetBlockedEnvironments(ruleSet.Environments, clientCredentials);

            if (blockedEnvironments.Count > 0)
            {
                var blockedMachineNemes = GetBlockedMachines(blockedEnvironments);
                var blockedEnvironmentNames = blockedEnvironments.Select(e => e.EnvironmentName.ToLower()).ToList();

                var existingRule =
                    ruleSet.Rules.FirstOrDefault(
                        r => string.Equals(oldName, r.RuleName, StringComparison.InvariantCultureIgnoreCase));
                if (existingRule != null)
                {
                    if (!string.IsNullOrEmpty(existingRule.Environment))
                    {
                        if (blockedEnvironmentNames.Contains(existingRule.Environment.ToLower()))
                            throw new Exception("You do not have permission to update rules for the " +
                                                existingRule.Environment + " environment");
                    }
                    if (!string.IsNullOrEmpty(existingRule.Machine))
                    {
                        if (blockedMachineNemes.Contains(existingRule.Machine.ToLower()))
                            throw new Exception("You do not have permission to update rules for the " +
                                                existingRule.Machine + " machine");
                    }
                }

                if (!string.IsNullOrEmpty(rule.Environment))
                {
                    if (blockedEnvironmentNames.Contains(rule.Environment.ToLower()))
                        throw new Exception("You do not have permission to update rules for the " + rule.Environment +
                                            " environment");
                }
                if (!string.IsNullOrEmpty(rule.Machine))
                {
                    if (blockedMachineNemes.Contains(rule.Machine.ToLower()))
                        throw new Exception("You do not have permission to update rules for the " + rule.Machine +
                                            " machine");
                }
            }

            DeleteRule(ruleSet, oldName);
            DeleteRule(ruleSet, rule.RuleName);

            _persister.InsertOrUpdateRule(rule);
            ruleSet.Rules.Add(rule);

            // Replace the rules with a new set
            SetRuleSet(null, ruleSet);
        }

        public void DeleteRule(IClientCredentials clientCredentials, string name)
        {
            var ruleSet = _ruleSet;
            if (ruleSet == null) return;

            // Get the environments and machines that this client does not have access to
            var blockedEnvironments = GetBlockedEnvironments(ruleSet.Environments, clientCredentials);

            if (blockedEnvironments.Count > 0)
            {
                var blockedMachineNemes = GetBlockedMachines(blockedEnvironments);
                var blockedEnvironmentNames = blockedEnvironments.Select(e => e.EnvironmentName.ToLower()).ToList();

                var existingRule =
                    ruleSet.Rules.FirstOrDefault(
                        r => string.Equals(name, r.RuleName, StringComparison.InvariantCultureIgnoreCase));
                if (existingRule != null)
                {
                    if (!string.IsNullOrEmpty(existingRule.Environment))
                    {
                        if (blockedEnvironmentNames.Contains(existingRule.Environment.ToLower()))
                            throw new Exception("You do not have permission to delete rules for the " +
                                                existingRule.Environment + " environment");
                    }
                    if (!string.IsNullOrEmpty(existingRule.Machine))
                    {
                        if (blockedMachineNemes.Contains(existingRule.Machine.ToLower()))
                            throw new Exception("You do not have permission to delete rules for the " +
                                                existingRule.Machine + " machine");
                    }
                }
            }

            DeleteRule(_ruleSet, name);
        }

        #region Private methods

        private JObject MergeRules(
            IList<RuleDto> rules,
            EnvironmentDto environment,
            string machine,
            string application,
            string instance)
        {
            var variables = MergeVariables(rules, environment, machine, application, instance);

            var config = new JObject();
            foreach (var rule in rules)
            {
                if (!string.IsNullOrWhiteSpace(rule.ConfigurationData))
                {
                    var json = ParseJson(rule.ConfigurationData, variables);
                    config.Merge(json);
                }
            }
            return config;
        }

        private Dictionary<string, string> MergeVariables(
            IEnumerable<RuleDto> rules,
            EnvironmentDto environment,
            string machine,
            string application,
            string instance)
        {
            var variables = new Dictionary<string, string>
            {
                {"environment", environment.EnvironmentName},
                {"machine", machine},
                {"application", application},
                {"instance", instance}
            };

            foreach (var rule in rules)
            {
                if (rule.Variables != null)
                {
                    foreach (var variable in rule.Variables)
                    {
                        variables[variable.VariableName.ToLower()] = variable.SubstitutionValue;
                    }
                }
            }

            return variables;
        }

        private List<RuleDto> GetApplicableRules(
            RuleVersionDto ruleVersion,
            EnvironmentDto environment,
            string machine,
            string application,
            string instance)
        {
            if (ruleVersion == null || ruleVersion.Rules == null || ruleVersion.Rules.Count == 0)
                return new List<RuleDto>();

            return ruleVersion.Rules.Where(r => RuleApplies(r, environment, machine, application, instance)).ToList();
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

            try
            {
                return JToken.Parse(json);
            }
            catch (Exception ex)
            {
                throw new Exception("Failed to parse JSON " + json, ex);
            }
        }

        private EnvironmentDto LookupEnvironment(string environmentName, string machineName)
        {
            var environments = _environments;
            if (environments == null) return null;

            if (!string.IsNullOrWhiteSpace(environmentName))
            {
                return environments.FirstOrDefault(e => string.Equals(e.EnvironmentName, environmentName, StringComparison.InvariantCultureIgnoreCase);
            }

            foreach (var environment in environments)
            {
                if (environment.Machines == null) continue;
                if (environment.Machines.Any(
                    machine => string.Equals(machine, machineName, StringComparison.InvariantCultureIgnoreCase)))
                {
                    return environment;
                }
            }
            return environments.FirstOrDefault(e => string.Equals(e.EnvironmentName, _defaultEnvironmentName, StringComparison.InvariantCultureIgnoreCase);
        }

        private bool RuleApplies(RuleDto rule, EnvironmentDto environment, string machine, string application, string instance)
        {
            if (!string.IsNullOrEmpty(rule.Application))
            {
                if (!string.Equals(application, rule.Application, StringComparison.InvariantCultureIgnoreCase))
                    return false;
            }
            if (!string.IsNullOrEmpty(rule.Machine))
            {
                if (string.Compare(machine, rule.Machine, StringComparison.InvariantCultureIgnoreCase) != 0)
                    return false;
            }
            if (!string.IsNullOrEmpty(rule.Environment))
            {
                if (!string.Equals(environment.EnvironmentName, rule.Environment, StringComparison.InvariantCultureIgnoreCase))
                    return false;
            }
            if (!string.IsNullOrEmpty(rule.Instance))
            {
                if (!string.Equals(instance, rule.Instance, StringComparison.InvariantCultureIgnoreCase))
                    return false;
            }
            return true;
        }

        private IList<string> GetBlockedMachines(IEnumerable<EnvironmentDto> blockedEnvironments)
        {
            return blockedEnvironments.Aggregate(new List<string>(),
                (l, e) =>
                {
                    if (e.Machines != null)
                        l.AddRange(e.Machines.Select(m => m.ToLower()));
                    return l;
                });
        }

        private IList<EnvironmentDto> GetBlockedEnvironments(IClientCredentials clientCredentials)
        {
            var environments = _environments;
            if (environments == null || clientCredentials == null || clientCredentials.IsAdministrator)
                return new List<EnvironmentDto>();

            Func<string, uint> parseIp = (ip) =>
            {
                if (ip.Contains(':')) return 0; // IPv6 address

                var parts = ip.Split('.');
                if (parts.Length != 4)
                    throw new Exception("Invalid IP address format");
                return parts.Aggregate(0u, (s, p) => s * 256 + uint.Parse(p));
            };

            var clientIp = parseIp(clientCredentials.IpAddress);

            Func<EnvironmentDto, int, bool> isBlocked = (environment, i) =>
            {
                if (environment.SecurityRules == null || environment.SecurityRules.Count == 0) return false;
                foreach (var rule in environment.SecurityRules)
                {
                    var start = parseIp(rule.AllowedIpStart);
                    var end = parseIp(rule.AllowedIpEnd);
                    if (clientIp >= start && clientIp <= end) return false;
                }
                return true;
            };

            var blockedEnvironments = environments.Where(isBlocked).ToList();
            return blockedEnvironments;
        }

        private void ReloadFromPersister()
        {
            _defaultEnvironmentName = _persister.GetDefaultEnvironment();
            _environments = _persister.GetAllEnvironments().ToList();
            _rules = new List<RuleVersionDto>();
            _highestVersionNumber = _persister.GetVersionNumbers().Aggregate(0, (s, v) => v > s ? v : s);
        }

        private RuleVersionDto EnsureVersion(int versionNumber)
        {
            var rules = _rules;
            lock (rules)
            {
                RuleVersionDto version;
                if (_persister.SupportsVersioning)
                {
                    version = rules.FirstOrDefault(r => r.Version == versionNumber);
                    if (version == null)
                    {
                        var ruleList = _persister.GetAllRules(versionNumber);
                        if (ruleList != null)
                        {
                            version = new RuleVersionDto
                            {
                                Version = versionNumber,
                                Rules = ruleList.ToList()
                            };
                            SetEvaluationOrder(version);
                            rules.Add(version);
                        }
                    }
                }
                else
                {
                    if (rules.Count == 0)
                    {
                        version = new RuleVersionDto
                        {
                            Rules = _persister.GetAllRules(0).ToList()
                        };
                        SetEvaluationOrder(version);
                        rules.Add(version);
                    }
                    return rules[0];
                }
                return version;
            }
        }

        private void DeleteRule(RuleVersionDto version, string name)
        {
            _persister.DeleteRule(version.Version, name);

            if (version != null)
            {
                var rules = version.Rules;
                lock (rules)
                {
                    rules.RemoveAll(r => string.Compare(r.RuleName, name, StringComparison.InvariantCultureIgnoreCase) == 0);
                }
            }
        }

        #endregion

        private class RuleComparer : IComparer<RuleDto>
        {
            public int Compare(RuleDto x, RuleDto y)
            {
                if (x.EvaluationOrder.Length < y.EvaluationOrder.Length) return -1;
                if (x.EvaluationOrder.Length > y.EvaluationOrder.Length) return 1;
                return string.Compare(x.EvaluationOrder, y.EvaluationOrder, StringComparison.Ordinal);
            }
        }

    }
}
