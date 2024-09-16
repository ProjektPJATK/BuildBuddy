﻿using Backend.Dto;

namespace Backend.Interface.User;

public interface IUserService
{
    Task<UserDto> GetUserByIdAsync(int userId);
    Task<IEnumerable<UserDto>> GetAllUsersAsync();
    Task<UserDto> CreateUserAsync(UserDto userDto);
    Task UpdateUserAsync(int userId, UserDto userDto);
    Task DeleteUserAsync(int userId);

    Task<IEnumerable<ConversationDto>> GetUserConversationsAsync(int userId);

    Task<IEnumerable<TeamDto>> GetUserTeamsAsync(int userId);
}