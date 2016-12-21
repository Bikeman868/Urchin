using System.Collections.Generic;
using Ioc.Modules;
using Urchin.Server.Shared.Interfaces;

namespace Urchin.Server.Persistence.Prius
{
    [Package]
    public class Package : IPackage
    {
        public string Name { get { return "Urchin database persister"; } }
        public IList<IocRegistration> IocRegistrations { get; private set; }

        public Package()
        {
            IocRegistrations = new List<IocRegistration>
            {
                new IocRegistration().Init<global::Prius.Contracts.Interfaces.External.IFactory, PriusFactory>(),
                new IocRegistration().Init<global::Prius.Contracts.Interfaces.External.IErrorReporter, PriusErrorReporter>(),
                new IocRegistration().Init<IPersister, DatabasePersister>(),
            };
        }
    }
}
