using System;
using System.Net;
using System.Threading.Tasks;
using System.Web;
using Microsoft.Owin;
using Newtonsoft.Json;
using OwinFramework.Interfaces.Builder;
using Urchin.Server.Owin.Extensions;
using Urchin.Server.Shared.Interfaces;

namespace Urchin.Server.Owin.Middleware
{
    public class TraceEndpoint : ApiBase, IMiddleware<object>
    {
        private readonly IRuleData _ruleData;
        private readonly PathString _path;

        public TraceEndpoint(
            IRuleData ruleData)
        {
            _ruleData = ruleData;
            _path = new PathString("/trace");
        }

        public override Task Invoke(IOwinContext context, Func<Task> next)
        {
            var request = context.Request;
            if (request.Method != "GET" || !_path.IsWildcardMatch(request.Path))
                return next.Invoke();

            var datacenter = request.Query["datacenter"];
            var environment = request.Query["environment"];
            var machine = request.Query["machine"];
            var application = request.Query["application"];
            var instance = request.Query["instance"];

            if (string.IsNullOrWhiteSpace(machine))
                throw new HttpException((int)HttpStatusCode.BadRequest, "Machine parameter is required");

            if (string.IsNullOrWhiteSpace(application))
                throw new HttpException((int)HttpStatusCode.BadRequest, "Application parameter is required");

            try
            {
                var clientCredentials = context.Get<IClientCredentials>("ClientCredentials");

                var config = _ruleData.TraceConfig(clientCredentials, datacenter, environment, machine, application, instance);

                context.Response.ContentType = "application/json";
                return context.Response.WriteAsync(config.ToString(Formatting.Indented));
            }
            catch (Exception ex)
            {
                if (ex is HttpException) throw;
                throw new HttpException((int)HttpStatusCode.InternalServerError, ex.Message, ex);
            }
        }
    }
}