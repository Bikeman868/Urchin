using System;
using System.Text;
using System.Threading.Tasks;
using Microsoft.Owin;
using Urchin.Server.Owin.Extensions;
using Urchin.Server.Shared.Interfaces;

namespace Urchin.Server.Owin.Middleware
{
    public class HelloEndpoint: ApiBase
    {
        private readonly IPersister _persister;
        private readonly PathString _path;
        
        public HelloEndpoint(IPersister persister)
        {
            _persister = persister;
            _path = new PathString("/hello");
        }

        public Task Invoke(IOwinContext context, Func<Task> next)
        {
            var request = context.Request;
            if (request.Method != "GET" || !_path.IsWildcardMatch(request.Path))
                return next.Invoke();

            var content = new StringBuilder();
            content.Append("Hello from Urchin Server on ");
            content.AppendLine(Environment.MachineName);
            content.AppendLine();

            content.Append(_persister.CheckHealth());

            return PlainText(context, content);
        }
    }
}
