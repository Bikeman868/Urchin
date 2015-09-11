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
    public class TestEndpoint: ApiBase
    {
        private readonly IRuleData _ruleData;
        private readonly PathString _path;

        public TestEndpoint(
            IRuleData ruleData)
        {
            _ruleData = ruleData;
            _path = new PathString("/test");
        }

        public Task Invoke(IOwinContext context, Func<Task> next)
        {
            var request = context.Request;
            if (request.Method != "POST" || !_path.IsWildcardMatch(request.Path))
                return next.Invoke();

            var environment = request.Query["environment"];
            var machine = request.Query["machine"];
            var application = request.Query["application"];
            var instance = request.Query["instance"];

            if (string.IsNullOrWhiteSpace(machine))
                throw new HttpException((int)HttpStatusCode.BadRequest, "Machine parameter is required");

            if (string.IsNullOrWhiteSpace(application))
                throw new HttpException((int)HttpStatusCode.BadRequest, "Application parameter is required");

            RuleSetDto ruleSet;
            try
            {
                using (var sr = new StreamReader(request.Body, Encoding.UTF8))
                    ruleSet = JsonConvert.DeserializeObject<RuleSetDto>(sr.ReadToEnd());

            }
            catch (Exception ex)
            {
                return Json(context, new PostResponseDto { Success = false, ErrorMessage = "Failed to read request body. " + ex.Message });
            }

            try
            {
                return TestRules(context, ruleSet, environment, machine, application, instance);
            }
            catch (Exception ex)
            {
                return Json(context, new PostResponseDto { Success = false, ErrorMessage = "Failed to " + request.Method + " rules. " + ex.Message });
            }
        }

        private Task TestRules(
            IOwinContext context, 
            RuleSetDto ruleSet, 
            string environment, 
            string machine, 
            string application, 
            string instance)
        {
            var config = _ruleData.TestConfig(ruleSet, environment, machine, application, instance);

            context.Response.ContentType = "application/json";
            return context.Response.WriteAsync(config.ToString(Formatting.Indented));
        }
    }
}