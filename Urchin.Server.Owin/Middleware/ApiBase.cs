using System.Threading.Tasks;
using Microsoft.Owin;
using Newtonsoft.Json;

namespace Urchin.Server.Owin.Middleware
{
    public class ApiBase
    {
        protected Task Json<T>(IOwinContext context, T data)
        {
            context.Response.ContentType = "application/json";
            return context.Response.WriteAsync(JsonConvert.SerializeObject(data));
        }
    }
}
