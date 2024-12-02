using Backend.DbContext;
using Backend.Dto;
using Backend.Interface.Communication;
using Backend.Model;
using Microsoft.EntityFrameworkCore;

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
    
    public async Task<List<ConversationDto>> GetAllConversationsAsync()
    {
        var conversations = await _context.Conversations
            .Include(c => c.UserConversations)
            .ThenInclude(uc => uc.User)
            .ToListAsync();

        return conversations.Select(c => new ConversationDto
        {
            Id = c.Id,
            Name = c.Name,
            TeamId = c.TeamId,
            Users = c.UserConversations.Select(uc => new UserDto
            {
                Id = uc.User.Id,
                Name = uc.User.Name,
                Surname = uc.User.Surname,
                Mail = uc.User.Mail,
                TelephoneNr = uc.User.TelephoneNr,
                UserImageUrl = uc.User.UserImageUrl,
                PreferredLanguage = uc.User.PreferredLanguage,
                TeamId = uc.User.TeamId
            }).ToList()
        }).ToList();
    }

    public async Task<ConversationDto> GetConversationByIdAsync(int conversationId)
    {
        var conversation = await _context.Conversations
            .Include(c => c.UserConversations)
            .ThenInclude(uc => uc.User)
            .FirstOrDefaultAsync(c => c.Id == conversationId);

        if (conversation == null) return null;

        return new ConversationDto
        {
            Id = conversation.Id,
            Name = conversation.Name,
            TeamId = conversation.TeamId,
            Users = conversation.UserConversations.Select(uc => new UserDto
            {
                Id = uc.User.Id,
                Name = uc.User.Name,
                Surname = uc.User.Surname,
                Mail = uc.User.Mail,
                TelephoneNr = uc.User.TelephoneNr,
                UserImageUrl = uc.User.UserImageUrl,
                PreferredLanguage = uc.User.PreferredLanguage,
                TeamId = uc.User.TeamId
            }).ToList()
        };
    }
}