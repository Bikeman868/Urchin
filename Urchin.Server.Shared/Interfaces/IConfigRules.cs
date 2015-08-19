using Newtonsoft.Json.Linq;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Urchin.Server.Shared.Interfaces
{
    public interface IConfigRules
    {
        JToken GetConfig(string environment, string machine, string application, string instance);
    }
}
