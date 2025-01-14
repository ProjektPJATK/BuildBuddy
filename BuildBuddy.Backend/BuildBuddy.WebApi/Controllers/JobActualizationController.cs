using BuildBuddy.Application.Abstractions;
using BuildBuddy.Contract;
using Microsoft.AspNetCore.Mvc;

namespace BuildBuddy.WebApi.Controllers;

    [Route("api/[controller]")]
    [ApiController]
    public class JobActualizationController : ControllerBase
    {
        private readonly IJobActualizationService _jobActualizationService;

        public JobActualizationController(IJobActualizationService jobActualizationService)
        {
            _jobActualizationService = jobActualizationService;
        }

        [HttpGet]
        public async Task<ActionResult<IEnumerable<JobActualizationDto>>> GetAllTasksActualization()
        {
            var tasksActualization = await _jobActualizationService.GetAllJobsActualizationAsync();
            return Ok(tasksActualization);
        }

     [HttpGet("{id}")]
public async Task<ActionResult<List<JobActualizationDto>>> GetTaskActualizationById(int id)
{
    // Fetch job actualizations using the service
    var taskActualizations = await _jobActualizationService.GetJobActualizationByIdAsync(id);

    // Check if the list is null or empty
    if (taskActualizations == null || !taskActualizations.Any())
    {
        return NotFound(); // Return 404 if no actualizations are found
    }

    // Return the list of actualizations
    return Ok(taskActualizations);
}


        [HttpPost]
        public async Task<ActionResult<JobActualizationDto>> CreateTaskActualization(JobActualizationDto jobActualizationDto)
        {
            var createdTaskActualization = await _jobActualizationService.CreateJobActualizationAsync(jobActualizationDto);
            return CreatedAtAction(nameof(GetTaskActualizationById), new { id = createdTaskActualization.Id }, createdTaskActualization);
        }

        [HttpPut("{id}")]
        public async Task<IActionResult> UpdateTaskActualization(int id, JobActualizationDto jobActualizationDto)
        {
            await _jobActualizationService.UpdateJobActualizationAsync(id, jobActualizationDto);
            return NoContent();
        }

        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteTaskActualization(int id)
        {
            await _jobActualizationService.DeleteJobActualizationAsync(id);
            return NoContent();
        }
        
        [HttpPost("{jobId}/add-image")]
        public async Task<IActionResult> AddTaskImage(int jobId, IFormFile image)
        {
            using var stream = image.OpenReadStream();
            await _jobActualizationService.AddJobImageAsync(jobId, stream, image.FileName);
            return NoContent();
        }
        
        [HttpDelete("{jobId}/delete-image")]
        public async Task<IActionResult> DeleteTaskImage(int jobId, [FromQuery] string imageUrl)
        {
            await _jobActualizationService.RemoveJobImageAsync(jobId, imageUrl);
            return NoContent();
        }
        
        [HttpGet("{jobId}/images")]
        public async Task<IActionResult> GetTaskImages(int jobId)
        {
            var images = await _jobActualizationService.GetJobImagesAsync(jobId);
            if (images == null || !images.Any())
            {
                return NotFound("No images found for the given task.");
            }
            return Ok(images);
        }
        [HttpPost("{id}/toggle-status")]
        public async Task<IActionResult> ToggleJobActualizationStatus(int id)
        {
            await _jobActualizationService.ToggleJobActualizationStatusAsync(id);
            return NoContent();
        }
    }

