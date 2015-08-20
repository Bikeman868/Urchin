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
                return GetRules();

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
                if (request.Method == "POST")
                    return CreateRules();
            }
            catch (Exception ex)
            {
                return Json(context, new PostResponseDto { Success = false, ErrorMessage = "Failed to " + request.Method + " rules. " + ex.Message });
            }

            return next.Invoke();
        }

        private Task GetRules()
        {
            throw new HttpException((int)HttpStatusCode.ServiceUnavailable, "Getting a list of rules is not implemented yet");
        }

        private Task CreateRules()
        {
            throw new HttpException((int)HttpStatusCode.ServiceUnavailable, "Creating a list of rules is not implemented yet");
        }
    }
}