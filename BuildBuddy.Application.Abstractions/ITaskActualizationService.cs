using BuildBuddy.Contract;

namespace BuildBuddy.Application.Abstractions;

public interface ITaskActualizationService
{
    Task<IEnumerable<TaskActualizationDto>> GetAllTasksActualizationAsync();
    Task<TaskActualizationDto> GetTaskActualizationByIdAsync(int id);
    Task<TaskActualizationDto> CreateTaskActualizationAsync(TaskActualizationDto conversationDto);
    Task UpdateTaskActualizationAsync(int id, TaskActualizationDto conversationDto);
    Task DeleteTaskActualizationAsync(int id);
    Task AddTaskImageAsync(int taskId, Stream imageStream, string imageName);
    Task<IEnumerable<string>> GetTaskImagesAsync(int taskId);
    Task RemoveTaskImageAsync(int taskId, string imageUrl);
}