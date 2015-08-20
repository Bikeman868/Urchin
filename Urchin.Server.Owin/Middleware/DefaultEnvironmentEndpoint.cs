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
    public class DefaultEnvironmentEndpoint: ApiBase
    {
        private readonly IConfigRules _configRules;
        private readonly PathString _path;

        public DefaultEnvironmentEndpoint(
            IConfigRules configRules)
        {
            _configRules = configRules;
            _path = new PathString("/environment/default");
        }

        public Task Invoke(IOwinContext context, Func<Task> next)
        {
            var request = context.Request;
            if (!_path.IsWildcardMatch(request.Path))
                return next.Invoke();

            if (request.Method == "GET")
                return GetDefaultEnvironment(context);

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

            if (request.Method == "PUT")
            {
                try
                {
                    return UpdateDefaultEnvironment(context, requestBody);
                }
                catch (Exception ex)
                {
                    return Json(context,
                        new PostResponseDto
                        {
                            Success = false,
                            ErrorMessage = ex.Message
                        });
                }
            }

            return next.Invoke();
        }

        private Task GetDefaultEnvironment(IOwinContext context)
        {
            var rules = _configRules.GetRules();
            return Json(context, rules.DefaultEnvironmentName);
        }

        private Task UpdateDefaultEnvironment(IOwinContext context, string requestBody)
        {
            if (string.IsNullOrWhiteSpace(requestBody))
                return Json(context, new PostResponseDto { Success = false, ErrorMessage = "The default environment name can not be blank" });

            if (requestBody.Length > 80)
                return Json(context, new PostResponseDto { Success = false, ErrorMessage = "The default environment name is too long" });

            _configRules.SetDefaultEnvironment(requestBody);

            return Json(context, new PostResponseDto { Success = true });
        }
    }
}