using BuildBuddy.Application.Abstractions;
using BuildBuddy.Application.Services;
using BuildBuddy.Data.Repositories;
using BuildBuddy.Storage.Repository;

namespace BuildBuddy.Application;

public static class ServiceCollectionExtensions
{
    public static IServiceCollection AddBuildBuddyApp(this IServiceCollection services, IConfiguration configuration)
    {
        services.AddScoped<IItemService, ItemService>()
            .AddScoped<IConversationService, ConversationService>()
            .AddScoped<ITaskActualizationService, TaskActualizationService>()
            .AddScoped<ITaskService, TaskService>()
            .AddScoped<IPlaceService, PlaceService>()
            .AddScoped<ITeamService, TeamService>()
            .AddScoped<IUserService, UserService>()
            .AddScoped<IChatService, ChatService>()
            .AddBuildBuddyData(configuration)
            .AddStorageServices(configuration);
        return services;
    }

}