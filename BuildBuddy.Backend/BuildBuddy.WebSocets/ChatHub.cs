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
    Console.WriteLine($"SendMessage called with senderId={senderId}, conversationId={conversationId}, text={text}");

    var message = await _chatService.HandleIncomingMessage(senderId, conversationId, text);

    var translations = await _chatService.PrepareMessageForUsers(senderId, conversationId, text);

    Console.WriteLine("Translations:");
    foreach (var translation in translations)
    {
        Console.WriteLine($"UserId: {translation.Key}, Message: {translation.Value},senderId: {senderId}");
        if (translation.Key != senderId)
        {
            await Clients.OthersInGroup(conversationId.ToString()).SendAsync(
                "ReceiveMessage",
                senderId,
                translation.Value,
                message.DateTimeDate
            );
        }
    }
    await Clients.Caller.SendAsync(
        "ReceiveMessage",
        senderId,
        text,  
        message.DateTimeDate
    );
}
    public async Task FetchHistory(int conversationId, int userId)
    {
        var messages = await _chatService.GetChatHistory(conversationId, userId);
        await Clients.Caller.SendAsync("ReceiveHistory", messages);
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