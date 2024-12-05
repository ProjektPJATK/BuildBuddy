using Microsoft.AspNetCore.Mvc;

namespace Backend.StorageService;

[ApiController]
[Route("api/[controller]")]
public class StorageController : ControllerBase
{
    private readonly IStorageService _s3Service;

    public StorageController(IStorageService s3Service)
    {
        _s3Service = s3Service;
    }

    [HttpPost("upload/{taskId}")]
    public async Task<IActionResult> UploadImage([FromRoute] int taskId, IFormFile? file)
    {
        if (file == null || file.Length == 0)
            return BadRequest("Bad file");

        var fileName = $"task-{taskId}/{Guid.NewGuid()}-{file.FileName}";
        var stream = file.OpenReadStream();
        var imageUrl = await _s3Service.UploadImageAsync(stream, fileName);

        return Ok(new { Url = imageUrl });
    }

    [HttpGet("images/{taskId}")]
    public async Task<IActionResult> GetImages([FromRoute] int taskId)
    {
        var imageUrls = await _s3Service.GetTaskImagesAsync(taskId);
        return Ok(imageUrls);
    }
}