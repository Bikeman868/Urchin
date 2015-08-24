using Urchin.Server.Shared.Interfaces;

namespace Urchin.Server.Persistence.Prius
{
    public class IocConfiguration : IIocConfig
    {
        public int OrderIndex { get { return 100; } }

        public void RegisterDependencies(IIocRegistrar registrar)
        {
            registrar.RegisterSingleton<IPersister, DatabasePersister>();
        }
    }
}
