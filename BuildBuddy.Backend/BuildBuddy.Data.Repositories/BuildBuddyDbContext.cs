using System.Globalization;
using BuildBuddy.Data.Model;
using Microsoft.EntityFrameworkCore;

namespace BuildBuddy.Data.Repositories;

public class BuildBuddyDbContext : DbContext
{
    public BuildBuddyDbContext(DbContextOptions<BuildBuddyDbContext> options) : base(options) { }

    public DbSet<User> Users { get; set; }
    public DbSet<Team> Teams { get; set; }
    public DbSet<Conversation> Conversations { get; set; }
    public DbSet<UserConversation> UserConversations { get; set; }
    public DbSet<Message> Messages { get; set; }
    public DbSet<Tasks> Tasks { get; set; }
    public DbSet<TaskActualization> TaskActualizations { get; set; }
    public DbSet<Item> Items { get; set; }
    public DbSet<Place> Places { get; set; }
}