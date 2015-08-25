using System;
using System.Data.SqlClient;
using Common.Logging;
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
            registrar.RegisterSingleton<IErrorReporter, PriusErrorReporter>();

            // Register the Urchin persister provided by this package
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

        public T Create<T>() where T: class
        {
            return _urchinFactory.Create<T>();
        }
    }

    public class PriusErrorReporter: IErrorReporter
    {
        private readonly ILog _log;

        public PriusErrorReporter(ILogManager logManager)
        {
            _log = logManager.GetLogger("Prius");
        }

        public void ReportError(Exception e, SqlCommand cmd, string subject, params object[] otherInfo)
        {
            _log.Error(m => m("Prius error {0} executing SQL command '{1}'. {2}", subject, cmd.CommandText, e.Message));
        }

        public void ReportError(System.Exception e, string subject, params object[] otherInfo)
        {
            _log.Error(m => m("Prius error {0}. {1}", subject, e.Message));
        }

        public void Dispose()
        {
        }
    }
}
