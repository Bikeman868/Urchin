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
    public class DatacentersEndpoint : ApiBase, IMiddleware<object>
    {
        private readonly IRuleData _ruleData;
        private readonly PathString _path;

        public DatacentersEndpoint(
            IRuleData ruleData)
        {
            _ruleData = ruleData;
            _path = new PathString("/datacenters");
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
                    return GetDatacenters(context);
                }
                catch (Exception ex)
                {
                    if (ex is HttpException) throw;
                    throw new HttpException((int) HttpStatusCode.InternalServerError,
                        "Exception getting list of datacenters. " + ex.Message, ex);
                }
            }

            List<DatacenterDto> datacenters;
            try
            {
                using (var sr = new StreamReader(request.Body, Encoding.UTF8))
                    datacenters = JsonConvert.DeserializeObject<List<DatacenterDto>>(sr.ReadToEnd());
            }
            catch (Exception ex)
            {
                return Json(context, new PostResponseDto { Success = false, ErrorMessage = "Failed to deserialize request body to a list of datacenters. " + ex.Message });
            }

            if (request.Method == "PUT")
            {
                try
                {
                    return UpdateDatacenters(context, datacenters);
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

        private Task GetDatacenters(IOwinContext context)
        {
            var clientCredentials = context.Get<IClientCredentials>("ClientCredentials");
            var datacenters = _ruleData.GetDatacenters(clientCredentials);
            return Json(context, datacenters);
        }

        private Task UpdateDatacenters(IOwinContext context, List<DatacenterDto> datacenters)
        {
            var clientCredentials = context.Get<IClientCredentials>("ClientCredentials");
            _ruleData.SetDatacenters(clientCredentials, datacenters);
            return Json(context, new PostResponseDto { Success = true });
        }
    }
}