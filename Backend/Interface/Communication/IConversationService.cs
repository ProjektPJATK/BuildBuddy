using Backend.Dto;
using Backend.Model;

namespace Backend.Interface.Communication;

public interface IConversationService
{
    Task AddUserToConversationAsync(int conversationId, int userId);
    Task<int> CreateConversationAsync(int user1Id, int user2Id);
    Task<List<ConversationDto>> GetAllConversationsAsync();
    Task<ConversationDto> GetConversationByIdAsync(int conversationId);

}