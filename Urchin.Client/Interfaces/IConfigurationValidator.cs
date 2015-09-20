using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Newtonsoft.Json.Linq;

namespace Urchin.Client.Interfaces
{
    public interface IConfigurationValidator
    {
        bool IsValidConfiguration(JToken configuration);
    }
}
