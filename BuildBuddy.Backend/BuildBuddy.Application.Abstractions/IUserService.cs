
using BuildBuddy.Contract;

namespace BuildBuddy.Application.Abstractions;

public interface IUserService
{
    Task<UserDto> GetUserByIdAsync(int userId);
    Task<UserDto?> GetUserByEmailAsync(string email);
    Task<IEnumerable<UserDto>> GetAllUsersAsync();
    Task<UserDto> CreateUserAsync(UserDto userDto);
    Task UpdateUserAsync(int userId, UserDto userDto);
    Task DeleteUserAsync(int userId);
    Task<List<TeamDto>> GetTeamsByUserId(int userId);
    Task UpdateUserImageAsync(int userId, Stream imageStream, string imageName);
    Task<IEnumerable<string>> GetUserImageAsync(string imageUrl);
    string GenerateJwtToken(UserDto user);
}