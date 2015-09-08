using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Urchin.Server.Shared.Interfaces
{
    public interface IClientCredentials
    {
        string IpAddress { get; }
        bool IsLoggedOn { get; }
        bool IsAdministrator { get; }
        string Username { get; }
    }
}
