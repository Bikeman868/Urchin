using System;
using System.Data.SqlClient;
using Common.Logging;

namespace Urchin.Server.Persistence.Prius
{
    public class PriusFactory : global::Prius.Contracts.Interfaces.External.IFactory
    {
        private readonly Shared.Interfaces.IFactory _urchinFactory;

        public PriusFactory(Shared.Interfaces.IFactory urchinFactory)
        {
            _urchinFactory = urchinFactory;
        }

        public T Create<T>() where T: class
        {
            return _urchinFactory.Create<T>();
        }
    }

    public class PriusErrorReporter : global::Prius.Contracts.Interfaces.External.IErrorReporter
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

        public void ReportError(Exception e, string subject, params object[] otherInfo)
        {
            _log.Error(m => m("Prius error {0}. {1}", subject, e.Message));
        }

        public void Dispose()
        {
        }
    }
}
