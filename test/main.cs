using System;
using System.Net.WebSockets;
using System.Text;
using System.Threading;
using System.Net;
using System.Net.Http;

using (var client = new HttpClient(new HttpClientHandler { AutomaticDecompression = DecompressionMethods.GZip | DecompressionMethods.Deflate }))
{
	client.BaseAddress = new Uri("https://frontdoor-test-123-fdd4f9eddee2cag0.z01.azurefd.net/");
	HttpResponseMessage response = client.GetAsync("/").Result;
	response.EnsureSuccessStatusCode();
	string url = response.Content.ReadAsStringAsync().Result;
	
	using (var ws = new ClientWebSocket())
	{
		await ws.ConnectAsync(new Uri(url), CancellationToken.None);
		var buffer = new byte[1024 * 4];

		await ws.SendAsync(Encoding.ASCII.GetBytes($"{DateTime.Now}"), WebSocketMessageType.Text, true, CancellationToken.None);

		var result = await ws.ReceiveAsync(buffer, CancellationToken.None);
		Console.WriteLine(Encoding.ASCII.GetString(buffer, 0, result.Count));

		await ws.CloseAsync(WebSocketCloseStatus.NormalClosure, null, CancellationToken.None);
	}
}