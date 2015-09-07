using Newtonsoft.Json.Linq;
using System.Collections.Generic;
using Urchin.Server.Shared.DataContracts;

namespace Urchin.Server.Shared.Interfaces
{
    public interface IConfigRules
    {
        JObject GetConfig(IClientCredentials clientCredentials, string environment, string machine, string application, string instance);
        JObject TraceConfig(IClientCredentials clientCredentials, string environment, string machine, string application, string instance);
        JObject TestConfig(RuleSetDto ruleSet, string environment, string machine, string application, string instance);

        RuleSetDto GetRuleSet(IClientCredentials clientCredentials);

        void Clear(IClientCredentials clientCredentials);
        void SetRuleSet(IClientCredentials clientCredentials, RuleSetDto rules);

        void SetDefaultEnvironment(IClientCredentials clientCredentials, string environmentName);
        void SetEnvironments(IClientCredentials clientCredentials, List<EnvironmentDto> environments);

        void AddRules(IClientCredentials clientCredentials, List<RuleDto> newRules);
        void UpdateRule(IClientCredentials clientCredentials, string oldName, RuleDto rules);
        void DeleteRule(IClientCredentials clientCredentials, string name);

        void ReloadFromPersister();
    }
}
