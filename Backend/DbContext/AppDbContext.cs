using Backend.Model;
using Microsoft.EntityFrameworkCore;

namespace Backend.DbContext;

public class AppDbContext : Microsoft.EntityFrameworkCore.DbContext
{
    public AppDbContext(DbContextOptions<AppDbContext> options) : base(options) { }

    public DbSet<User> Users { get; set; }
    public DbSet<Team> Teams { get; set; }
    public DbSet<TeamUser> TeamUsers { get; set; }
    public DbSet<Conversation> Conversations { get; set; }
    public DbSet<UserConversation> UserConversations { get; set; }
    public DbSet<Message> Messages { get; set; }
    public DbSet<Calendar> Calendars { get; set; }
    public DbSet<CalendarTask> CalendarTasks { get; set; }
    public DbSet<Tasks> Tasks { get; set; }
}