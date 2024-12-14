namespace BuildBuddy.Application.Abstractions;

public interface IChatService
{
    Task HandleIncomingMessage(int senderId, int conversationId, string text);
    
}