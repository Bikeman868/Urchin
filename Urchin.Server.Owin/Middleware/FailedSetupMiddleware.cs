using System;
using System.Text;
using System.Threading.Tasks;
using Microsoft.Owin;

namespace Urchin.Server.Owin.Middleware
{
    public class FailedSetupMiddleware : ApiBase
    {
        private readonly Exception _exception;

        public FailedSetupMiddleware(Exception exception)
        {
            _exception = exception;
        }

        public override Task Invoke(IOwinContext context, Func<Task> next)
        {
            var content = new StringBuilder();
            content.Append("The Urchin Server failed to initialize correctly on ");
            content.Append(Environment.MachineName);
            content.Append(".\n");
            content.Append("There is a configuration error in Urchin, or a failure in something that Urchin depends on.\n\n");
            content.Append("Check the error log for more detailed information.\n\n");
            if (_exception != null)
            {
                content.Append("The exception that was caught was ");
                content.Append(_exception.GetType().FullName);
                content.Append("\n");
                content.Append(_exception.Message);
                content.Append("\n");
                if (_exception.StackTrace != null)
                {
                    content.Append(_exception.StackTrace);
                    content.Append("\n");
                }
                var inner = _exception.InnerException;
                while (inner != null)
                {
                    content.Append("The inner exception was ");
                    content.Append(inner.GetType().FullName);
                    content.Append("\n");
                    content.Append(inner.Message);
                    content.Append("\n");
                    inner = inner.InnerException;
                }
            }

            context.Response.ContentType = "text/plain";
            return context.Response.WriteAsync(content.ToString());
        }
    }
}