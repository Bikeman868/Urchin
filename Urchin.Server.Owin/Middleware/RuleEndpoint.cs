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

            var pathSegmnts = request.Path.Value.Split('/').Select(HttpUtility.UrlDecode).ToArray();

            if (pathSegmnts.Length <= 2)
                throw new HttpException((int)HttpStatusCode.BadRequest, "Path has too few segments. Expecting " + _path.Value);

            var ruleName = pathSegmnts[1];
            
            if (request.Method == "GET")
                return GetRule(ruleName);

            string requestBody;
            try
            {
                using (var sr = new StreamReader(request.Body, Encoding.UTF8))
                    requestBody = sr.ReadToEnd();
            }
            catch (Exception ex)
            {
                return Json(context, new PostResponseDto { Success = false, ErrorMessage = "Failed to read request body. " + ex.Message });
            }

            try
            {
                if (request.Method == "PUT")
                    return UpdateRule(ruleName);

                if (request.Method == "POST")
                    return CreateRule(ruleName);

                if (request.Method == "DELETE")
                    return DeleteRule(ruleName);
            }
            catch (Exception ex)
            {
                return Json(context, new PostResponseDto { Success = false, ErrorMessage = "Failed to " + request.Method + " rule " + ruleName + ". " + ex.Message });
            }

            return next.Invoke();
        }

        private Task GetRule(string name)
        {
            throw new HttpException((int)HttpStatusCode.ServiceUnavailable, "Getting a rule is not implemented yet");
        }

        private Task CreateRule(string name)
        {
            throw new HttpException((int)HttpStatusCode.ServiceUnavailable, "Creating a rule is not implemented yet");
        }

        private Task UpdateRule(string name)
        {
            throw new HttpException((int)HttpStatusCode.ServiceUnavailable, "Updating a rule is not implemented yet");
        }

        private Task DeleteRule(string name)
        {
            throw new HttpException((int)HttpStatusCode.ServiceUnavailable, "Deleting a rule is not implemented yet");
        }
    }
}