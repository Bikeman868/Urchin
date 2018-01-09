using Urchin.Server.Shared.Interfaces;

namespace Urchin.Server.Shared.Rules
{
    /// <summary>
    /// This is the default encryptor that is used when the deployment does not
    /// include a custom one.
    /// </summary>
    internal class Encryptor: IEncryptor
    {
        public string Encrypt(string dataCenterName, string environmentName, string configurationData)
        {
            return configurationData;
        }
    }
}
