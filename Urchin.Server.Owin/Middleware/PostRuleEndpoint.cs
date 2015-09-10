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
    public class PostRuleEndpoint: ApiBase
    {
        private readonly IConfigRules _configRules;
        private readonly PathString _path;

        public PostRuleEndpoint(
            IConfigRules configRules)
        {
            _configRules = configRules;
            _path = new PathString("/rule/{version}");
        }

        public Task Invoke(IOwinContext context, Func<Task> next)
        {
            var request = context.Request;
            if (!_path.IsWildcardMatch(request.Path) || request.Method != "POST")
                return next.Invoke();

            try
            {
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

                return CreateRule(context, rule);
            }
            catch (Exception ex)
            {
                return Json(context, new PostResponseDto { Success = false, ErrorMessage = "Failed to POST new rule. " + ex.Message });
            }
        }

        private Task CreateRule(IOwinContext context, RuleDto rule)
        {
            var clientCredentials = context.Get<IClientCredentials>("ClientCredentials");
            _configRules.AddRules(clientCredentials, new List<RuleDto> { rule });
            return Json(context, new PostResponseDto { Success = true });
        }
    }
}