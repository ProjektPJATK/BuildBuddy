using Backend.DbContext;
using Backend.Dto;
using Backend.Interface.User;
using Backend.Model;
using Microsoft.EntityFrameworkCore;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace Backend.Service.User
{
    public class UserService : IUserService
    {
        private readonly AppDbContext _dbContext;

        public UserService(AppDbContext dbContext)
        {
            _dbContext = dbContext;
        }

        public async Task<UserDto> GetUserByIdAsync(int userId)
        {
            var user = await _dbContext.Users
                .FirstOrDefaultAsync(u => u.Id == userId);

            if (user == null)
            {
                return null;
            }

            return new UserDto
            {
                Id = user.Id,
                Name = user.Name,
                Surname = user.Surname,
                TelephoneNr = user.TelephoneNr,
                UserImageUrl = user.UserImageUrl,
                TeamId = user.TeamId
            };
        }

        public async Task<IEnumerable<UserDto>> GetAllUsersAsync()
        {
            return await _dbContext.Users
                .Select(user => new UserDto
                {
                    Id = user.Id,
                    Name = user.Name,
                    Surname = user.Surname,
                    TelephoneNr = user.TelephoneNr,
                    UserImageUrl = user.UserImageUrl,
                    TeamId = user.TeamId
                })
                .ToListAsync();
        }

        public async Task<UserDto> CreateUserAsync(UserDto userDto)
        {
            var user = new Model.User
            {
                Name = userDto.Name,
                Surname = userDto.Surname,
                TelephoneNr = userDto.TelephoneNr,
                Password = userDto.Password,
                UserImageUrl = userDto.UserImageUrl,
                TeamId = userDto.TeamId
            };

            _dbContext.Users.Add(user);
            await _dbContext.SaveChangesAsync();

            userDto.Id = user.Id;
            return userDto;
        }

        public async Task UpdateUserAsync(int userId, UserDto userDto)
        {
            var user = await _dbContext.Users.FirstOrDefaultAsync(u => u.Id == userId);

            if (user != null)
            {
                user.Name = userDto.Name;
                user.Surname = userDto.Surname;
                user.TelephoneNr = userDto.TelephoneNr;
                user.Password = userDto.Password;
                user.UserImageUrl = userDto.UserImageUrl;
                user.TeamId = userDto.TeamId;

                await _dbContext.SaveChangesAsync();
            }
        }

        public async Task DeleteUserAsync(int userId)
        {
            var user = await _dbContext.Users.FirstOrDefaultAsync(u => u.Id == userId);
            if (user != null)
            {
                _dbContext.Users.Remove(user);
                await _dbContext.SaveChangesAsync();
            }
        }

        public async Task<IEnumerable<ConversationDto>> GetUserConversationsAsync(int userId)
        {
            return await _dbContext.UserConversations
                .Where(uc => uc.UserId == userId)
                .Select(uc => new ConversationDto
                {
                    Id = uc.Conversation.Id,
                    Name = uc.Conversation.Name
                })
                .ToListAsync();
        }

        public async Task<IEnumerable<TeamDto>> GetUserTeamsAsync(int userId)
        {
            var user = await _dbContext.Users
                .Include(u => u.TeamUsers)
                .ThenInclude(tu => tu.Team)
                .FirstOrDefaultAsync(u => u.Id == userId);

            if (user == null)
            {
                return null;
            }

            return user.TeamUsers.Select(tu => new TeamDto
            {
                Id = tu.Team.Id,
                Name = tu.Team.Name,
            });
        }
    }
}
