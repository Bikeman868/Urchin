using System.Collections.Generic;
using Common.Logging;
using Ioc.Modules;
using OwinFramework.Interfaces.Builder;
using OwinFramework.InterfacesV1.Middleware;
using Urchin.Server.Owin.Middleware;

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
                new IocRegistration().Init<IMiddleware<IIdentification>, LogonEndpoint>(),
                new IocRegistration().Init<ILogManager, LogManager>(),
                new IocRegistration().Init<global::Prius.Contracts.Interfaces.External.IFactory, Prius.PriusFactory>(),
                new IocRegistration().Init<global::Prius.Contracts.Interfaces.External.IErrorReporter, Prius.PriusErrorReporter>(),
            };
        }
    }
}
