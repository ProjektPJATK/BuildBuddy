using BuildBuddy.Contract;

namespace BuildBuddy.Application.Abstractions;

public interface ITaskService
{
    Task<IEnumerable<TaskDto>> GetAllTasksAsync();
    Task<TaskDto> GetTaskIdAsync(int id);
    Task<TaskDto> CreateTaskAsync(TaskDto conversationDto);
    Task UpdateTaskAsync(int id, TaskDto conversationDto);
    Task DeleteTaskAsync(int id);
    Task<IEnumerable<TaskDto>> GetTaskByUserIdAsync(int userId);
    Task AssignTaskToUserAsync(int taskId, int userId);
}