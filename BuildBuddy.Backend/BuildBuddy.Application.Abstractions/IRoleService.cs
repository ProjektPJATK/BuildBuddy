using BuildBuddy.Contract;

namespace BuildBuddy.Application.Abstractions;

public interface IRoleService
{
    Task<IEnumerable<RoleDto>> GetAllRolesAsync();
    Task<RoleDto> GetRoleByIdAsync(int id);
    Task<RoleDto> CreateRoleAsync(RoleDto roleDto);
    Task UpdateRoleAsync(int id, RoleDto roleDto);
    Task DeleteRoleAsync(int id);
    Task AssignRoleToUserAsync(int userId, int roleId);
    Task RemoveRoleFromUserAsync(int userId);
    Task<List<UserDto>> GetUsersByRoleIdAsync(int roleId);
}