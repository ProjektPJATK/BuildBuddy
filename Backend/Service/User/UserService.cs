using Backend.Dto;
using Backend.Interface.User;

namespace Backend.Service.User;

public class UserService : IUserService
{
    public Task<UserDto> GetUserByIdAsync(int userId)
    {
        throw new NotImplementedException();
    }

    public Task<IEnumerable<UserDto>> GetAllUsersAsync()
    {
        throw new NotImplementedException();
    }

    public Task<UserDto> CreateUserAsync(UserDto userDto)
    {
        throw new NotImplementedException();
    }

    public Task UpdateUserAsync(int userId, UserDto userDto)
    {
        throw new NotImplementedException();
    }

    public Task DeleteUserAsync(int userId)
    {
        throw new NotImplementedException();
    }

    public Task<IEnumerable<ConversationDto>> GetUserConversationsAsync(int userId)
    {
        throw new NotImplementedException();
    }

    public Task<IEnumerable<TeamDto>> GetUserTeamsAsync(int userId)
    {
        throw new NotImplementedException();
    }
}