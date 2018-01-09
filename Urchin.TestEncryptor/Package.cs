using System.Collections.Generic;
using Ioc.Modules;
using Urchin.Server.Shared.Interfaces;

namespace Urchin.TestEncryptor
{
    [Package]
    public class Package : IPackage
    {
        public string Name { get { return "Urchin test encryptor"; } }
        public IList<IocRegistration> IocRegistrations { get; private set; }

        public Package()
        {
            IocRegistrations = new List<IocRegistration>
            {
                new IocRegistration().Init<IEncryptor, TestEncryptor>(),
            };
        }
    }
}
