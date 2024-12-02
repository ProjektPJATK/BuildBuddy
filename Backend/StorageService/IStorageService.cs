namespace Backend.StorageService;

public interface IStorageService
{
    Task<string> UploadImageAsync(Stream fileStream, string fileName);
    Task<List<string>> GetTaskImagesAsync(int taskId);
}