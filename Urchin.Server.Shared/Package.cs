using System.Collections.Generic;
using Ioc.Modules;
using Urchin.Server.Shared.Interfaces;
using Urchin.Server.Shared.Rules;
using Urchin.Server.Shared.TypeMappings;

namespace Urchin.Server.Shared
{
    [Package]
    public class Package : IPackage
    {
        public string Name { get { return "Urchin shared"; } }
        public IList<IocRegistration> IocRegistrations { get; private set; }

        public Package()
        {
            IocRegistrations = new List<IocRegistration>
            {
                // This package registers default implementations for Urchin interfaces.
                // Using the PackageLocator in Ioc.Modules you can decide if these mappings
                // should be used, or whether another assemblies implementation will
                // take priority.

                // In general system integrators can deploy assemblies to the bin folder
                // that contain custom implementations of any of these interfaces to alter
                // the behaviour of Urchin.

                new IocRegistration().Init<IRuleData, RuleData>(),
                new IocRegistration().Init<IMapper, Mapper>(),
                new IocRegistration().Init<IPersister, FilePersister>(),
                new IocRegistration().Init<IEncryptor, Encryptor>(),
            };
        }
    }
}
