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
        var teamClaims = context.User.Claims
            .Where(c => c.Type.StartsWith("PowerLevel:Team:"))
            .ToList();

        foreach (var claim in teamClaims)
        {
            if (int.TryParse(claim.Value, out int powerLevel) && powerLevel >= requirement.PowerLevel)
            {
                context.Succeed(requirement); 
                return Task.CompletedTask;
            }
        }

        return Task.CompletedTask; 
    }

}
