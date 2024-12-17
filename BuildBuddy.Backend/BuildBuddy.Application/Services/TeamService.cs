using BuildBuddy.Application.Abstractions;
using BuildBuddy.Contract;
using BuildBuddy.Data.Abstractions;
using BuildBuddy.Data.Model;

namespace BuildBuddy.Application.Services
{
    public class TeamService : ITeamService
    {
        private readonly IRepositoryCatalog _dbContext;

        public TeamService(IRepositoryCatalog dbContext)
        {
            _dbContext = dbContext;
        }

        public async Task<IEnumerable<TeamDto>> GetAllTeamsAsync()
        {
            return await _dbContext.Teams
                .GetAsync(team => new TeamDto
                {
                    Id = team.Id,
                    Name = team.Name,
                    AddressId = team.AdressId
                });
        }

        public async Task<TeamDto> GetTeamByIdAsync(int id)
        {
            var team = await _dbContext.Teams
                .GetByID(id);

            if (team == null)
            {
                return null;
            }

            return new TeamDto
            {
                Id = team.Id,
                Name = team.Name,
                AddressId = team.AdressId
            };
        }

        public async Task<TeamDto> CreateTeamAsync(TeamDto teamDto)
        {
            var team = new BuildBuddy.Data.Model.Team
            {
                Name = teamDto.Name,
                AdressId = teamDto.AddressId
            };

            _dbContext.Teams.Insert(team);
            await _dbContext.SaveChangesAsync();

            teamDto.Id = team.Id;
            return teamDto;
        }

        public async Task UpdateTeamAsync(int id, TeamDto teamDto)
        {
            var team = await _dbContext.Teams.GetByID(id);

            if (team != null)
            {
                team.Name = teamDto.Name;
                team.AdressId = teamDto.AddressId;

                await _dbContext.SaveChangesAsync();
            }
        }

        public async Task DeleteTeamAsync(int id)
        {
            var team = await _dbContext.Teams.GetByID(id);
            if (team != null)
            {
                _dbContext.Teams.Delete(team);
                await _dbContext.SaveChangesAsync();
            }
        }

        public async Task AddUserToTeamAsync(int teamId, int userId)
        {
            var team = (await _dbContext.Teams.GetAsync(
                filter: t => t.Id == teamId,
                includeProperties: "TeamUsers"
            )).FirstOrDefault();

            if (team != null && !team.TeamUsers.Any(tu => tu.UserId == userId))
            {
                team.TeamUsers.Add(new TeamUser
                {
                    TeamId = teamId,
                    UserId = userId
                });

                await _dbContext.SaveChangesAsync();
            }
        }

        public async Task RemoveUserFromTeamAsync(int teamId, int userId)
        {
            var team = (await _dbContext.Teams.GetAsync(
                filter: t => t.Id == teamId,
                includeProperties: "TeamUser"
                )).FirstOrDefault();

            var teamUser = team?.TeamUsers.FirstOrDefault(tu => tu.UserId == userId);
            if (teamUser != null)
            {
                team.TeamUsers.Remove(teamUser);
                await _dbContext.SaveChangesAsync();
            }
        }

        public async Task<List<UserDto>> GetUsersByTeamId(int teamId)
        {
            var users = await _dbContext.TeamUsers.GetAsync(
                filter: tu => tu.TeamId == teamId,
                mapper: tu => new UserDto
                {
                    Id = tu.User.Id,
                    Name = tu.User.Name,
                    Surname = tu.User.Surname,
                    Mail = tu.User.Mail,
                    TelephoneNr = tu.User.TelephoneNr,
                    UserImageUrl = tu.User.UserImageUrl,
                    PreferredLanguage = tu.User.PreferredLanguage
                },
                includeProperties:"User");
            return users;
        }
    }
}
