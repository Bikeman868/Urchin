using System.Collections.Generic;
using Ioc.Modules;
using Prius.Contracts.Interfaces;
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
                new IocRegistration().Init<Prius.Contracts.Interfaces.IFactory, PriusFactory>(IocLifetime.SingleInstance),
                new IocRegistration().Init<IErrorReporter, PriusErrorReporter>(IocLifetime.SingleInstance),
                new IocRegistration().Init<IPersister, DatabasePersister>(IocLifetime.SingleInstance),
            };
        }
    }
}
