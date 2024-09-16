using Backend.Dto;

namespace Backend.Interface.Team;

public interface ITeamService
{
    Task<IEnumerable<TeamDto>> GetAllTeamsAsync();
    Task<TeamDto> GetTeamByIdAsync(int id);
    Task<TeamDto> CreateTeamAsync(TeamDto conversationDto);
    Task UpdateTeamAsync(int id, TeamDto conversationDto);
    Task DeleteTeamAsync(int id);
    Task AddUserToTeamAsync(int teamId, int userId);
    Task RemoveUserFromTeamAsync(int teamId, int userId);
}