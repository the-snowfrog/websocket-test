using System.Net.WebSockets;
using System.Text;

public static class Echo
{
    public static async Task EchoMessage(WebSocket webSocket, string region)
    {
        byte[] buffer = new byte[1024 * 4];
        var result = await webSocket.ReceiveAsync(new ArraySegment<byte>(buffer), CancellationToken.None);
        while (!result.CloseStatus.HasValue)
        {
            byte[] response = new ArraySegment<byte>(buffer, 0, result.Count).Concat(Encoding.ASCII.GetBytes($" - from {region}")).ToArray();
            await webSocket.SendAsync(response, result.MessageType, result.EndOfMessage, CancellationToken.None);
            result = await webSocket.ReceiveAsync(new ArraySegment<byte>(buffer), CancellationToken.None);
        }
        await webSocket.CloseAsync(result.CloseStatus.Value, result.CloseStatusDescription, CancellationToken.None);
    }
}