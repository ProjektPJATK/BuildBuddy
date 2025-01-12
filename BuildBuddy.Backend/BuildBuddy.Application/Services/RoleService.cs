using BuildBuddy.Application.Abstractions;
using BuildBuddy.Contract;
using BuildBuddy.Data.Abstractions;
using BuildBuddy.Data.Model;

namespace BuildBuddy.Application.Services;

public class RoleService : IRoleService
{
    private readonly IRepositoryCatalog _dbContext;

    public RoleService(IRepositoryCatalog dbContext)
    {
        _dbContext = dbContext;
    }

    public async Task<IEnumerable<RoleDto>> GetAllRolesAsync()
    {
        return await _dbContext.Roles
            .GetAsync(role => new RoleDto
            {
                Id = role.Id,
                Name = role.Name,
                PowerLevel = role.PowerLevel
            });
    }

    public async Task<RoleDto> GetRoleByIdAsync(int id)
    {
        var role = await _dbContext.Roles.GetByID(id);

        if (role == null)
        {
            return null;
        }

        return new RoleDto
        {
            Id = role.Id,
            Name = role.Name,
            PowerLevel = role.PowerLevel
        };
    }

    public async Task<RoleDto> CreateRoleAsync(RoleDto roleDto)
    {
        var role = new Role
        {
            Name = roleDto.Name,
            PowerLevel = roleDto.PowerLevel
        };

        _dbContext.Roles.Insert(role);
        await _dbContext.SaveChangesAsync();

        roleDto.Id = role.Id;
        return roleDto;
    }

    public async Task UpdateRoleAsync(int id, RoleDto roleDto)
    {
        var role = await _dbContext.Roles.GetByID(id);

        if (role != null)
        {
            role.Name = roleDto.Name;
            role.PowerLevel = roleDto.PowerLevel;

            await _dbContext.SaveChangesAsync();
        }
    }

    public async Task DeleteRoleAsync(int id)
    {
        var role = await _dbContext.Roles.GetByID(id);
        if (role != null)
        {
            _dbContext.Roles.Delete(role);
            await _dbContext.SaveChangesAsync();
        }
    }

    public async Task AssignRoleToUserInTeamAsync(int userId, int roleId, int teamId)
    {
        var teamUserRole = new TeamUserRole
        {
            UserId = userId,
            RoleId = roleId,
            TeamId = teamId
        };

        _dbContext.TeamUserRoles.Insert(teamUserRole);
        await _dbContext.SaveChangesAsync();
    }

    public async Task RemoveRoleFromUserInTeamAsync(int userId, int roleId, int teamId)
    {
        var teamUserRole = await _dbContext.TeamUserRoles.GetAsync(
            filter: tur => tur.UserId == userId && tur.RoleId == roleId && tur.TeamId == teamId
        );

        if (teamUserRole.Any())
        {
            _dbContext.TeamUserRoles.Delete(teamUserRole.First());
            await _dbContext.SaveChangesAsync();
        }
    }

    public async Task<List<UserDto>> GetUsersByRoleIdAsync(int roleId)
    {
        var users = await _dbContext.TeamUserRoles.GetAsync(
            filter: tur => tur.RoleId == roleId,
            mapper: tur => new UserDto
            {
                Id = tur.User.Id,
                Name = tur.User.Name,
                Surname = tur.User.Surname,
                Mail = tur.User.Mail,
                TelephoneNr = tur.User.TelephoneNr,
                UserImageUrl = tur.User.UserImageUrl,
                PreferredLanguage = tur.User.PreferredLanguage
            },
            includeProperties: "User"
        );

        return users.DistinctBy(u => u.Id).ToList();
    }
}

