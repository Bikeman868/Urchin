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
    public class RuleEndpoint: ApiBase
    {
        private readonly IConfigRules _configRules;
        private readonly PathString _path;

        public RuleEndpoint(
            IConfigRules configRules)
        {
            _configRules = configRules;
            _path = new PathString("/rule/{name}");
        }

        public Task Invoke(IOwinContext context, Func<Task> next)
        {
            var request = context.Request;
            if (!_path.IsWildcardMatch(request.Path))
                return next.Invoke();

            var pathSegmnts = request.Path.Value
                .Split('/')
                .Where(p => !string.IsNullOrWhiteSpace(p))
                .Select(HttpUtility.UrlDecode)
                .ToArray();

            if (pathSegmnts.Length < 2)
                throw new HttpException((int)HttpStatusCode.BadRequest, "Path has too few segments. Expecting " + _path.Value);

            var ruleName = pathSegmnts[1];
            
            if (request.Method == "GET")
                return GetRule(context, ruleName);

            try
            {
                if (request.Method == "DELETE")
                    return DeleteRule(context, ruleName);

                RuleDto rule;
                try
                {
                    using (var sr = new StreamReader(request.Body, Encoding.UTF8))
                        rule = JsonConvert.DeserializeObject<RuleDto>(sr.ReadToEnd());
                }
                catch (Exception ex)
                {
                    return Json(context, new PostResponseDto { Success = false, ErrorMessage = "Failed to read request body. " + ex.Message });
                }

                if (request.Method == "PUT")
                    return UpdateRule(context, ruleName, rule);

            }
            catch (Exception ex)
            {
                return Json(context, new PostResponseDto { Success = false, ErrorMessage = "Failed to " + request.Method + " rule " + ruleName + ". " + ex.Message });
            }

            return next.Invoke();
        }

        private Task GetRule(IOwinContext context, string name)
        {
            var clientCredentials = context.Get<IClientCredentials>("ClientCredentials");

            var ruleSet = _configRules.GetRuleSet(clientCredentials);
            if (ruleSet == null || ruleSet.RuleVersion == null || ruleSet.RuleVersion.Count == 0)
                throw new HttpException((int)HttpStatusCode.NoContent, "There are no rules defined on the server");

            var matchingRules = ruleSet.RuleVersion.Where(r => string.Compare(r.RuleName, name, StringComparison.InvariantCultureIgnoreCase) == 0).ToList();

            if (matchingRules.Count == 1)
                return Json(context, matchingRules[0]);

            if (matchingRules.Count == 0)
                throw new HttpException((int)HttpStatusCode.NotFound, "There are no rules called " + name);

            throw new HttpException((int)HttpStatusCode.NoContent, "There are multiple rules with the name " + name);
        }

        private Task UpdateRule(IOwinContext context, string name, RuleDto rule)
        {
            var clientCredentials = context.Get<IClientCredentials>("ClientCredentials");
            _configRules.UpdateRule(clientCredentials, name, rule);
            return Json(context, new PostResponseDto { Success = true });
        }

        private Task DeleteRule(IOwinContext context, string name)
        {
            var clientCredentials = context.Get<IClientCredentials>("ClientCredentials");
            _configRules.DeleteRule(clientCredentials, name);
            return Json(context, new PostResponseDto { Success = true });
        }
    }
}