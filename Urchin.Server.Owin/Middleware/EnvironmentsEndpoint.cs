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
    public class EnvironmentsEndpoint: ApiBase
    {
        private readonly IRuleData _ruleData;
        private readonly PathString _path;

        public EnvironmentsEndpoint(
            IRuleData ruleData)
        {
            _ruleData = ruleData;
            _path = new PathString("/environments");
        }

        public Task Invoke(IOwinContext context, Func<Task> next)
        {
            var request = context.Request;
            if (!_path.IsWildcardMatch(request.Path))
                return next.Invoke();

            if (request.Method == "GET")
            {
                try
                {
                    return GetEnvironments(context);
                }
                catch (Exception ex)
                {
                    if (ex is HttpException) throw;
                    throw new HttpException((int) HttpStatusCode.InternalServerError,
                        "Exception getting list of environments. " + ex.Message, ex);
                }
            }

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
            var clientCredentials = context.Get<IClientCredentials>("ClientCredentials");
            var rules = _ruleData.GetRuleSet(clientCredentials);
            return Json(context, rules.Environments);
        }

        private Task UpdateEnvironments(IOwinContext context, List<EnvironmentDto> environments)
        {
            var clientCredentials = context.Get<IClientCredentials>("ClientCredentials");
            _ruleData.SetEnvironments(clientCredentials, environments);
            return Json(context, new PostResponseDto { Success = true });
        }
    }
}