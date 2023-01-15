using System.Net.WebSockets;
using System.Text;

var builder = WebApplication.CreateBuilder(args);
var app = builder.Build();

var webSocketOptions = new WebSocketOptions
{
    KeepAliveInterval = TimeSpan.FromMinutes(2)
};
app.UseWebSockets(webSocketOptions);

app.MapGet("/", (HttpContext context) => String.Concat("wss://", context.Request.Host.ToUriComponent(), context.Request.PathBase.ToUriComponent(), "ws"));

app.Use(async (context, next) =>
{
    if (context.Request.Path == "/ws")
    {
        if (context.WebSockets.IsWebSocketRequest)
        {
            using var webSocket = await context.WebSockets.AcceptWebSocketAsync();
            await webSocket.SendAsync(Encoding.UTF8.GetBytes("Hello World!"), WebSocketMessageType.Text, true, CancellationToken.None);
            await webSocket.CloseAsync(WebSocketCloseStatus.NormalClosure, "Bye", CancellationToken.None);
        }
        else
        {
            context.Response.StatusCode = StatusCodes.Status400BadRequest;
        }
    }
    else
    {
        await next(context);
    }

});

app.Run();
