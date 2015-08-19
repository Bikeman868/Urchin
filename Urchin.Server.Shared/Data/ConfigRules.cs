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
    }
}
