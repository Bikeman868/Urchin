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

namespace Urchin.Server.Owin.Middleware
{
    public class TraceEndpoint: ApiBase
    {
        private readonly IConfigRules _configRules;
        private readonly PathString _path;

        public TraceEndpoint(
            IConfigRules configRules)
        {
            _configRules = configRules;
            _path = new PathString("/trace");
        }

        public Task Invoke(IOwinContext context, Func<Task> next)
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

            var clientCredentials = new ClientCredentialsDto { IpAddress = context.Request.RemoteIpAddress };

            var config = _configRules.TraceConfig(clientCredentials, environment, machine, application, instance);

            context.Response.ContentType = "application/json";
            return context.Response.WriteAsync(config.ToString(Formatting.Indented));
        }
    }
}