using System.Collections.Generic;
using Common.Logging;
using Ioc.Modules;
using Urchin.Server.Shared.Interfaces;
using Urchin.Server.Shared.Rules;
using Urchin.Server.Shared.TypeMappings;

namespace Urchin.Server.Owin
{
    [Package]
    public class Package : IPackage
    {
        public string Name { get { return "Urchin on OWIN"; } }
        public IList<IocRegistration> IocRegistrations { get; private set; }

        public Package()
        {
            IocRegistrations = new List<IocRegistration>
            {
                new IocRegistration().Init<ILogManager, LogManager>(),
            };
        }
    }
}
