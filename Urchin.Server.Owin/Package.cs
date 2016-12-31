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
        public string Name { get { return "Urchin"; } }
        public IList<IocRegistration> IocRegistrations { get; private set; }

        public Package()
        {
            IocRegistrations = new List<IocRegistration>
            {
                new IocRegistration().Init<IRuleData, RuleData>(),
                new IocRegistration().Init<IMapper, Mapper>(),
                new IocRegistration().Init<ILogManager, LogManager>(),

                // Register the default persister. If you include the DLLs from any
                // other persister, it will override this registration and become the 
                // persister for your installation.
                new IocRegistration().Init<IPersister, FilePersister>(),
            };
        }
    }
}
