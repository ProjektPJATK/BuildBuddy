using Backend.Dto;

namespace Backend.Interface.Communication;

public interface IConversationService
{
    Task AddUserToConversationAsync(int conversationId, int userId);
    Task RemoveUserFromConversationAsync(int conversationId, int userId);
}