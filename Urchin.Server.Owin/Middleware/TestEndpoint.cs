using System;
using System.Linq;
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
    public class TestEndpoint : ApiBase, IMiddleware<object>
    {
        private readonly IRuleData _ruleData;
        private readonly PathString _draftVersionPath;
        private readonly PathString _versionPath;

        public TestEndpoint(
            IRuleData ruleData)
        {
            _ruleData = ruleData;
            _draftVersionPath = new PathString("/test");
            _versionPath = new PathString("/test/{version}");
        }

        public override Task Invoke(IOwinContext context, Func<Task> next)
        {
            var request = context.Request;
            if (request.Method != "GET")
                return next.Invoke();

            var draftVersionTest = _draftVersionPath.IsWildcardMatch(request.Path);
            var versionTest = _versionPath.IsWildcardMatch(request.Path);

            if (!(draftVersionTest || versionTest))
                return next.Invoke();

            int? version = null;
            if (versionTest)
            {
                var pathSegmnts = request.Path.Value
                    .Split('/')
                    .Where(p => !string.IsNullOrWhiteSpace(p))
                    .Select(HttpUtility.UrlDecode)
                    .ToArray();

                if (pathSegmnts.Length < 2)
                    throw new HttpException((int)HttpStatusCode.BadRequest, "Path has too few segments. Expecting " + _versionPath.Value);

                var versionText = pathSegmnts[1];
                int versionNumber;
                if (!int.TryParse(versionText, out versionNumber))
                    throw new HttpException((int)HttpStatusCode.BadRequest, "The version must be a whole number " + _versionPath.Value);
                version = versionNumber;
            }

            var datacenter = request.Query["datacenter"];
            var environment = request.Query["environment"];
            var machine = request.Query["machine"];
            var application = request.Query["application"];
            var instance = request.Query["instance"];

            if (string.IsNullOrWhiteSpace(machine))
                throw new HttpException((int)HttpStatusCode.BadRequest, "Machine parameter is required");

            if (string.IsNullOrWhiteSpace(application))
                throw new HttpException((int)HttpStatusCode.BadRequest, "Application parameter is required");

            return TestRules(context, version, datacenter, environment, machine, application, instance);
        }

        private Task TestRules(
            IOwinContext context, 
            int? version, 
            string datacenter,
            string environment, 
            string machine, 
            string application, 
            string instance)
        {
            var clientCredentials = context.Get<IClientCredentials>("ClientCredentials");

            var config = _ruleData.TestConfig(clientCredentials, version, datacenter, environment, machine, application, instance);

            context.Response.ContentType = "application/json";
            return context.Response.WriteAsync(config.ToString(Formatting.Indented));
        }
    }
}