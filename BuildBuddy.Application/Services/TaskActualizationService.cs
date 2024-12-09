using BuildBuddy.Application.Abstractions;
using BuildBuddy.Contract;
using BuildBuddy.Data.Abstractions;
using BuildBuddy.Data.Model;

namespace BuildBuddy.Application.Services
{
    public class TaskActualizationService : ITaskActualizationService
    {
        private readonly IRepositoryCatalog _dbContext;

        public TaskActualizationService(IRepositoryCatalog dbContext)
        {
            _dbContext = dbContext;
        }

        public async Task<IEnumerable<TaskActualizationDto>> GetAllTasksActualizationAsync()
        {
            return await _dbContext.TaskActualizations
                .GetAsync(ta => new TaskActualizationDto
                {
                    Id = ta.Id,
                    Message = ta.Message,
                    IsDone = ta.IsDone,
                    TaskImageUrl = ta.TaskImageUrl,
                    TaskId = ta.TaskId
                });
        }

        public async Task<TaskActualizationDto> GetTaskActualizationByIdAsync(int id)
        {
            var taskActualization = await _dbContext.TaskActualizations 
                .GetByID(id);

            if (taskActualization == null)
            {
                return null;
            }

            return new TaskActualizationDto
            {
                Id = taskActualization.Id,
                Message = taskActualization.Message,
                IsDone = taskActualization.IsDone,
                TaskImageUrl = taskActualization.TaskImageUrl,
                TaskId = taskActualization.TaskId
            };
        }

        public async Task<TaskActualizationDto> CreateTaskActualizationAsync(TaskActualizationDto taskActualizationDto)
        {
            var taskActualization = new TaskActualization
            {
                Message = taskActualizationDto.Message,
                IsDone = taskActualizationDto.IsDone,
                TaskImageUrl = taskActualizationDto.TaskImageUrl,
                TaskId = taskActualizationDto.TaskId
            };

            _dbContext.TaskActualizations.Insert(taskActualization);
            await _dbContext.SaveChangesAsync();

            taskActualizationDto.Id = taskActualization.Id;
            return taskActualizationDto;
        }

        public async Task UpdateTaskActualizationAsync(int id, TaskActualizationDto taskActualizationDto)
        {
            var taskActualization = await _dbContext.TaskActualizations
                .GetByID(id);

            if (taskActualization != null)
            {
                taskActualization.Message = taskActualizationDto.Message;
                taskActualization.IsDone = taskActualizationDto.IsDone;
                taskActualization.TaskImageUrl = taskActualizationDto.TaskImageUrl;
                taskActualization.TaskId = taskActualizationDto.TaskId;

                await _dbContext.SaveChangesAsync();
            }
        }

        public async Task DeleteTaskActualizationAsync(int id)
        {
            var taskActualization = await _dbContext.TaskActualizations
                .GetByID(id);

            if (taskActualization != null)
            {
                _dbContext.TaskActualizations.Delete(taskActualization);
                await _dbContext.SaveChangesAsync();
            }
        }
    }
}
