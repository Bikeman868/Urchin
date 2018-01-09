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
    public class PostRuleEndpoint : ApiBase, IMiddleware<object>
    {
        private readonly IRuleData _ruleData;
        private readonly PathString _path;

        public PostRuleEndpoint(
            IRuleData ruleData)
        {
            _ruleData = ruleData;
            _path = new PathString("/rule/{version}");
        }

        public override Task Invoke(IOwinContext context, Func<Task> next)
        {
            var request = context.Request;
            if (!_path.IsWildcardMatch(request.Path) || request.Method != "POST")
                return next.Invoke();

            try
            {
                var pathSegmnts = request.Path.Value
                    .Split('/')
                    .Where(p => !string.IsNullOrWhiteSpace(p))
                    .Select(HttpUtility.UrlDecode)
                    .ToArray();

                if (pathSegmnts.Length < 2)
                    throw new HttpException((int)HttpStatusCode.BadRequest, "Path has too few segments. Expecting " + _path.Value);

                var versionText = pathSegmnts[1];
                int version;
                if (!int.TryParse(versionText, out version))
                    throw new HttpException((int)HttpStatusCode.BadRequest, "The version must be a whole number " + _path.Value);

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

                return CreateRule(context, version, rule);
            }
            catch (Exception ex)
            {
                return Json(context, new PostResponseDto { Success = false, ErrorMessage = "Failed to POST new rule. " + ex.Message });
            }
        }

        private Task CreateRule(IOwinContext context, int version, RuleDto rule)
        {
            var clientCredentials = context.Get<IClientCredentials>("ClientCredentials");
            _ruleData.AddRules(clientCredentials, version, new List<RuleDto> { rule });
            return Json(context, new PostResponseDto { Success = true });
        }
    }
}