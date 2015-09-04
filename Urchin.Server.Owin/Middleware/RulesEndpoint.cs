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
    public class RulesEndpoint: ApiBase
    {
        private readonly IConfigRules _configRules;
        private readonly PathString _path;

        public RulesEndpoint(
            IConfigRules configRules)
        {
            _configRules = configRules;
            _path = new PathString("/rules");
        }

        public Task Invoke(IOwinContext context, Func<Task> next)
        {
            var request = context.Request;
            if (!_path.IsWildcardMatch(request.Path))
                return next.Invoke();

            if (request.Method == "GET")
                return GetRules(context);

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
                    return CreateRules(context, rules);

                if (request.Method == "PUT")
                    return UpdateRules(context, rules);
            }
            catch (Exception ex)
            {
                return Json(context, new PostResponseDto { Success = false, ErrorMessage = "Failed to " + request.Method + " rules. " + ex.Message });
            }

            return next.Invoke();
        }

        private Task GetRules(IOwinContext context)
        {
            var clientCredentials = new ClientCredentialsDto { IpAddress = context.Request.RemoteIpAddress };

            var ruleSet = _configRules.GetRuleSet(clientCredentials);
            if (ruleSet == null || ruleSet.Rules == null)
                throw new HttpException((int)HttpStatusCode.NoContent, "There are no rules defined on the server");

            return Json(context, ruleSet.Rules);
        }

        private Task CreateRules(IOwinContext context, List<RuleDto> rules)
        {
            var clientCredentials = new ClientCredentialsDto { IpAddress = context.Request.RemoteIpAddress };
            _configRules.AddRules(clientCredentials, rules);
            return Json(context, new PostResponseDto { Success = true });
        }

        private Task UpdateRules(IOwinContext context, List<RuleDto> rules)
        {
            var clientCredentials = new ClientCredentialsDto { IpAddress = context.Request.RemoteIpAddress };

            foreach (var rule in rules)
                _configRules.UpdateRule(clientCredentials, rule.RuleName, rule);

            return Json(context, new PostResponseDto { Success = true });
        }
    }
}