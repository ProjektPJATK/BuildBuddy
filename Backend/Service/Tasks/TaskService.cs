using Backend.Dto;
using Backend.Interface.Tasks;

namespace Backend.Service.Tasks;

public class TaskService : ITaskService
{
    public Task<IEnumerable<TaskDto>> GetAllTasksAsync()
    {
        throw new NotImplementedException();
    }

    public Task<TaskDto> GetTaskIdAsync(int id)
    {
        throw new NotImplementedException();
    }

    public Task<TaskDto> CreateTaskAsync(TaskDto conversationDto)
    {
        throw new NotImplementedException();
    }

    public Task UpdateTaskAsync(int id, TaskDto conversationDto)
    {
        throw new NotImplementedException();
    }

    public Task DeleteTaskAsync(int id)
    {
        throw new NotImplementedException();
    }
}