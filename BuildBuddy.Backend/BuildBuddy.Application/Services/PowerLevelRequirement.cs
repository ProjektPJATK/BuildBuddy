using Microsoft.AspNetCore.Authorization;

namespace BuildBuddy.Application.Services;

public class PowerLevelRequirement : IAuthorizationRequirement
{
    public int PowerLevel { get; }

    public PowerLevelRequirement(int powerLevel)
    {
        PowerLevel = powerLevel;
    }
}

public class PowerLevelHandler : AuthorizationHandler<PowerLevelRequirement>
{
    protected override Task HandleRequirementAsync(AuthorizationHandlerContext context, PowerLevelRequirement requirement)
    {
        var powerLevelClaim = context.User.Claims.FirstOrDefault(c => c.Type == "powerLevel");

        if (powerLevelClaim != null && int.TryParse(powerLevelClaim.Value, out int powerLevel))
        {
            if (powerLevel >= requirement.PowerLevel)
            {
                context.Succeed(requirement);
            }
        }

        return Task.CompletedTask;
    }

}
