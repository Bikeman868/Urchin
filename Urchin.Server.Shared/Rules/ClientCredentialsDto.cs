using System;
using Urchin.Server.Shared.Interfaces;

namespace Urchin.Server.Shared.Rules
{
    public class ClientCredentialsDto: IClientCredentials
    {
        public string IpAddress { get; set; }
        public bool IsAdministrator { get; set; }
    }
}
