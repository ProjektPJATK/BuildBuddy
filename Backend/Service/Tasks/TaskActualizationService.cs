using Backend.Dto;
using Backend.Interface.Tasks;

namespace Backend.Service.Tasks;

public class TaskActualizationService : ITaskActualizationService
{
    public Task<IEnumerable<TaskActualizationDto>> GetAllTasksActualizationAsync()
    {
        throw new NotImplementedException();
    }

    public Task<TaskActualizationDto> GetTaskActualizationByIdAsync(int id)
    {
        throw new NotImplementedException();
    }

    public Task<TaskActualizationDto> CreateTaskActualizationAsync(TaskActualizationDto conversationDto)
    {
        throw new NotImplementedException();
    }

    public Task UpdateTaskActualizationAsync(int id, TaskActualizationDto conversationDto)
    {
        throw new NotImplementedException();
    }

    public Task DeleteTaskActualizationAsync(int id)
    {
        throw new NotImplementedException();
    }
}