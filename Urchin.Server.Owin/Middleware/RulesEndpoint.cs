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
using OwinFramework.Interfaces.Builder;
using Urchin.Server.Owin.Extensions;
using Urchin.Server.Shared.DataContracts;
using Urchin.Server.Shared.Interfaces;

namespace Urchin.Server.Owin.Middleware
{
    public class RulesEndpoint : ApiBase, IMiddleware<object>
    {
        private readonly IRuleData _ruleData;
        private readonly PathString _draftRulesPath;
        private readonly PathString _versionRulesPath;

        public RulesEndpoint(
            IRuleData ruleData)
        {
            _ruleData = ruleData;
            _draftRulesPath = new PathString("/rules");
            _versionRulesPath = new PathString("/rules/{version}");
        }

        public override Task Invoke(IOwinContext context, Func<Task> next)
        {
            var request = context.Request;

            if (_draftRulesPath.IsWildcardMatch(request.Path) && request.Method == "GET")
                return GetDraftRules(context);

            if (!_versionRulesPath.IsWildcardMatch(request.Path))
                return next.Invoke();

            var pathSegmnts = request.Path.Value
                .Split('/')
                .Where(p => !string.IsNullOrWhiteSpace(p))
                .Select(HttpUtility.UrlDecode)
                .ToArray();

            if (pathSegmnts.Length < 2)
                throw new HttpException((int)HttpStatusCode.BadRequest, "Path has too few segments. Expecting " + _versionRulesPath.Value);

            var versionText = pathSegmnts[1];
            int version;
            if (!int.TryParse(versionText, out version))
                throw new HttpException((int)HttpStatusCode.BadRequest, "The version must be a whole number " + _versionRulesPath.Value);
                
            if (request.Method == "GET")
                return GetRules(context, version);

            List<RuleDto> rules;
            try
            {
                using (var sr = new StreamReader(request.Body, Encoding.UTF8))
                    rules = JsonConvert.DeserializeObject<List<RuleDto>>(sr.ReadToEnd());
            }
            catch (Exception ex)
            {
                return Json(context, new PostResponseDto { Success = false, ErrorMessage = "Failed to deserialize request body to a list of rules. " + ex.Message });
            }

            try
            {
                if (request.Method == "POST")
                    return CreateRules(context, rules, version);

                if (request.Method == "PUT")
                    return UpdateRules(context, rules, version);
            }
            catch (Exception ex)
            {
                return Json(context, new PostResponseDto { Success = false, ErrorMessage = "Failed to " + request.Method + " rules. " + ex.Message });
            }

            return next.Invoke();
        }

        private Task GetRules(IOwinContext context, int version)
        {
            var clientCredentials = context.Get<IClientCredentials>("ClientCredentials");

            var ruleVersion = _ruleData.GetRuleVersion(clientCredentials, version);
            if (ruleVersion == null)
                throw new HttpException((int)HttpStatusCode.NoContent, "There are no rules with that version number");

            return Json(context, ruleVersion);
        }

        private Task GetDraftRules(IOwinContext context)
        {
            var clientCredentials = context.Get<IClientCredentials>("ClientCredentials");

            var ruleVersion = _ruleData.GetRuleVersion(clientCredentials);
            if (ruleVersion == null)
                throw new HttpException((int)HttpStatusCode.NoContent, "There are no rules defined on the server");

            return Json(context, ruleVersion);
        }

        private Task CreateRules(IOwinContext context, List<RuleDto> rules, int version)
        {
            var clientCredentials = context.Get<IClientCredentials>("ClientCredentials");
            _ruleData.AddRules(clientCredentials, version, rules);
            return Json(context, new PostResponseDto { Success = true });
        }

        private Task UpdateRules(IOwinContext context, IEnumerable<RuleDto> rules, int version)
        {
            var clientCredentials = context.Get<IClientCredentials>("ClientCredentials");

            foreach (var rule in rules)
                _ruleData.UpdateRule(clientCredentials, version, rule.RuleName, rule);

            return Json(context, new PostResponseDto { Success = true });
        }
    }
}