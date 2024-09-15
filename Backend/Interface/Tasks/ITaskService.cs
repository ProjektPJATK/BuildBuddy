using Backend.Dto;

namespace Backend.Interface.Tasks;

public interface ITaskService
{
    Task<IEnumerable<TaskDto>> GetAllTasksAsync();
    Task<TaskDto> GetTaskIdAsync(int id);
    Task<TaskDto> CreateTaskAsync(TaskDto conversationDto);
    Task UpdateTaskAsync(int id, TaskDto conversationDto);
    Task DeleteTaskAsync(int id);
}