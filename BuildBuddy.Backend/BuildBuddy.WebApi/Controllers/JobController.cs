
using BuildBuddy.Application.Abstractions;
using BuildBuddy.Contract;
using Microsoft.AspNetCore.Mvc;

namespace BuildBuddy.WebApi.Controllers;

    [Route("api/[controller]")]
    [ApiController]
    public class JobController : ControllerBase
    {
        private readonly IJobService _jobService;

        public JobController(IJobService jobService)
        {
            _jobService = jobService;
        }

        [HttpGet]
        public async Task<ActionResult<IEnumerable<JobDto>>> GetAllTasks()
        {
            var tasks = await _jobService.GetAllJobsAsync();
            return Ok(tasks);
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<JobDto>> GetTaskById(int id)
        {
            var task = await _jobService.GetJobIdAsync(id);
            if (task == null)
            {
                return NotFound();
            }
            return Ok(task);
        }

        [HttpPost]
        public async Task<ActionResult<JobDto>> CreateTask(JobDto jobDto, string message)
        {
            var createdTask = await _jobService.CreateJobAsync(jobDto, message);
            return CreatedAtAction(nameof(GetTaskById), new { id = createdTask.Id }, createdTask);
        }

        [HttpPut("{id}")]
        public async Task<IActionResult> UpdateTask(int id, JobDto jobDto)
        {
            await _jobService.UpdateJobAsync(id, jobDto);
            return NoContent();
        }

        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteTask(int id)
        {
            await _jobService.DeleteJobAsync(id);
            return NoContent();
        }
        [HttpGet("user/{userId}")]
        public async Task<IActionResult> GetTasksByUserId(int userId)
        {
            var tasks = await _jobService.GetJobByUserIdAsync(userId);
            if (tasks == null || !tasks.Any())
                return NotFound("No tasks found for this user.");

            return Ok(tasks);
        }

        [HttpPost("assign")]
        public async Task<IActionResult> AssignTaskToUser(int taskId, int userId)
        {
            if (taskId <= 0 || userId <= 0)
                return BadRequest("Invalid taskId or userId.");

            try
            {
                await _jobService.AssignJobToUserAsync(taskId, userId);
                return Ok("Task successfully assigned to user.");
            }
            catch (Exception ex)
            {
                return BadRequest(ex.Message);
            }
        }
    }
