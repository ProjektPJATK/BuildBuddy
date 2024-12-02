using Amazon.Translate;
using Amazon.Translate.Model;
using Backend.DbContext;
using Backend.Interface.User;
using Backend.Model;
using Microsoft.AspNetCore.SignalR;
using Microsoft.EntityFrameworkCore;

namespace Backend.SignaRHub;

public class ChatHub : Hub
{
    private readonly AppDbContext _context;
    private readonly IUserService _userService;
    private readonly IAmazonTranslate _translateClient;

    public ChatHub(AppDbContext context, IUserService userService, IAmazonTranslate translateClient)
    {
        _context = context;
        _userService = userService;
        _translateClient = translateClient;
    }

    public async Task SendMessage(int senderId, int conversationId, string text)
    {
        var conversation = await _context.Conversations
            .Include(c => c.UserConversations)
            .ThenInclude(uc => uc.User)
            .FirstOrDefaultAsync(c => c.Id == conversationId);       
        var sender = await _userService.GetUserByIdAsync(senderId);

        foreach (var userConversation in conversation.UserConversations)
        {
            var recipient = userConversation.User;
            if (recipient.Id != senderId)
            {
                if (recipient.PreferredLanguage != sender.PreferredLanguage)
                {
                    var translateRequest = new TranslateTextRequest
                    {
                        Text = text,
                        SourceLanguageCode = sender.PreferredLanguage,
                        TargetLanguageCode = recipient.PreferredLanguage
                    };

                    var response = await _translateClient.TranslateTextAsync(translateRequest);
                    text = response.TranslatedText;
                }

                await Clients.User(recipient.Id.ToString()).SendAsync("ReceiveMessage", senderId, text);
            }
        }

        var message = new Message
        {
            SenderId = senderId,
            Text = text,
            ConversationId = conversationId,
            DateTimeDate = DateTime.UtcNow
        };

        _context.Messages.Add(message);
        await _context.SaveChangesAsync();    
    }
}