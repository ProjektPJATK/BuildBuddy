using BuildBuddy.Application.Abstractions;
using BuildBuddy.Application.Services;
using BuildBuddy.Data.Repositories;
using BuildBuddy.Storage.Repository;

namespace BuildBuddy.Application;

public static class ServiceCollectionExtensions
{
    public static IServiceCollection AddBuildBuddyApp(this IServiceCollection services, IConfiguration configuration)
    {
        services.AddScoped<IBuildingArticlesService, BuildingArticlesService>()
            .AddScoped<IConversationService, ConversationService>()
            .AddScoped<IJobActualizationService, JobActualizationService>()
            .AddScoped<IJobService, JobService>()
            .AddScoped<IAddressService, AddressService>()
            .AddScoped<ITeamService, TeamService>()
            .AddScoped<IUserService, UserService>()
            .AddScoped<IChatService, ChatService>()
            .AddBuildBuddyData(configuration)
            .AddStorageServices(configuration);
        return services;
    }

}