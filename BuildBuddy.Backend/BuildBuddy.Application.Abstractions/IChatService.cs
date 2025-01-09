using BuildBuddy.Contract;

namespace BuildBuddy.Application.Abstractions;

public interface IChatService
{
    Task<MessageDto> HandleIncomingMessage(int senderId, int conversationId, string text);
    Task<List<MessageDto>> GetChatHistory(int conversationId, int userId);
    Task<Dictionary<int, string>> PrepareMessageForUsers(int senderId, int conversationId, string text);
    Task MarkMessagesAsRead(int conversationId, int userId);
    Task<int> GetUnreadMessagesCount(int userId);
}