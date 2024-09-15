using Backend.Dto;
using Backend.Interface.Team;

namespace Backend.Service.Team;

public class TeamService : ITeamService
{
    public Task<IEnumerable<TeamDto>> GetAllTeamsAsync()
    {
        throw new NotImplementedException();
    }

    public Task<TeamDto> GetTeamByIdAsync(int id)
    {
        throw new NotImplementedException();
    }

    public Task<TeamDto> CreateTeamAsync(TeamDto conversationDto)
    {
        throw new NotImplementedException();
    }

    public Task UpdateTeamAsync(int id, TeamDto conversationDto)
    {
        throw new NotImplementedException();
    }

    public Task DeleteTeamAsync(int id)
    {
        throw new NotImplementedException();
    }

    public Task AddUserToTeamAsync(int teamId, int userId)
    {
        throw new NotImplementedException();
    }

    public Task RemoveUserFromTeamAsync(int teamId, int userId)
    {
        throw new NotImplementedException();
    }
}