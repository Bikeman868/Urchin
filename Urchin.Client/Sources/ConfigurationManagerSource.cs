using System.Configuration;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using Urchin.Client.Interfaces;

namespace Urchin.Client.Sources
{
    public class ConfigurationManagerSource
    {
        private readonly IConfigurationStore _configurationStore;

        public ConfigurationManagerSource(IConfigurationStore configurationStore)
        {
            _configurationStore = configurationStore;
        }

        public ConfigurationManagerSource Initialize()
        {
            return this;
        }

        public void LoadConfiguration()
        {
            var json = new JObject();

            var appSettings = new JObject();
            foreach (var key in ConfigurationManager.AppSettings.AllKeys)
            {
                var value = ConfigurationManager.AppSettings[key];

                double d;
                if (value == "true" || value == "false" || value == "null" || double.TryParse(value, out d))
                    appSettings.Add(key, JToken.Parse(value));
                else 
                    appSettings.Add(key, JToken.Parse("\"" + value + "\""));
            }
            json.Add("appSettings", appSettings);

            var jsonText = json.ToString(Formatting.None);
            _configurationStore.UpdateConfiguration(jsonText);
        }
    }
}
