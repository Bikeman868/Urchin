using System;
using Newtonsoft.Json;
using Urchin.Server.Shared.Interfaces;

namespace Urchin.Server.Shared.Rules
{
    public class ClientCredentialsDto: IClientCredentials
    {
        [JsonProperty("ip")]
        public string IpAddress { get; set; }

        [JsonProperty("admin")]
        public bool IsAdministrator { get; set; }

        [JsonProperty("loggedOn")]
        public bool IsLoggedOn { get; set; }

        [JsonProperty("userName")]
        public string Username { get; set; }
    }
}
