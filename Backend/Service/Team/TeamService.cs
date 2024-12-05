using Backend.DbContext;
using Backend.Dto;
using Backend.Interface.Team;
using Backend.Model;
using Microsoft.EntityFrameworkCore;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace Backend.Service.Team
{
    public class TeamService : ITeamService
    {
        private readonly AppDbContext _dbContext;

        public TeamService(AppDbContext dbContext)
        {
            _dbContext = dbContext;
        }

        public async Task<IEnumerable<TeamDto>> GetAllTeamsAsync()
        {
            return await _dbContext.Teams
                .Select(team => new TeamDto
                {
                    Id = team.Id,
                    Name = team.Name,
                    PlaceId = team.PlaceId
                })
                .ToListAsync();
        }

        public async Task<TeamDto> GetTeamByIdAsync(int id)
        {
            var team = await _dbContext.Teams
                .FirstOrDefaultAsync(t => t.Id == id);

            if (team == null)
            {
                return null;
            }

            return new TeamDto
            {
                Id = team.Id,
                Name = team.Name,
                PlaceId = team.PlaceId
            };
        }

        public async Task<TeamDto> CreateTeamAsync(TeamDto teamDto)
        {
            var team = new Model.Team
            {
                Name = teamDto.Name,
                PlaceId = teamDto.PlaceId
            };

            _dbContext.Teams.Add(team);
            await _dbContext.SaveChangesAsync();

            teamDto.Id = team.Id;
            return teamDto;
        }

        public async Task UpdateTeamAsync(int id, TeamDto teamDto)
        {
            var team = await _dbContext.Teams.FirstOrDefaultAsync(t => t.Id == id);

            if (team != null)
            {
                team.Name = teamDto.Name;
                team.PlaceId = teamDto.PlaceId;

                await _dbContext.SaveChangesAsync();
            }
        }

        public async Task DeleteTeamAsync(int id)
        {
            var team = await _dbContext.Teams.FirstOrDefaultAsync(t => t.Id == id);
            if (team != null)
            {
                _dbContext.Teams.Remove(team);
                await _dbContext.SaveChangesAsync();
            }
        }

        public async Task AddUserToTeamAsync(int teamId, int userId)
        {
            var team = await _dbContext.Teams
                .Include(t => t.TeamUsers)
                .FirstOrDefaultAsync(t => t.Id == teamId);

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
            var team = await _dbContext.Teams
                .Include(t => t.TeamUsers)
                .FirstOrDefaultAsync(t => t.Id == teamId);

            var teamUser = team?.TeamUsers.FirstOrDefault(tu => tu.UserId == userId);
            if (teamUser != null)
            {
                team.TeamUsers.Remove(teamUser);
                await _dbContext.SaveChangesAsync();
            }
        }

        public async Task<List<UserDto>> GetUsersByTeamId(int teamId)
        {
            var users = await _dbContext.Users
                .Where(u => u.TeamUsers.Any(tu => tu.TeamId == teamId))
                .Select(u => new UserDto
                {
                    Id = u.Id,
                    Name = u.Name,
                    Surname = u.Surname,
                    Mail = u.Mail
                })
                .ToListAsync();
            return users;
        }
    }
}
