using BuildBuddy.Application.Abstractions;
using BuildBuddy.Data.Abstractions;
using BuildBuddy.Data.Model;

public class ChatService : IChatService
{
    private readonly IRepositoryCatalog _repositoryCatalog;

    public ChatService(IRepositoryCatalog messageRepository)
    {
        _repositoryCatalog = messageRepository;
    }

    public async Task HandleIncomingMessage(int senderId, int conversationId, string text)
    {
        if (string.IsNullOrWhiteSpace(text))
        {
            throw new ArgumentException("Message cannot be empty");
        }

        var userConversations = await _repositoryCatalog.UserConversations.GetAsync(
            filter:uc => uc.UserId == senderId && uc.ConversationId == conversationId
        );

        if (userConversations.Count == 0)
        {
            throw new UnauthorizedAccessException("User is not part of this conversation");
        }


        var message = new Message
        {
            SenderId = senderId,
            Text = text,
            DateTimeDate = DateTime.UtcNow,
            ConversationId = conversationId
        };

        _repositoryCatalog.Messages.Insert(message);
        await _repositoryCatalog.SaveChangesAsync();
    }

}