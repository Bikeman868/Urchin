using Newtonsoft.Json.Linq;
using System.Collections.Generic;
using Urchin.Server.Shared.DataContracts;

namespace Urchin.Server.Shared.Interfaces
{
    public interface IConfigRules
    {
        JObject GetConfig(string environment, string machine, string application, string instance);
        JObject TraceConfig(string environment, string machine, string application, string instance);
        JObject TestConfig(RuleSetDto ruleSet, string environment, string machine, string application, string instance);

        RuleSetDto GetRuleSet();

        void Clear();
        void SetRuleSet(RuleSetDto rules);

        void SetDefaultEnvironment(string environmentName);
        void SetEnvironments(List<EnvironmentDto> environments);

        void AddRules(List<RuleDto> newRules);
        void UpdateRule(string oldName, RuleDto rule);
        void DeleteRule(string name);
    }
}
