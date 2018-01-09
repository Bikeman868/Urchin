using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Urchin.Server.Shared.Interfaces;

namespace Urchin.TestEncryptor
{
    public class TestEncryptor: IEncryptor
    {
        public string Encrypt(string datacenterName, string environmentName, string configurationData)
        {
            if (string.Equals(datacenterName, "localhost", StringComparison.OrdinalIgnoreCase))
                return configurationData;

            return configurationData.Replace('{', '@').Replace('}', '@');
        }
    }
}
