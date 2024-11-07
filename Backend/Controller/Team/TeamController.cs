using Backend.Dto;
using Backend.Interface.Team;
using Microsoft.AspNetCore.Mvc;

namespace Backend.Controller.Team
{
    [Route("api/[controller]")]
    [ApiController]
    public class TeamController : ControllerBase
    {
        private readonly ITeamService _teamService;

        public TeamController(ITeamService teamService)
        {
            _teamService = teamService;
        }

        [HttpGet]
        public async Task<ActionResult<IEnumerable<TeamDto>>> GetAllTeams()
        {
            var teams = await _teamService.GetAllTeamsAsync();
            return Ok(teams);
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<TeamDto>> GetTeamById(int id)
        {
            var team = await _teamService.GetTeamByIdAsync(id);
            if (team == null)
            {
                return NotFound();
            }
            return Ok(team);
        }

        [HttpPost]
        public async Task<ActionResult<TeamDto>> CreateTeam(TeamDto teamDto)
        {
            var createdTeam = await _teamService.CreateTeamAsync(teamDto);
            return CreatedAtAction(nameof(GetTeamById), new { id = createdTeam.Id }, createdTeam);
        }

        [HttpPut("{id}")]
        public async Task<IActionResult> UpdateTeam(int id, TeamDto teamDto)
        {
            await _teamService.UpdateTeamAsync(id, teamDto);
            return NoContent();
        }

        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteTeam(int id)
        {
            await _teamService.DeleteTeamAsync(id);
            return NoContent();
        }

        [HttpPost("{teamId}/users/{userId}")]
        public async Task<IActionResult> AddUserToTeam(int teamId, int userId)
        {
            await _teamService.AddUserToTeamAsync(teamId, userId);
            return NoContent();
        }

        [HttpDelete("{teamId}/users/{userId}")]
        public async Task<IActionResult> RemoveUserFromTeam(int teamId, int userId)
        {
            await _teamService.RemoveUserFromTeamAsync(teamId, userId);
            return NoContent();
        }
        
        [HttpGet("{id}/teams")]
        public async Task<ActionResult<IEnumerable<TeamDto>>> GetUserTeams(int id)
        {
            var teams = await _teamService.GetTeamsByUserId(id);

            if (teams == null)
            {
                return NotFound($"User with ID {id} does not exist.");
            }

            if (!teams.Any())
            {
                return NotFound($"User with ID {id} has no teams associated.");
            }

            return Ok(teams);
        }
    }
}
