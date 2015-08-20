using System;
using Newtonsoft.Json.Linq;
using Urchin.Server.Shared.Interfaces;

namespace Urchin.Server.Shared.Data
{
    public class ConfigRules: IConfigRules
    {
        public JToken GetConfig(string environment, string machine, string application, string instance)
        {
            var config = new JObject();
            config.Add("test", 1234);
            return config;
        }

        public JToken TraceConfig(string environment, string machine, string application, string instance)
        {
            var config = new JObject();
            config.Add("test", 1234);
            return config;
        }

        public DataContracts.RuleSetDto GetRules()
        {
            throw new NotImplementedException();
        }

        public void SetRules(DataContracts.RuleSetDto rules)
        {
            throw new NotImplementedException();
        }

        public void SetDefaultEnvironment(string environmentName)
        {
            throw new NotImplementedException();
        }

        public void SetEnvironments(System.Collections.Generic.List<DataContracts.EnvironmentDto> environments)
        {
            throw new NotImplementedException();
        }

        public void AddRules(System.Collections.Generic.List<DataContracts.RuleDto> newRules)
        {
            throw new NotImplementedException();
        }

        public void UpdateRule(string name, DataContracts.RuleDto rule)
        {
            throw new NotImplementedException();
        }

        public void DeleteRule(string name)
        {
            throw new NotImplementedException();
        }
    }
}
