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

            List<EnvironmentDto> environments;
            try
            {
                using (var sr = new StreamReader(request.Body, Encoding.UTF8))
                    environments = JsonConvert.DeserializeObject<List<EnvironmentDto>>(sr.ReadToEnd());
            }
            catch (Exception ex)
            {
                return Json(context, new PostResponseDto { Success = false, ErrorMessage = "Failed to deserialize request body to a list of environments. " + ex.Message });
            }

            if (request.Method == "PUT")
            {
                try
                {
                    return UpdateEnvironments(context, environments);
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

        private Task UpdateEnvironments(IOwinContext context, List<EnvironmentDto> environments)
        {
            _configRules.SetEnvironments(environments);
            return Json(context, new PostResponseDto { Success = true });
        }
    }
}