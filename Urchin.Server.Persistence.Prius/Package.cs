using System.Collections.Generic;
using Ioc.Modules;
using Urchin.Server.Persistence.Prius;
using Urchin.Server.Shared.Interfaces;

namespace Urchin.Client
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
                new IocRegistration().Init<Prius.Contracts.Interfaces.External.IFactory, PriusFactory>(),
                new IocRegistration().Init<Prius.Contracts.Interfaces.External.IErrorReporter, PriusErrorReporter>(),
                new IocRegistration().Init<IPersister, DatabasePersister>(),
            };
        }
    }
}
