using System;
using System.Net;
using System.Text;
using System.Threading.Tasks;
using Microsoft.Owin;

namespace Urchin.Server.Owin.Middleware
{
    public class NotFoundMiddleware : ApiBase
    {
        public Task Invoke(IOwinContext context, Func<Task> next)
        {
            var content = new StringBuilder();
            content.Append("The requested url did not match any endpoints in the Urchin Server REST API.");

            // TODO: return readme.md file - possible conversion to HTML?

            context.Response.StatusCode = (int)HttpStatusCode.NotFound;
            context.Response.ContentType = "text/plain";
            return context.Response.WriteAsync(content.ToString());
        }
    }
}