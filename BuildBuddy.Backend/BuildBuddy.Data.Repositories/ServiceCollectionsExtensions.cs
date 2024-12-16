using BuildBuddy.Data.Abstractions;
using BuildBuddy.Data.Model;
using Microsoft.EntityFrameworkCore;

namespace BuildBuddy.Data.Repositories
{
    public static class ServiceCollectionsExtensions
    {
        public static IServiceCollection AddBuildBuddyData(this IServiceCollection services, IConfiguration configuration) 
        {
            return services.AddDbContext<BuildBuddyDbContext>(options =>
                    options.UseNpgsql(configuration.GetConnectionString("DefaultConnection")))
                .AddScoped<IRepository<User, int>, MainRepository<User, int>>()
                .AddScoped<IRepository<Conversation, int>, MainRepository<Conversation, int>>()
                .AddScoped<IRepository<Item, int>, MainRepository<Item, int>>()
                .AddScoped<IRepository<Message, int>, MainRepository<Message, int>>()
                .AddScoped<IRepository<Place, int>, MainRepository<Place, int>>()
                .AddScoped<IRepository<TaskActualization, int>, MainRepository<TaskActualization, int>>()
                .AddScoped<IRepository<Tasks, int>, MainRepository<Tasks, int>>()
                .AddScoped<IRepository<Team, int>, MainRepository<Team, int>>()
                .AddScoped<IRepository<TeamUser, int>, MainRepository<TeamUser, int>>()
                .AddScoped<IRepository<User, int>, MainRepository<User, int>>()
                .AddScoped<IRepository<UserConversation, int>, MainRepository<UserConversation, int>>()
                .AddScoped<IRepository<UserTask,int>,MainRepository<UserTask,int>>()
                .AddScoped<IRepositoryCatalog, UnitOfWork>();
        }
    }
}