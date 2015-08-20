using Newtonsoft.Json.Linq;
using System.Collections.Generic;
using Urchin.Server.Shared.DataContracts;

namespace Urchin.Server.Shared.Interfaces
{
    public interface IConfigRules
    {
        JToken GetConfig(string environment, string machine, string application, string instance);
        JToken TraceConfig(string environment, string machine, string application, string instance);

        RuleSetDto GetRules();

        void SetRules(RuleSetDto rules);

        void SetDefaultEnvironment(string environmentName);
        void SetEnvironments(List<EnvironmentDto> environments);

        void AddRules(List<RuleDto> newRules);
        void UpdateRule(string name, RuleDto rule);
        void DeleteRule(string name);
    }
}
