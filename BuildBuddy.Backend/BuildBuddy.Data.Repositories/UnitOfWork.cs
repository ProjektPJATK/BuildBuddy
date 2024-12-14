using BuildBuddy.Data.Abstractions;
using BuildBuddy.Data.Model;

namespace BuildBuddy.Data.Repositories;

public class UnitOfWork(BuildBuddyDbContext buildBuddyDb, 
    IRepository<User, int> users, 
    IRepository<Conversation, int> conversations, 
    IRepository<Item, int> items, 
    IRepository<Message, int> messages, 
    IRepository<Place, int> places, 
    IRepository<TaskActualization, int> taskActualizations,
    IRepository<Tasks, int> tasks, 
    IRepository<Team, int> teams, 
    IRepository<TeamUser, int> teamUsers, 
    IRepository<UserConversation, int> userConversations) : IDisposable, IRepositoryCatalog
{
    private readonly BuildBuddyDbContext _context = buildBuddyDb;

    public IRepository<Item, int> Items { get; } = items;
    public IRepository<User, int> Users { get; } = users;
    public IRepository<Conversation, int> Conversations { get; } = conversations;
    public IRepository<Message, int> Messages { get; } = messages;
    public IRepository<Place, int> Places { get; } = places;
    public IRepository<TaskActualization, int> TaskActualizations { get; } = taskActualizations;
    public IRepository<Tasks, int> Tasks { get; } = tasks;
    public IRepository<Team, int> Teams { get; } = teams;
    public IRepository<TeamUser, int> TeamUsers { get; } = teamUsers;
    public IRepository<UserConversation, int> UserConversations { get; } = userConversations;

    public Task SaveChangesAsync()
    {
        return _context.SaveChangesAsync();
    }

    private bool disposed = false;

    protected virtual void Dispose(bool disposing)
    {
        if (!disposed)
        {
            if (disposing)
            {
                _context.Dispose();
            }
        }
        disposed = true;
    }

    public void Dispose()
    {
        Dispose(true);
        GC.SuppressFinalize(this);
    }
}