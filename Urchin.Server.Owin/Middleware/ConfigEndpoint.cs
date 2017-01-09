using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Text;
using System.Threading.Tasks;
using System.Web;
using Microsoft.Owin;
using Newtonsoft.Json;
using Urchin.Server.Owin.Extensions;
using Urchin.Server.Shared.Interfaces;
using Urchin.Server.Shared.Rules;
using OwinFramework.Interfaces.Builder;

namespace Urchin.Server.Owin.Middleware
{
    public class ConfigEndpoint : ApiBase, IMiddleware<object>
    {
        private readonly IRuleData _ruleData;
        private readonly PathString _path;

        public ConfigEndpoint(
            IRuleData ruleData)
        {
            _ruleData = ruleData;
            _path = new PathString("/config");
        }

        public override Task Invoke(IOwinContext context, Func<Task> next)
        {
            var request = context.Request;
            if (request.Method != "GET" || !_path.IsWildcardMatch(request.Path))
                return next.Invoke();

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
                var config = _ruleData.GetConfig(clientCredentials, environment, machine, application, instance);

                context.Response.ContentType = "application/json";
                return context.Response.WriteAsync(config.ToString(Formatting.None));
            }
            catch (Exception ex)
            {
                if (ex is HttpException) throw;
                throw new HttpException((int)HttpStatusCode.InternalServerError,
                    "Exception getting application configuration. " + ex.Message, ex);
            }
        }
    }
}