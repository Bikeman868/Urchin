using System;
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
    public class RuleEndpoint : ApiBase, IMiddleware<object>
    {
        private readonly IRuleData _ruleData;
        private readonly PathString _path;

        public RuleEndpoint(
            IRuleData ruleData)
        {
            _ruleData = ruleData;
            _path = new PathString("/rule/{version}/{name}");
        }

        public override Task Invoke(IOwinContext context, Func<Task> next)
        {
            var request = context.Request;
            if (!_path.IsWildcardMatch(request.Path))
                return next.Invoke();

            var pathSegmnts = request.Path.Value
                .Split('/')
                .Where(p => !string.IsNullOrWhiteSpace(p))
                .Select(HttpUtility.UrlDecode)
                .ToArray();

            if (pathSegmnts.Length < 3)
                throw new HttpException((int)HttpStatusCode.BadRequest, "Path has too few segments. Expecting " + _path.Value);

            var versionText = pathSegmnts[1];
            int version;
            if (!int.TryParse(versionText, out version))
                throw new HttpException((int)HttpStatusCode.BadRequest, "The version must be a whole number " + _path.Value);

            var ruleName = pathSegmnts[2];

            if (request.Method == "GET")
            {
                try
                {
                    return GetRule(context, version, ruleName);
                }
                catch (Exception ex)
                {
                    if (ex is HttpException) throw;
                    throw new HttpException((int)HttpStatusCode.InternalServerError, 
                        "Exception retrieving rule " + ruleName + ". " + ex.Message, ex);
                }
            }

            try
            {
                if (request.Method == "DELETE")
                    return DeleteRule(context, version, ruleName);

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
                    return UpdateRule(context, version, ruleName, rule);

            }
            catch (Exception ex)
            {
                return Json(context, new PostResponseDto { Success = false, ErrorMessage = "Failed to " + request.Method + " rule " + ruleName + ". " + ex.Message });
            }

            return next.Invoke();
        }

        private Task GetRule(IOwinContext context, int version, string name)
        {
            var clientCredentials = context.Get<IClientCredentials>("ClientCredentials");

            var ruleVersion = _ruleData.GetRuleVersion(clientCredentials, version);
            if (ruleVersion == null)
                throw new HttpException((int)HttpStatusCode.NoContent, "There are no rules defined on the server with this version");

            var matchingRules = ruleVersion.Rules.Where(r => string.Compare(r.RuleName, name, StringComparison.InvariantCultureIgnoreCase) == 0).ToList();

            if (matchingRules.Count == 1)
                return Json(context, matchingRules[0]);

            if (matchingRules.Count == 0)
                throw new HttpException((int)HttpStatusCode.NotFound, "There are no rules called " + name + " in version " + version);

            throw new HttpException((int)HttpStatusCode.NoContent, "There are multiple rules with the name " + name + " in version " + version);
        }

        private Task UpdateRule(IOwinContext context, int version, string name, RuleDto rule)
        {
            var clientCredentials = context.Get<IClientCredentials>("ClientCredentials");
            _ruleData.UpdateRule(clientCredentials, version, name, rule);
            return Json(context, new PostResponseDto { Success = true });
        }

        private Task DeleteRule(IOwinContext context, int version, string name)
        {
            var clientCredentials = context.Get<IClientCredentials>("ClientCredentials");
            _ruleData.DeleteRule(clientCredentials, version, name);
            return Json(context, new PostResponseDto { Success = true });
        }
    }
}