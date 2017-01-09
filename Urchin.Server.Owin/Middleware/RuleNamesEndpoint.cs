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
using Urchin.Server.Shared.Rules;

namespace Urchin.Server.Owin.Middleware
{
    public class RuleNamesEndpoint : ApiBase, IMiddleware<object>
    {
        private readonly IRuleData _ruleData;
        private readonly PathString _draftRuleNamesPath;
        private readonly PathString _versionRuleNamesPath;

        public RuleNamesEndpoint(
            IRuleData ruleData)
        {
            _ruleData = ruleData;
            _draftRuleNamesPath = new PathString("/rulenames");
            _versionRuleNamesPath = new PathString("/rulenames/{version}");
        }

        public override Task Invoke(IOwinContext context, Func<Task> next)
        {
            var request = context.Request;

            if (request.Method != "GET")
                return next.Invoke();
                
            if (_draftRuleNamesPath.IsWildcardMatch(request.Path))
                return GetDraftRuleNames(context);

            if (!_versionRuleNamesPath.IsWildcardMatch(request.Path))
                return next.Invoke();

            var pathSegmnts = request.Path.Value
                .Split('/')
                .Where(p => !string.IsNullOrWhiteSpace(p))
                .Select(HttpUtility.UrlDecode)
                .ToArray();

            if (pathSegmnts.Length < 2)
                throw new HttpException((int)HttpStatusCode.BadRequest, "Path has too few segments. Expecting " + _versionRuleNamesPath.Value);

            var versionText = pathSegmnts[1];
            int version;
            if (!int.TryParse(versionText, out version))
                throw new HttpException((int)HttpStatusCode.BadRequest, "The version must be a whole number " + _versionRuleNamesPath.Value);
                
            if (request.Method == "GET")
                return GetRuleNames(context, version);

            return next.Invoke();
        }

        private Task GetRuleNames(IOwinContext context, int version)
        {
            var ruleVersion = _ruleData.GetRuleVersion(null, version);
            if (ruleVersion == null)
                throw new HttpException((int)HttpStatusCode.NoContent, "There are no rules with that version number");

            var ruleNames = ruleVersion.Rules.Select(r => r.RuleName);
            return Json(context, ruleNames);
        }

        private Task GetDraftRuleNames(IOwinContext context)
        {
            var ruleVersion = _ruleData.GetRuleVersion(null);
            if (ruleVersion == null)
                throw new HttpException((int)HttpStatusCode.NoContent, "There are no rules defined on the server");

            var ruleNames = ruleVersion.Rules.Select(r => r.RuleName);
            return Json(context, ruleNames);
        }
    }
}