using System;
using System.Collections.Generic;
using System.IO;
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
    public class DatacenterRulesEndpoint : ApiBase, IMiddleware<object>
    {
        private readonly IRuleData _ruleData;
        private readonly PathString _path;

        public DatacenterRulesEndpoint(
            IRuleData ruleData)
        {
            _ruleData = ruleData;
            _path = new PathString("/datacenterrules");
        }

        public override Task Invoke(IOwinContext context, Func<Task> next)
        {
            var request = context.Request;
            if (!_path.IsWildcardMatch(request.Path))
                return next.Invoke();

            if (request.Method == "GET")
            {
                try
                {
                    return GetDatacenterRules(context);
                }
                catch (Exception ex)
                {
                    if (ex is HttpException) throw;
                    throw new HttpException((int) HttpStatusCode.InternalServerError,
                        "Exception getting list of datacenter rules. " + ex.Message, ex);
                }
            }

            List<DatacenterRuleDto> datacenterRules;
            try
            {
                using (var sr = new StreamReader(request.Body, Encoding.UTF8))
                    datacenterRules = JsonConvert.DeserializeObject<List<DatacenterRuleDto>>(sr.ReadToEnd());
            }
            catch (Exception ex)
            {
                return Json(context, new PostResponseDto { Success = false, ErrorMessage = "Failed to deserialize request body to a list of datacenter rules. " + ex.Message });
            }

            if (request.Method == "PUT")
            {
                try
                {
                    return UpdateDatacenterRules(context, datacenterRules);
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

        private Task GetDatacenterRules(IOwinContext context)
        {
            var clientCredentials = context.Get<IClientCredentials>("ClientCredentials");
            var datacenters = _ruleData.GetDatacenterRules(clientCredentials);
            return Json(context, datacenters);
        }

        private Task UpdateDatacenterRules(IOwinContext context, List<DatacenterRuleDto> datacenterRules)
        {
            var clientCredentials = context.Get<IClientCredentials>("ClientCredentials");
            _ruleData.SetDatacenterRules(clientCredentials, datacenterRules);
            return Json(context, new PostResponseDto { Success = true });
        }
    }
}