using BuildBuddy.Application.Abstractions;
using Microsoft.AspNetCore.SignalR;

namespace BuildBuddy.WebSocets;

public class ChatHub : Hub
{
    private readonly IChatService _chatService;
    private readonly IConversationService _conversationService;
    private readonly ITranslationService _translationService;

    public ChatHub(IChatService chatService, IConversationService conversationService, ITranslationService translationService)
    {
        _chatService = chatService;
        _conversationService = conversationService;
        _translationService = translationService;
    }

    public async Task SendMessage(int senderId, int conversationId, string text)
    {
        Console.WriteLine($"SendMessage called with senderId={senderId}, conversationId={conversationId}, text={text}");

        var message = await _chatService.HandleIncomingMessage(senderId, conversationId, text);

        var translations = await _chatService.PrepareMessageForUsers(senderId, conversationId, text);

        foreach (var translation in translations)
        {
            await Clients.User(translation.Key.ToString()).SendAsync(
                "ReceiveMessage",
                senderId,
                translation.Value,
                message.DateTimeDate
            );
        }
    }
    public async Task FetchHistory(int conversationId)
    {
        var userId = int.Parse(Context.UserIdentifier);

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