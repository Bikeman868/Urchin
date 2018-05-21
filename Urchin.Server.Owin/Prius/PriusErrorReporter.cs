using System;
using System.Data.SqlClient;
using Prius.Contracts.Interfaces.External;

namespace Urchin.Server.Owin.Prius
{
    internal class PriusErrorReporter : IErrorReporter
    {
        public void ReportError(Exception e, SqlCommand cmd, string subject, params object[] otherInfo)
        {
            Console.WriteLine("Prius exception " + e.Message + " executing " + cmd.CommandText);
        }

        public void ReportError(Exception e, string subject, params object[] otherInfo)
        {
            Console.WriteLine("Prius exception " + e.Message + " whilst " + subject);
        }

        public void Dispose()
        {
        }
    }
}
