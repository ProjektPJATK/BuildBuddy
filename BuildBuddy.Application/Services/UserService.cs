using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using BuildBuddy.Application.Abstractions;
using BuildBuddy.Contract;
using BuildBuddy.Data.Abstractions;
using BuildBuddy.Data.Model;
using Microsoft.IdentityModel.Tokens;

namespace BuildBuddy.Application.Services
{
    public class UserService : IUserService
    {
        private readonly IConfiguration _configuration;
        private readonly IRepositoryCatalog _dbContext;

        public UserService(IRepositoryCatalog dbContext, IConfiguration configuration)
        {
            _dbContext = dbContext;
            _configuration = configuration;
        }

        public async Task<UserDto> GetUserByIdAsync(int userId)
        {
            var user = await _dbContext.Users
                .GetByID(userId);

            if (user == null)
            {
                return null;
            }

            return new UserDto
            {
                Id = user.Id,
                Name = user.Name,
                Surname = user.Surname,
                Mail = user.Mail,
                TelephoneNr = user.TelephoneNr,
                UserImageUrl = user.UserImageUrl,
                PreferredLanguage = user.PreferredLanguage,
                TeamId = user.TeamId
            };
        }
        public async Task<UserDto?> GetUserByEmailAsync(string email)
        {
            return await _dbContext.Users.GetByFieldAsync(
                filter: u => u.Mail == email,
                mapper: user => new UserDto
                {
                    Id = user.Id,
                    Name = user.Name,
                    Surname = user.Surname,
                    Mail = user.Mail,
                    TelephoneNr = user.TelephoneNr,
                    Password = user.Password,
                    UserImageUrl = user.UserImageUrl,
                    PreferredLanguage = user.PreferredLanguage,
                    TeamId = user.TeamId
                });
        }
        
        public async Task<IEnumerable<UserDto>> GetAllUsersAsync()
        {
            return await _dbContext.Users
                .GetAsync(user => new UserDto
                {
                    Id = user.Id,
                    Name = user.Name,
                    Mail = user.Mail,
                    Surname = user.Surname,
                    Password = user.Password,
                    TelephoneNr = user.TelephoneNr,
                    UserImageUrl = user.UserImageUrl,
                    PreferredLanguage = user.PreferredLanguage,
                    TeamId = user.TeamId
                });
        }

        public async Task<UserDto> CreateUserAsync(UserDto userDto)
        {
            var user = new User
            {
                Name = userDto.Name,
                Surname = userDto.Surname,
                TelephoneNr = userDto.TelephoneNr,
                Mail = userDto.Mail,
                Password = userDto.Password,
                UserImageUrl = userDto.UserImageUrl,
                PreferredLanguage = userDto.PreferredLanguage,
                TeamId = userDto.TeamId
            };

            _dbContext.Users.Insert(user);
            await _dbContext.SaveChangesAsync();

            userDto.Id = user.Id;
            return userDto;
        }

        public async Task UpdateUserAsync(int userId, UserDto userDto)
        {
            var user = await _dbContext.Users.GetByID(userId);

            if (user != null)
            {
                user.Name = userDto.Name;
                user.Surname = userDto.Surname;
                user.TelephoneNr = userDto.TelephoneNr;
                user.Mail = userDto.Mail;
                user.Password = userDto.Password;
                user.UserImageUrl = userDto.UserImageUrl;
                user.PreferredLanguage = userDto.PreferredLanguage;
                user.TeamId = userDto.TeamId;

                await _dbContext.SaveChangesAsync();
            }
        }

        public async Task DeleteUserAsync(int userId)
        {
            var user = await _dbContext.Users.GetByID(userId);
            if (user != null)
            {
                _dbContext.Users.Delete(user);
                await _dbContext.SaveChangesAsync();
            }
        }

        public async Task<IEnumerable<ConversationDto>> GetUserConversationsAsync(int userId)
        {
            return await _dbContext.UserConversations.GetRelatedEntitiesAsync<UserConversation, ConversationDto>(
                uc => uc.UserId == userId,
                uc => new ConversationDto
                {
                    Id = uc.Conversation.Id,
                    Name = uc.Conversation.Name
                }
            );
        }

        public async Task<List<TeamDto>> GetTeamsByUserId(int userId)
        {
            var teams = await _dbContext.Teams.GetRelatedEntitiesAsync<Team, User, TeamDto>(
                filterSource: t => true,
                relationCondition: (t, u) => u.Id == userId && u.TeamId == t.Id,
                mapper: t => new TeamDto
                {
                    Id = t.Id,
                    Name = t.Name,
                    PlaceId = t.PlaceId
                });
            return teams;
        }
        
        public string GenerateJwtToken(UserDto user)
        {
            var tokenHandler = new JwtSecurityTokenHandler();
            var key = Encoding.ASCII.GetBytes(_configuration["Jwt:Key"] ?? string.Empty);
            var tokenDescriptor = new SecurityTokenDescriptor
            {
                Subject = new ClaimsIdentity(new[]
                {
                    new Claim("id", user.Id.ToString()),
                    new Claim("mail", user.Mail)
                }),
                Expires = DateTime.UtcNow.AddHours(2),
                Issuer = _configuration["Jwt:Issuer"],
                Audience = _configuration["Jwt:Issuer"], 
                SigningCredentials = new SigningCredentials(new SymmetricSecurityKey(key), SecurityAlgorithms.HmacSha256Signature)
            };
            var token = tokenHandler.CreateToken(tokenDescriptor);
            return tokenHandler.WriteToken(token);
        }
    }
}
