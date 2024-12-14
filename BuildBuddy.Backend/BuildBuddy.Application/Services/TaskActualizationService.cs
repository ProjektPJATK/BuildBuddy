using BuildBuddy.Application.Abstractions;
using BuildBuddy.Contract;
using BuildBuddy.Data.Abstractions;
using BuildBuddy.Data.Model;
using BuildBuddy.Storage.Abstraction;

namespace BuildBuddy.Application.Services
{
    public class TaskActualizationService : ITaskActualizationService
    {
        private readonly IRepositoryCatalog _dbContext;
        private readonly IFileStorageRepository _fileStorage;

        public TaskActualizationService(IRepositoryCatalog dbContext, IFileStorageRepository fileStorage)
        {
            _dbContext = dbContext;
            _fileStorage = fileStorage;
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
        
        public async Task AddTaskImageAsync(int taskId, Stream imageStream, string imageName)
        {
            const string prefix = "task";
            var task = await _dbContext.TaskActualizations.GetByID(taskId);
            if (task == null) throw new Exception("Task not found");

            var imageUrl = await _fileStorage.UploadImageAsync(imageStream, imageName, prefix);
            task.TaskImageUrl.Add(imageUrl);

            _dbContext.TaskActualizations.Update(task);
            await _dbContext.SaveChangesAsync();
        }
        
        public async Task<IEnumerable<string>> GetTaskImagesAsync(int taskId)
        {
            var task = await _dbContext.TaskActualizations.GetByID(taskId);
            if (task == null) throw new Exception("Task not found");

            return task.TaskImageUrl;
        }

        public async Task RemoveTaskImageAsync(int taskId, string imageUrl)
        {
            var task = await _dbContext.TaskActualizations.GetByID(taskId);
            if (task == null) throw new Exception("Task not found");
            
            await _fileStorage.DeleteFileAsync(imageUrl);

            task.TaskImageUrl.Remove(imageUrl);

            _dbContext.TaskActualizations.Update(task);
            await _dbContext.SaveChangesAsync();
        }
    }
}
