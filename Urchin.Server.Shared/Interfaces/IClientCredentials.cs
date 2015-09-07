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
        bool IsAdministrator { get; }
    }
}
