using BuildBuddy.Application.Abstractions;
using Microsoft.AspNetCore.SignalR;

namespace BuildBuddy.WebSocets;

public class ChatHub : Hub
{
    private readonly IChatService _chatService;

    public ChatHub(IChatService chatService)
    {
        _chatService = chatService;
    }

    public async Task SendMessage(int senderId, int conversationId, string text)
    {
        await _chatService.HandleIncomingMessage(senderId, conversationId, text);
        Console.WriteLine($"Message received: SenderId={senderId}, Text={text}, Timestamp={DateTime.UtcNow}");

        await Clients.Group(conversationId.ToString()).SendAsync("ReceiveMessage", senderId, text, DateTime.UtcNow);
    }

    public override async Task OnConnectedAsync()
    {
        Console.WriteLine($"Connection established: {Context.ConnectionId}");
        var conversationId = Context.GetHttpContext()?.Request.Query["conversationId"];
        Console.WriteLine($"Conversation ID: {conversationId}");
        if (!string.IsNullOrEmpty(conversationId))
        {
            await Groups.AddToGroupAsync(Context.ConnectionId, conversationId);
        }
        await base.OnConnectedAsync();
    }
}