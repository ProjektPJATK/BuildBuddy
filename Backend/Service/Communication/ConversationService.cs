using Backend.DbContext;
using Backend.Interface.Communication;
using Backend.Model;

namespace Backend.Service.Communication;

public class ConversationService : IConversationService
{
    private readonly AppDbContext _context;

    public ConversationService(AppDbContext context)
    {
        _context = context;
    }

    public async Task AddUserToConversationAsync(int conversationId, int userId)
    {
        var conversation = await _context.Conversations.FindAsync(conversationId);
        var user = await _context.Users.FindAsync(userId);

        if (conversation == null || user == null)
        throw new ArgumentException("Invalid conversation or user.");

        conversation.UserConversations.Add(new UserConversation
        {
            ConversationId = conversationId,
            UserId = userId
        });

        await _context.SaveChangesAsync();
    }
    public async Task<int> CreateConversationAsync(int user1Id, int user2Id)
    {
        var user1 = await _context.Users.FindAsync(user1Id);
        var user2 = await _context.Users.FindAsync(user2Id);

        if (user1 == null || user2 == null)
        {
            throw new ArgumentException("One or both users not found.");
        }
        
        var conversation = new Conversation
        {
            Name = $"Conversation_{user1Id}_{user2Id}",
        };
        _context.Conversations.Add(conversation);
        await _context.SaveChangesAsync();

        await AddUserToConversationAsync(conversation.Id, user1Id);
        await AddUserToConversationAsync(conversation.Id, user2Id);

        return conversation.Id;
    }
}