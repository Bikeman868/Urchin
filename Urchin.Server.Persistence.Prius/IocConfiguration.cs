using System.Data.SqlClient;
using Prius.Contracts.Interfaces;
using Prius.Orm.Commands;
using Prius.Orm.Connections;
using Prius.Orm.Data;
using Urchin.Server.Shared.Interfaces;

namespace Urchin.Server.Persistence.Prius
{
    public class IocConfiguration : IIocConfig
    {
        public int OrderIndex { get { return 100; } }

        public void RegisterDependencies(IIocRegistrar registrar)
        {
            // Register interfaces implemented in Prius
            registrar.RegisterSingleton<ICommandFactory, CommandFactory>();
            registrar.RegisterSingleton<IConnectionFactory, ConnectionFactory>();
            registrar.RegisterSingleton<IContextFactory, ContextFactory>();
            registrar.RegisterSingleton<IDataEnumeratorFactory, DataEnumeratorFactory>();
            registrar.RegisterSingleton<IDataReaderFactory, DataReaderFactory>();
            registrar.RegisterSingleton<IMapper, Mapper>();
            registrar.RegisterSingleton<IParameterFactory, ParameterFactory>();
            registrar.RegisterSingleton<IRepositoryFactory, RepositoryFactory>();
            registrar.RegisterSingleton<IEnumerableDataFactory, EnumerableDataFactory>();

            // Register interfaces needed by Prius
            registrar.RegisterSingleton<IFactory, PriusFactory>();
            registrar.RegisterSingleton<IErrorReporter, ErrorReporter>();

            // Register the Urchin persister
            registrar.RegisterSingleton<IPersister, DatabasePersister>();
        }
    }

    public class PriusFactory : IFactory
    {
        private readonly IIocFactory _urchinFactory;

        public PriusFactory(IIocFactory urchinFactory)
        {
            _urchinFactory = urchinFactory;
        }

        public T Create<T>()
        {
            return _urchinFactory.Create<T>();
        }
    }

    public class ErrorReporter: IErrorReporter
    {
        public void ReportError(System.Exception e, SqlCommand cmd, string subject, params object[] otherInfo)
        {
        }

        public void ReportError(System.Exception e, string subject, params object[] otherInfo)
        {
        }

        public void Dispose()
        {
        }
    }
}
