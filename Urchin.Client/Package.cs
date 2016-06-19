using System.Collections.Generic;
using Ioc.Modules;
using Urchin.Client.Data;
using Urchin.Client.Interfaces;

namespace Urchin.Client
{
    [Package]
    public class Package : IPackage
    {
        public string Name { get { return "Urchin"; } }
        public IList<IocRegistration> IocRegistrations { get; private set; }

        public Package()
        {
            IocRegistrations = new List<IocRegistration>
            {
                new IocRegistration().Init<IConfigurationStore, ConfigurationStore>(IocLifetime.SingleInstance),
            };
        }
    }
}
