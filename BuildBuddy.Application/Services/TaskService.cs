using BuildBuddy.Application.Abstractions;
using BuildBuddy.Contract;
using BuildBuddy.Data.Abstractions;
using BuildBuddy.Data.Model;


namespace BuildBuddy.Application.Services
{
    public class TaskService : ITaskService
    {
        private readonly IRepositoryCatalog _dbContext;

        public TaskService(IRepositoryCatalog dbContext)
        {
            _dbContext = dbContext;
        }

        public async Task<IEnumerable<TaskDto>> GetAllTasksAsync()
        {
            return await _dbContext.Tasks
                .GetAsync(t => new TaskDto
                {
                    Id = t.Id,
                    Name = t.Name,
                    Message = t.Message,
                    StartTime = t.StartTime,
                    EndTime = t.EndTime,
                    AllDay = t.AllDay,
                    PlaceId = t.PlaceId ?? 0
                });
        }

        public async Task<TaskDto> GetTaskIdAsync(int id)
        {
            var task = await _dbContext.Tasks
                .GetByID(id);

            if (task == null)
            {
                return null;
            }

            return new TaskDto
            {
                Id = task.Id,
                Name = task.Name,
                Message = task.Message,
                StartTime = task.StartTime,
                EndTime = task.EndTime,
                AllDay = task.AllDay,
                PlaceId = task.PlaceId ?? 0
            };
        }

        public async Task<TaskDto> CreateTaskAsync(TaskDto taskDto)
        {
            var task = new BuildBuddy.Data.Model.Tasks()
            {
                Name = taskDto.Name,
                Message = taskDto.Message,
                StartTime = taskDto.StartTime,
                EndTime = taskDto.EndTime,
                AllDay = taskDto.AllDay,
                PlaceId = taskDto.PlaceId
            };

            _dbContext.Tasks.Insert(task);
            await _dbContext.SaveChangesAsync();

            taskDto.Id = task.Id;
            return taskDto;
        }

        public async Task UpdateTaskAsync(int id, TaskDto taskDto)
        {
            var task = await _dbContext.Tasks.GetByID(id);

            if (task != null)
            {
                task.Name = taskDto.Name;
                task.Message = taskDto.Message;
                task.StartTime = taskDto.StartTime;
                task.EndTime = taskDto.EndTime;
                task.AllDay = taskDto.AllDay;
                task.PlaceId = taskDto.PlaceId;
                
                await _dbContext.SaveChangesAsync();
            }
        }

        public async Task DeleteTaskAsync(int id)
        {
            var task = await _dbContext.Tasks.GetByID(id);
            if (task != null)
            {
                _dbContext.Tasks.Delete(task);
                await _dbContext.SaveChangesAsync();
            }
        }
    }
}
