using Backend.Dto;

namespace Backend.Interface.Tasks;

public interface ITaskActualizationService
{
    Task<IEnumerable<TaskActualizationDto>> GetAllTasksActualizationAsync();
    Task<TaskActualizationDto> GetTaskActualizationByIdAsync(int id);
    Task<TaskActualizationDto> CreateTaskActualizationAsync(TaskActualizationDto conversationDto);
    Task UpdateTaskActualizationAsync(int id, TaskActualizationDto conversationDto);
    Task DeleteTaskActualizationAsync(int id);
}