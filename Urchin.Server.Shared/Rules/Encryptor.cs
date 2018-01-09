using Urchin.Server.Shared.Interfaces;

namespace Urchin.Server.Shared.Rules
{
    internal class Encryptor: IEncryptor
    {
        public string Encrypt(string dataCenterName, string environmentName, string configurationData)
        {
            return configurationData;
        }
    }
}
