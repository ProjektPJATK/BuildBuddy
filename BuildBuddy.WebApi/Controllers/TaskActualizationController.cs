using BuildBuddy.Application.Abstractions;
using BuildBuddy.Contract;
using Microsoft.AspNetCore.Mvc;

namespace Backend.Controller.Tasks
{
    [Route("api/[controller]")]
    [ApiController]
    public class TaskActualizationController : ControllerBase
    {
        private readonly ITaskActualizationService _taskActualizationService;

        public TaskActualizationController(ITaskActualizationService taskActualizationService)
        {
            _taskActualizationService = taskActualizationService;
        }

        [HttpGet]
        public async Task<ActionResult<IEnumerable<TaskActualizationDto>>> GetAllTasksActualization()
        {
            var tasksActualization = await _taskActualizationService.GetAllTasksActualizationAsync();
            return Ok(tasksActualization);
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<TaskActualizationDto>> GetTaskActualizationById(int id)
        {
            var taskActualization = await _taskActualizationService.GetTaskActualizationByIdAsync(id);
            if (taskActualization == null)
            {
                return NotFound();
            }
            return Ok(taskActualization);
        }

        [HttpPost]
        public async Task<ActionResult<TaskActualizationDto>> CreateTaskActualization(TaskActualizationDto taskActualizationDto)
        {
            var createdTaskActualization = await _taskActualizationService.CreateTaskActualizationAsync(taskActualizationDto);
            return CreatedAtAction(nameof(GetTaskActualizationById), new { id = createdTaskActualization.Id }, createdTaskActualization);
        }

        [HttpPut("{id}")]
        public async Task<IActionResult> UpdateTaskActualization(int id, TaskActualizationDto taskActualizationDto)
        {
            await _taskActualizationService.UpdateTaskActualizationAsync(id, taskActualizationDto);
            return NoContent();
        }

        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteTaskActualization(int id)
        {
            await _taskActualizationService.DeleteTaskActualizationAsync(id);
            return NoContent();
        }
    }
}
