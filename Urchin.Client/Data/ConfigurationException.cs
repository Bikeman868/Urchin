using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Urchin.Client.Data
{
    public class ConfigurationException: Exception
    {
        public ConfigurationException(string path, string message)
            : base("Configuration error in '" + path + "'. " + message)
        {}

        public ConfigurationException(string path, string message, Exception innerException)
            : base("Configuration error in '" + path + "'. " + message, innerException)
        {}
    }
}
