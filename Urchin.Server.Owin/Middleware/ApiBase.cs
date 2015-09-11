using System.Text;
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

        protected Task PlainText(IOwinContext context, string text)
        {
            context.Response.ContentType = "text/plain";
            return context.Response.WriteAsync(text);
        }

        protected Task PlainText(IOwinContext context, StringBuilder text)
        {
            context.Response.ContentType = "text/plain";
            return context.Response.WriteAsync(text.ToString());
        }
    }
}
