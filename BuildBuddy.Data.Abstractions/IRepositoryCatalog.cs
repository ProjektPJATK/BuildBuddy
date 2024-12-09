using BuildBuddy.Data.Model;

namespace BuildBuddy.Data.Abstractions;

public interface IRepositoryCatalog
{
    IRepository<Item, int> Items { get; }
    IRepository<User, int> Users { get; } 
    IRepository<Conversation, int> Conversations { get; } 
    IRepository<Message, int> Messages { get; } 
    IRepository<Place, int> Places { get; } 
    IRepository<TaskActualization, int> TaskActualizations { get; } 
    IRepository<Tasks, int> Tasks { get; } 
    IRepository<Team, int> Teams { get; } 
    IRepository<TeamUser, int> TeamUsers { get; } 
    IRepository<UserConversation, int> UserConversations { get; } 
    void Dispose();
    Task SaveChangesAsync();
}