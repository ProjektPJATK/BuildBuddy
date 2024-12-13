using Backend.DbContext;
using Backend.Dto;
using Backend.Interface.User;
using Microsoft.EntityFrameworkCore;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using Microsoft.IdentityModel.Tokens;

namespace Backend.Service.User
{
    public class UserService : IUserService
    {
        private readonly IConfiguration _configuration;
        private readonly AppDbContext _dbContext;

        public UserService(AppDbContext dbContext, IConfiguration configuration)
        {
            _dbContext = dbContext;
            _configuration = configuration;
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
                Mail = user.Mail,
                TelephoneNr = user.TelephoneNr,
                UserImageUrl = user.UserImageUrl,
                PreferredLanguage = user.PreferredLanguage,
                TeamId = user.TeamId
            };
        }
        public async Task<UserDto> GetUserByEmailAsync(string email)
        {
            var user = await _dbContext.Users.FirstOrDefaultAsync(u => u.Mail == email);
            if (user == null) return null;

            return new UserDto
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
            };
        }
        
        public async Task<IEnumerable<UserDto>> GetAllUsersAsync()
        {
            return await _dbContext.Users
                .Select(user => new UserDto
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
                Mail = userDto.Mail,
                Password = userDto.Password,
                UserImageUrl = userDto.UserImageUrl,
                PreferredLanguage = userDto.PreferredLanguage,
                //TeamId = userDto.TeamId
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

        public async Task<List<TeamDto>> GetTeamsByUserId(int userId)
        {
            var teams = await _dbContext.Teams
                .Where(t => _dbContext.Users
                    .Any(u => u.Id == userId && u.TeamId == t.Id))
                .Select(t => new TeamDto
                {
                    Id = t.Id,
                    Name = t.Name,
                    PlaceId = t.PlaceId
                })
                .ToListAsync();
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
