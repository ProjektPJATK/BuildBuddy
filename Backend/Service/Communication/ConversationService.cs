using Backend.Interface.Communication;

namespace Backend.Service.Communication;

public class ConversationService : IConversationService
{
    public Task AddUserToConversationAsync(int conversationId, int userId)
    {
        throw new NotImplementedException();
    }

    public Task RemoveUserFromConversationAsync(int conversationId, int userId)
    {
        throw new NotImplementedException();
    }
}