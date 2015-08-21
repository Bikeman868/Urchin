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
    public class EnvironmentsEndpoint: ApiBase
    {
        private readonly IConfigRules _configRules;
        private readonly PathString _path;

        public EnvironmentsEndpoint(
            IConfigRules configRules)
        {
            _configRules = configRules;
            _path = new PathString("/environments");
        }

        public Task Invoke(IOwinContext context, Func<Task> next)
        {
            var request = context.Request;
            if (!_path.IsWildcardMatch(request.Path))
                return next.Invoke();

            if (request.Method == "GET")
                return GetEnvironments(context);

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
                    return UpdateEnvironments(context, requestBody);
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

        private Task GetEnvironments(IOwinContext context)
        {
            var rules = _configRules.GetRuleSet();
            return Json(context, rules.Environments);
        }

        private Task UpdateEnvironments(IOwinContext context, string requestBody)
        {
            List<EnvironmentDto> environments;
            try
            {
                environments = JsonConvert.DeserializeObject<List<EnvironmentDto>>(requestBody);
            }
            catch (Exception ex)
            {
                return Json(context,
                    new PostResponseDto
                    {
                        Success = false,
                        ErrorMessage = "Failed to deserialize request body to List<EnvironmentDto>. " + ex.Message
                    });
            }

            _configRules.SetEnvironments(environments);

            return Json(context, new PostResponseDto { Success = true });
        }
    }
}