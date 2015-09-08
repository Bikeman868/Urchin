using System;
using System.Collections.Generic;
using System.Linq;
using System.Security;
using System.Text;
using System.Threading.Tasks;
using Newtonsoft.Json;

namespace Urchin.Server.Shared.DataContracts
{
    public class EnvironmentDto
    {
        [JsonProperty("name")]
        public string EnvironmentName { get; set; }

        [JsonProperty("machines")]
        public List<string> Machines { get; set; }

        [JsonProperty("securityRules")]
        public List<SecurityRuleDto> SecurityRules { get; set; }
    }
}
