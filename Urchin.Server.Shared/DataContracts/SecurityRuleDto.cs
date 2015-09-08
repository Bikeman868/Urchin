using System;
using System.Collections.Generic;
using System.Linq;
using System.Security;
using System.Text;
using System.Threading.Tasks;
using Newtonsoft.Json;

namespace Urchin.Server.Shared.DataContracts
{
    public class SecurityRuleDto
    {
        [JsonProperty("startIp")]
        public string  AllowedIpStart { get; set; }

        [JsonProperty("endIp")]
        public string AllowedIpEnd { get; set; }
    }
}
