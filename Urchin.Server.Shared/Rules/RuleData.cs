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
    public class RuleData: IRuleData
    {
        private readonly IMapper _mapper;
        private readonly IPersister _persister;

        private string _defaultEnvironmentName;
        private List<EnvironmentDto> _environments;
        private List<RuleVersionDto> _rules;
        private List<ApplicationDto> _applications;
        private List<DatacenterDto> _datacenters;
        private List<DatacenterRuleDto> _datacenterRules;

        public RuleData(IMapper mapper, IPersister persister)
        {
            _mapper = mapper;
            _persister = persister;

            ReloadFromPersister();
        }

        #region Methods to support unit tests - do not call from application code

        public void UnitTest_Clear()
        {
            _defaultEnvironmentName = "Development";
            _environments = new List<EnvironmentDto>();
            _rules = new List<RuleVersionDto>();
            _applications = new List<ApplicationDto>();
            _datacenters = new List<DatacenterDto>();
            _datacenterRules = new List<DatacenterRuleDto>();

            _persister.SetDefaultEnvironment(_defaultEnvironmentName);

            foreach (var name in _persister.GetEnvironmentNames().ToList())
                _persister.DeleteEnvironment(name);

            foreach (var versionNumber in _persister.GetVersionNumbers().ToList())
                _persister.DeleteVersion(versionNumber);
        }

        public RuleSetDto UnitTest_GetRuleSet(IClientCredentials clientCredentials, int? version)
        {
            var ruleVersion = GetRuleVersion(clientCredentials, version);
            var ruleSet = new RuleSetDto
            {
                DefaultEnvironmentName = _defaultEnvironmentName,
                Environments = _mapper.Map<List<EnvironmentDto>, List<EnvironmentDto>>(_environments),
                Applications = _mapper.Map<List<ApplicationDto>, List<ApplicationDto>>(_applications),
                Datacenters = _mapper.Map<List<DatacenterDto>, List<DatacenterDto>>(_datacenters),
                DatacenterRules = _mapper.Map<List<DatacenterRuleDto>, List<DatacenterRuleDto>>(_datacenterRules),
                RuleVersion = ruleVersion
            };

            return ruleSet;
        }

        #endregion

        #region Querying for application config

        public JObject GetConfig(IClientCredentials clientCredentials, ref string datacenter, ref string environment, string machine, string application, string instance)
        {
            if (string.IsNullOrWhiteSpace(machine) || string.IsNullOrWhiteSpace(application))
                return new JObject();

            var environmentDto = LookupEnvironment(environment, machine);
            if (environmentDto == null)
                return new JObject();
            environment = environmentDto.EnvironmentName;

            if (string.IsNullOrEmpty(datacenter))
                datacenter = LookupDatacenter(environmentDto, machine, application, instance);

            var ruleVersion = EnsureVersion(environmentDto.Version, false);

            if (ruleVersion == null || ruleVersion.Rules == null || ruleVersion.Rules.Count == 0)
                return new JObject();

            var blockedEnvironments = GetBlockedEnvironments(clientCredentials);
            if (blockedEnvironments != null)
            {
                if (blockedEnvironments.Any(e => String.Equals(e.EnvironmentName, environmentDto.EnvironmentName, StringComparison.InvariantCultureIgnoreCase)))
                    return new JObject();
            }

            var applicableRules = GetApplicableRules(ruleVersion, environmentDto, datacenter, machine, application, instance);
            return MergeRules(applicableRules, environmentDto, datacenter, machine, application, instance);
        }

        public JObject TraceConfig(IClientCredentials clientCredentials, ref string datacenter, ref string environment, string machine, string application, string instance)
        {
            var response = new JObject();

            if (string.IsNullOrWhiteSpace(machine) || string.IsNullOrWhiteSpace(application))
                return response;

            var environmentDto = LookupEnvironment(environment, machine);
            if (environmentDto == null)
            {
                response["error"] = "There is no such environment configured";
                return response;
            }
            environment = environmentDto.EnvironmentName;
            var ruleVersion = EnsureVersion(environmentDto.Version, false);

            if (string.IsNullOrEmpty(datacenter))
                datacenter = LookupDatacenter(environmentDto, machine, application, instance);

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

            var serializedEnvironment = JsonConvert.SerializeObject(environmentDto);

            var applicableRules = GetApplicableRules(ruleVersion, environmentDto, datacenter, machine, application, instance);
            var serializedRules = JsonConvert.SerializeObject(applicableRules);

            var variables = MergeVariables(applicableRules, environmentDto, datacenter, machine, application, instance);
            var serializedVariables = JsonConvert.SerializeObject(variables);

            response["config"] = MergeRules(applicableRules, environmentDto, datacenter, machine, application, instance);
            response["environment"] = JToken.Parse(serializedEnvironment);
            response["variables"] = JToken.Parse(serializedVariables);
            response["matchingRules"] = JToken.Parse(serializedRules);

            return response;
        }

        public JObject TestConfig(IClientCredentials clientCredentials, int? version, ref string datacenter, ref string environment, string machine, string application, string instance)
        {
            if (string.IsNullOrWhiteSpace(machine) || string.IsNullOrWhiteSpace(application))
                return new JObject();

            var environmentDto = LookupEnvironment(environment, machine);
            if (environmentDto == null)
                return new JObject();
            environment = environmentDto.EnvironmentName;

            if (string.IsNullOrEmpty(datacenter))
                datacenter = LookupDatacenter(environmentDto, machine, application, instance);

            if (!version.HasValue) version = GetDraftVersion();
            var ruleVersion = EnsureVersion(version.Value, false);

            if (ruleVersion == null || ruleVersion.Rules == null || ruleVersion.Rules.Count == 0)
                return new JObject();

            var blockedEnvironments = GetBlockedEnvironments(clientCredentials);
            if (blockedEnvironments != null)
            {
                if (blockedEnvironments.Any(e => String.Equals(e.EnvironmentName, environmentDto.EnvironmentName, StringComparison.InvariantCultureIgnoreCase)))
                    return new JObject();
            }

            var applicableRules = GetApplicableRules(ruleVersion, environmentDto, datacenter, machine, application, instance);
            return MergeRules(applicableRules, environmentDto, datacenter, machine, application, instance);
        }

        #endregion

        #region Environment administration

        public string GetDefaultEnvironment()
        {
            return _defaultEnvironmentName;
        }

        public List<EnvironmentDto> GetEnvironments(IClientCredentials clientCredentials)
        {
            var environments = _environments;
            return environments == null 
                ? null
                : _mapper.Map<List<EnvironmentDto>, List<EnvironmentDto>>(environments);
        }

        public void SetDefaultEnvironment(IClientCredentials clientCredentials, string environmentName)
        {
            var blockedEnvironments = GetBlockedEnvironments(clientCredentials);

            if (blockedEnvironments != null && blockedEnvironments.Any(e => string.Equals(e.EnvironmentName, environmentName, StringComparison.InvariantCultureIgnoreCase)))
                throw new Exception("You do not have permission to set " + environmentName + " as the default environment");

            if (blockedEnvironments != null && blockedEnvironments.Any(e => string.Equals(e.EnvironmentName, _defaultEnvironmentName, StringComparison.InvariantCultureIgnoreCase)))
                throw new Exception("You do not have permission to make " + _defaultEnvironmentName + " no longer the default environment");

            _persister.SetDefaultEnvironment(environmentName);
            _defaultEnvironmentName = environmentName;
        }

        public void SetEnvironments(IClientCredentials clientCredentials, List<EnvironmentDto> environments)
        {
            var blockedEnvironments = GetBlockedEnvironments(clientCredentials);

            var currentEnvironments = _environments;
            if (currentEnvironments == null)
                currentEnvironments = new List<EnvironmentDto>();

            var toDelete = new List<string>();
            var toAdd = new List<EnvironmentDto>();

            Func<EnvironmentDto, EnvironmentDto, bool> eq =
                (e1, e2) => string.Equals(e1.EnvironmentName, e2.EnvironmentName, StringComparison.InvariantCultureIgnoreCase);

            var someUpdatesBlocked = false;

            lock (currentEnvironments)
            {
                if (environments == null || environments.Count == 0)
                {
                    foreach (var environment in currentEnvironments)
                    {
                        if (blockedEnvironments.Any(e => eq(e, environment)))
                            someUpdatesBlocked = true;
                        else
                            toDelete.Add(environment.EnvironmentName);
                    }
                }
                else
                {
                    foreach (var environment in currentEnvironments)
                    {
                        if (blockedEnvironments.Any(e => eq(e, environment)))
                            someUpdatesBlocked = true;
                        else
                            toDelete.Add(environment.EnvironmentName);
                    }

                    foreach (var environment in environments)
                    {
                        if (blockedEnvironments.Any(e => eq(e, environment)))
                            someUpdatesBlocked = true;
                        else
                            toAdd.Add(environment);
                    }
                }
            }

            foreach (var environment in toDelete)
                _persister.DeleteEnvironment(environment);

            lock (currentEnvironments)
            {
                currentEnvironments = currentEnvironments
                    .Where(e => !toDelete.Any(d => string.Equals(d, e.EnvironmentName, StringComparison.InvariantCultureIgnoreCase)))
                    .ToList();
            }

            foreach (var environment in toAdd)
            {
                _persister.InsertOrUpdateEnvironment(environment);
                lock(currentEnvironments)
                    currentEnvironments.Add(environment);
            }

            _environments = currentEnvironments;

            if (someUpdatesBlocked)
                throw new Exception("Some environments were not updated because you don't have permission");
        }

        public void SetEnvironmentVersion(IClientCredentials clientCredentials, string environmentName, int version)
        {
            var environments = _environments;
            if (environments == null)
                return;

            var blockedEnvironments = GetBlockedEnvironments(clientCredentials);

            if (blockedEnvironments != null && blockedEnvironments.Any(e => string.Equals(e.EnvironmentName, environmentName, StringComparison.InvariantCultureIgnoreCase)))
                throw new Exception("You do not have permission to change the rule version for the " + environmentName + " environment");

            lock (environments)
            {
                var environment = environments.FirstOrDefault(e => string.Equals(e.EnvironmentName, environmentName, StringComparison.InvariantCultureIgnoreCase));
                if (environment != null)
                {
                    environment.Version = version;
                    _persister.InsertOrUpdateEnvironment(environment);
                }
            }
        }


        #endregion

        #region Rule administration

        public RuleVersionDto GetRuleVersion(IClientCredentials clientCredentials, int? version = null)
        {
            if (!version.HasValue) version = GetDraftVersion();
            var ruleVersion = EnsureVersion(version.Value, false);

            if (ruleVersion == null) return null;

            var blockedEnvironments = GetBlockedEnvironments(clientCredentials) ?? new List<EnvironmentDto>();
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

            var filteredVersion = new RuleVersionDto
            {
                Version = ruleVersion.Version,
                Name = ruleVersion.Name,
                Rules = _mapper.Map<IEnumerable<RuleDto>, List<RuleDto>>(ruleVersion.Rules.Where(isAllowed))
            };

            return filteredVersion;
        }

        public void AddRules(IClientCredentials clientCredentials, int version, List<RuleDto> newRules)
        {
            if (newRules == null) return;

            var ruleVersion = EnsureVersion(version, true);
            if (ruleVersion == null)
                throw new Exception("There is no version of the rules with this RuleVersion number");

            var blockedEnvironments = GetBlockedEnvironments(clientCredentials) ?? new List<EnvironmentDto>();
            var blockedMachineNemes = GetBlockedMachines(blockedEnvironments);
            var blockedEnvironmentNames = blockedEnvironments.Select(e => e.EnvironmentName.ToLower()).ToList();

            // Make a deep copy of the rule list in a thread-safe way
            var rules = _mapper.Map<List<RuleDto>, List<RuleDto>>(ruleVersion.Rules);

            // Add the new rules
            foreach (var newRule in newRules)
            {
                if (rules.Exists(r => string.Equals(r.RuleName, newRule.RuleName, StringComparison.InvariantCultureIgnoreCase)))
                    throw new Exception("There is already a rule with the name " + newRule.RuleName);

                if (string.IsNullOrEmpty(newRule.Environment))
                {
                    if (blockedEnvironments.Count > 0)
                        throw new Exception("You do not have permission to add rules that affect all environments");
                }
                else
                {
                    if (blockedEnvironmentNames.Contains(newRule.Environment.ToLower()))
                        throw new Exception("You do not have permission to add rules for the " + newRule.Environment + " environment");
                }

                if (!string.IsNullOrEmpty(newRule.Machine))
                {
                    if (blockedMachineNemes.Contains(newRule.Machine.ToLower()))
                        throw new Exception("You do not have permission to add rules for the " + newRule.Machine + " machine");
                }

                _persister.InsertOrUpdateRule(version, newRule);
                rules.Add(newRule);
            }
            SetEvaluationOrder(rules);
            ruleVersion.Rules = rules;
        }

        public void UpdateRule(IClientCredentials clientCredentials, int version, string oldName, RuleDto rule)
        {
            var ruleVersion = EnsureVersion(version, false);
            if (ruleVersion == null)
                throw new Exception("There is no version of the rules with this RuleVersion number");

            var blockedEnvironments = GetBlockedEnvironments(clientCredentials) ?? new List<EnvironmentDto>();

            // Make a deep copy of the rule list in a thread-safe way
            var rules = _mapper.Map<List<RuleDto>, List<RuleDto>>(ruleVersion.Rules);

            if (blockedEnvironments.Count > 0)
            {
                var blockedMachineNemes = GetBlockedMachines(blockedEnvironments);
                var blockedEnvironmentNames = blockedEnvironments.Select(e => e.EnvironmentName.ToLower()).ToList();

                var existingRule = rules.FirstOrDefault(r => string.Equals(oldName, r.RuleName, StringComparison.InvariantCultureIgnoreCase));
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

            _persister.DeleteRule(ruleVersion.Version, oldName);
            _persister.DeleteRule(ruleVersion.Version, rule.RuleName);

            rules.RemoveAll(r => string.Compare(r.RuleName, oldName, StringComparison.InvariantCultureIgnoreCase) == 0);
            rules.RemoveAll(r => string.Compare(r.RuleName, rule.RuleName, StringComparison.InvariantCultureIgnoreCase) == 0);

            if (rule.Variables != null)
                rule.Variables = rule.Variables.OrderBy(v => v.VariableName).ToList();

            _persister.InsertOrUpdateRule(version, rule);

            rules.Add(rule);
            SetEvaluationOrder(rules);

            ruleVersion.Rules = rules;
        }

        public void DeleteRule(IClientCredentials clientCredentials, int version, string name)
        {
            var ruleVersion = EnsureVersion(version, false);
            if (ruleVersion == null) return;

            var blockedEnvironments = GetBlockedEnvironments(clientCredentials) ?? new List<EnvironmentDto>();

            // Make a deep copy of the rule list in a thread-safe way
            var rules = _mapper.Map<List<RuleDto>, List<RuleDto>>(ruleVersion.Rules);

            if (blockedEnvironments.Count > 0)
            {
                var blockedMachineNemes = GetBlockedMachines(blockedEnvironments);
                var blockedEnvironmentNames = blockedEnvironments.Select(e => e.EnvironmentName.ToLower()).ToList();

                var existingRule = rules.FirstOrDefault(r => string.Equals(name, r.RuleName, StringComparison.InvariantCultureIgnoreCase));
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

            DeleteRule(ruleVersion, name);
        }

        #endregion

        #region Version administration

        public void RenameVersion(IClientCredentials clientCredentials, int version, string newName)
        {
            var ruleVersion = EnsureVersion(version, true);
            if (ruleVersion == null)
                return;

            ruleVersion.Name = newName;
            _persister.SetVersionName(version, newName);
        }

        public List<VersionNameDto> GetVersions()
        {
            var versionNumbers = _persister.GetVersionNumbers();

            var result = versionNumbers
                .Select(v => new VersionNameDto
                {
                    Version = v,
                    Name = EnsureVersion(v, true).Name ?? "Version " + v
                })
                .ToList();

            return result;
        }

        public void DeleteVersion(IClientCredentials clientCredentials, int version)
        {
            var environments = _environments;
            if (environments != null)
            {
                lock (environments)
                {
                    if (environments.Any(e => e.Version == version))
                        throw new Exception("You can not delete version " + version + 
                            " because it is in use by an environment");
                }
            }

            _persister.DeleteVersion(version);

            var rules = _rules;
            if (rules != null)
            {
                lock(rules)
                {
                    rules.RemoveAll(r => r.Version == version);
                    _rules = rules;
                }
            }
        }

        public void DeleteOldVersions()
        {
            var environments = _environments;
            if (environments == null || environments.Count == 0) return;

            int lowestVersion;
            lock (environments)
            {
                lowestVersion = environments.Aggregate(int.MaxValue, (m, e) => e.Version < m ? e.Version : m);
            }

            var versionsToDelete = _persister.GetVersionNumbers().Where(v => v < lowestVersion);
            foreach(var version in versionsToDelete)
            {
                _persister.DeleteVersion(version);
            }

            var rules = _rules;
            if (rules != null)
            {
                lock (rules)
                {
                    rules.RemoveAll(r => r.Version < lowestVersion);
                    _rules = rules;
                }
            }
        }

        #endregion

        #region Application administration

        public List<ApplicationDto> GetApplications(IClientCredentials clientCredentials)
        {
            var applications = _applications;
            return applications == null
                ? null
                : _mapper.Map<List<ApplicationDto>, List<ApplicationDto>>(applications);
        }

        public void SetApplications(IClientCredentials clientCredentials, List<ApplicationDto> applications)
        {
            _applications = applications.OrderBy(a => a.Name).ToList();
            _persister.ReplaceApplications(applications);
        }

        #endregion

        #region Datacenter administration

        public List<DatacenterDto> GetDatacenters(IClientCredentials clientCredentials)
        {
            var datacenters = _datacenters;
            return datacenters == null
                ? null
                : _mapper.Map<List<DatacenterDto>, List<DatacenterDto>>(datacenters);
        }

        public List<DatacenterRuleDto> GetDatacenterRules(IClientCredentials clientCredentials)
        {
            var datacenterRules = _datacenterRules;
            return datacenterRules == null
                ? null
                : _mapper.Map<List<DatacenterRuleDto>, List<DatacenterRuleDto>>(datacenterRules);
        }

        public void SetDatacenters(IClientCredentials clientCredentials, List<DatacenterDto> datacenters)
        {
            _datacenters = datacenters;
            _persister.ReplaceDatacenters(datacenters);
        }

        public void SetDatacenterRules(IClientCredentials clientCredentials, List<DatacenterRuleDto> datacenterRules)
        {
            SetEvaluationOrder(datacenterRules);
            _datacenterRules = datacenterRules;
            _persister.ReplaceDatacenterRules(datacenterRules);
        }

        #endregion

        #region Private methods

        private int GetDraftVersion()
        {
            var highestVersionNumber = _persister.GetVersionNumbers().Aggregate(0, (s, v) => v > s ? v : s);
            highestVersionNumber = _rules.Aggregate(highestVersionNumber, (s, r) => r.Version > s ? r.Version : s);

            var highestEnvironmentVersion = _environments.Aggregate(0, (s, e) => e.Version > s ? e.Version : s);
            var draftVersion = highestEnvironmentVersion >= highestVersionNumber ? highestEnvironmentVersion + 1 : highestVersionNumber;

            if (draftVersion == 0 || highestEnvironmentVersion == 0)
            {
                draftVersion = 1;
                CreateRuleVersion(draftVersion);
            }
            else
            {
                if (draftVersion > highestVersionNumber)
                {
                    var highestVersion = EnsureVersion(highestVersionNumber, true);
                    var ruleVersion = CreateRuleVersion(draftVersion);
                    ruleVersion.Rules = _mapper.Map<List<RuleDto>, List<RuleDto>>(highestVersion.Rules);
                }
            }
            return draftVersion;
        }

        private void SetEvaluationOrder(RuleVersionDto ruleVersion)
        {
            SetEvaluationOrder(ruleVersion.Rules);
        }

        private void SetEvaluationOrder(List<RuleDto> rules)
        {
            if (rules != null)
            {
                foreach (var rule in rules)
                {
                    rule.EvaluationOrder = string.Empty;
                    if (!string.IsNullOrWhiteSpace(rule.Instance)) rule.EvaluationOrder += 'E';
                    if (!string.IsNullOrWhiteSpace(rule.Machine)) rule.EvaluationOrder += 'D';
                    if (!string.IsNullOrWhiteSpace(rule.Application)) rule.EvaluationOrder += 'C';
                    if (!string.IsNullOrWhiteSpace(rule.Datacenter)) rule.EvaluationOrder += 'B';
                    if (!string.IsNullOrWhiteSpace(rule.Environment)) rule.EvaluationOrder += 'A';
                }
                rules.Sort(new RuleComparer());
            }
        }

        private void SetEvaluationOrder(List<DatacenterRuleDto> datacenterRules)
        {
            if (datacenterRules != null)
            {
                foreach (var datacenterRule in datacenterRules)
                {
                    datacenterRule.EvaluationOrder = string.Empty;
                    if (!string.IsNullOrWhiteSpace(datacenterRule.Instance)) datacenterRule.EvaluationOrder += 'D';
                    if (!string.IsNullOrWhiteSpace(datacenterRule.Machine)) datacenterRule.EvaluationOrder += 'C';
                    if (!string.IsNullOrWhiteSpace(datacenterRule.Application)) datacenterRule.EvaluationOrder += 'B';
                    if (!string.IsNullOrWhiteSpace(datacenterRule.Environment)) datacenterRule.EvaluationOrder += 'A';
                }
                datacenterRules.Sort(new DatacenterRuleComparer());
            }
        }

        private JObject MergeRules(
            IList<RuleDto> rules,
            EnvironmentDto environment,
            string datacenter,
            string machine,
            string application,
            string instance)
        {
            var variables = MergeVariables(rules, environment, datacenter, machine, application, instance);

            var mergeSettings = new JsonMergeSettings 
            { 
                MergeArrayHandling = MergeArrayHandling.Replace
            };

            var config = new JObject();
            foreach (var rule in rules)
            {
                if (!string.IsNullOrWhiteSpace(rule.ConfigurationData))
                {
                    var json = ParseJson(rule.ConfigurationData, variables);
                    config.Merge(json, mergeSettings);
                }
            }
            return config;
        }

        private Dictionary<string, string> MergeVariables(
            IEnumerable<RuleDto> rules,
            EnvironmentDto environment,
            string datacenter,
            string machine,
            string application,
            string instance)
        {
            var variables = new Dictionary<string, string>
            {
                {"environment", environment == null ? string.Empty : environment.EnvironmentName.ToLower()},
                {"machine", machine == null ? string.Empty : machine.ToLower()},
                {"application", application == null ? string.Empty : application.ToLower()},
                {"instance", instance == null ? string.Empty : instance.ToLower()},
                {"datacenter", datacenter == null ? string.Empty : datacenter.ToLower()}
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
            string datacenter,
            string machine,
            string application,
            string instance)
        {
            if (ruleVersion == null || ruleVersion.Rules == null || ruleVersion.Rules.Count == 0)
                return new List<RuleDto>();

            return ruleVersion.Rules.Where(r => RuleApplies(r, environment, datacenter, machine, application, instance)).ToList();
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
                return environments.FirstOrDefault(e => string.Equals(e.EnvironmentName, environmentName, StringComparison.InvariantCultureIgnoreCase));
            }

            foreach (var environment in environments)
            {
                if (environment.Machines == null) continue;
                if (environment.Machines.Any(
                    machine => string.Equals(machine.Name, machineName, StringComparison.InvariantCultureIgnoreCase)))
                {
                    return environment;
                }
            }
            return environments.FirstOrDefault(e => string.Equals(e.EnvironmentName, _defaultEnvironmentName, StringComparison.InvariantCultureIgnoreCase));
        }

        private string LookupDatacenter(EnvironmentDto environment, string machine, string application, string instance)
        {
            var datacenterRules = _datacenterRules;
            if (datacenterRules == null) return null;

            var datacenterName = string.Empty;
            foreach (var datacenterRule in datacenterRules)
            {
                if (RuleApplies(datacenterRule, environment, machine, application, instance))
                    datacenterName = datacenterRule.DatacenterName;
            }

            return datacenterName;
        }

        private bool RuleApplies(RuleDto rule, EnvironmentDto environment, string datacenter, string machine, string application, string instance)
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
            if (!string.IsNullOrEmpty(rule.Datacenter))
            {
                if (!string.Equals(datacenter, rule.Datacenter, StringComparison.InvariantCultureIgnoreCase))
                    return false;
            }
            return true;
        }

        private bool RuleApplies(DatacenterRuleDto rule, EnvironmentDto environment, string machine, string application, string instance)
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
            if (blockedEnvironments == null)
                return null;

            return blockedEnvironments.Aggregate(
                new List<string>(),
                (l, e) =>
                {
                    if (e.Machines != null)
                        l.AddRange(e.Machines.Select(m => m.Name.ToLower()));
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
            _applications = _persister.GetApplications().ToList();
            _datacenters = _persister.GetDatacenters().ToList();

            var datacenterRules = _persister.GetDatacenterRules().ToList();
            SetEvaluationOrder(datacenterRules);
            _datacenterRules = datacenterRules;

            _rules = new List<RuleVersionDto>();
        }

        private RuleVersionDto EnsureVersion(int versionNumber, bool createIfMissing)
        {
            var rules = _rules;
            lock (rules)
            {
                var ruleVersion = rules.FirstOrDefault(r => r.Version == versionNumber);
                if (ruleVersion == null)
                {
                    var ruleList = _persister.GetAllRules(versionNumber);
                    if (ruleList == null)
                    {
                        if (createIfMissing)
                        {
                            ruleVersion = CreateRuleVersion(versionNumber);
                        }
                    }
                    else
                    {
                        var versionName = _persister.GetVersionName(versionNumber);
                        ruleVersion = new RuleVersionDto
                        {
                            Version = versionNumber,
                            Rules = ruleList.ToList(),
                            Name = versionName ?? "Version " + versionNumber

                        };
                        SetEvaluationOrder(ruleVersion);
                        rules.Add(ruleVersion);
                    }
                }
                return ruleVersion;
            }
        }

        private void DeleteRule(RuleVersionDto ruleVersion, string name)
        {
            _persister.DeleteRule(ruleVersion.Version, name);

            var rules = ruleVersion.Rules;
            lock (rules)
            {
                rules.RemoveAll(r => string.Compare(r.RuleName, name, StringComparison.InvariantCultureIgnoreCase) == 0);
            }
        }

        private RuleVersionDto CreateRuleVersion(int versionNumber)
        {
            var ruleVersion = new RuleVersionDto
            {
                Version = versionNumber,
                Name = "Version " + versionNumber,
                Rules = new List<RuleDto>()
            };

            var rules = _rules ?? new List<RuleVersionDto>();
            lock (rules) rules.Add(ruleVersion);
            _rules = rules;

            return ruleVersion;
        }

        #endregion

        private class RuleComparer : IComparer<RuleDto>
        {
            public int Compare(RuleDto x, RuleDto y)
            {
                if (x.EvaluationOrder.Length < y.EvaluationOrder.Length) return -1;
                if (x.EvaluationOrder.Length > y.EvaluationOrder.Length) return 1;
                var result = string.Compare(x.EvaluationOrder, y.EvaluationOrder, StringComparison.Ordinal);
                if (result == 0)
                    result = string.Compare(x.RuleName, y.RuleName, StringComparison.Ordinal);
                return result;
            }
        }

        private class DatacenterRuleComparer : IComparer<DatacenterRuleDto>
        {
            public int Compare(DatacenterRuleDto x, DatacenterRuleDto y)
            {
                if (x.EvaluationOrder.Length < y.EvaluationOrder.Length) return -1;
                if (x.EvaluationOrder.Length > y.EvaluationOrder.Length) return 1;
                return string.Compare(x.EvaluationOrder, y.EvaluationOrder, StringComparison.Ordinal);
            }
        }
    }
}
