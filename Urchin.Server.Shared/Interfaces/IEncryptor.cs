using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Urchin.Server.Shared.Interfaces
{
    public interface IEncryptor
    {
        /// <summary>
        /// This is used to optionally encrypt the configuration data before returning it to the
        /// client application.
        /// </summary>
        /// <param name="dataCenterName">The name of the datacenter that the configuration is for</param>
        /// <param name="environmentName">The name of the environment that the configuration is for</param>
        /// <param name="configurationData">The configuration data to optionally encrypt</param>
        /// <returns>An encrypted version of the configuration data or the original configuration data
        /// Note that the client-side decryption must be provided when calling the Initialize()
        /// method of the ConfigurationStore in the client application.</returns>
        string Encrypt(
            string dataCenterName, 
            string environmentName, 
            string configurationData);
    }
}
