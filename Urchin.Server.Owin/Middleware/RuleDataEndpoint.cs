using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Net;
using System.Text;
using System.Threading.Tasks;
using System.Web;
using Microsoft.Owin;
using Newtonsoft.Json;
using Urchin.Server.Owin.Extensions;
using Urchin.Server.Shared.DataContracts;
using Urchin.Server.Shared.Interfaces;
using Urchin.Server.Shared.Rules;

namespace Urchin.Server.Owin.Middleware
{
    public class RuleDataEndpoint: ApiBase
    {
        private readonly IConfigRules _configRules;
        private readonly PathString _path;

        public RuleDataEndpoint(
            IConfigRules configRules)
        {
            _configRules = configRules;
            _path = new PathString("/ruledata");
        }

        public Task Invoke(IOwinContext context, Func<Task> next)
        {
            var request = context.Request;
            if (!_path.IsWildcardMatch(request.Path))
                return next.Invoke();

            if (request.Method == "GET")
                return GetRules(context);

            return next.Invoke();
        }

        private Task GetRules(IOwinContext context)
        {
            var clientCredentials = context.Get<IClientCredentials>("ClientCredentials");

            var ruleSet = _configRules.GetRuleSet(clientCredentials);
            if (ruleSet == null)
                throw new HttpException((int)HttpStatusCode.NoContent, "There are no rules defined on the server");

            return Json(context, ruleSet);
        }
    }
}