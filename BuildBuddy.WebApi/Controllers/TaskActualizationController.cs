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
        
        [HttpPost("{taskId}/add-image")]
        public async Task<IActionResult> AddTaskImage(int taskId, IFormFile image)
        {
            using var stream = image.OpenReadStream();
            await _taskActualizationService.AddTaskImageAsync(taskId, stream, image.FileName);
            return NoContent();
        }
        
        [HttpDelete("{taskId}/delete-image")]
        public async Task<IActionResult> DeleteTaskImage(int taskId, [FromQuery] string imageUrl)
        {
            await _taskActualizationService.RemoveTaskImageAsync(taskId, imageUrl);
            return NoContent();
        }
        
        [HttpGet("{taskId}/images")]
        public async Task<IActionResult> GetTaskImages(int taskId)
        {
            var images = await _taskActualizationService.GetTaskImagesAsync(taskId);
            if (images == null || !images.Any())
            {
                return NotFound("No images found for the given task.");
            }
            return Ok(images);
        }
    }
}
