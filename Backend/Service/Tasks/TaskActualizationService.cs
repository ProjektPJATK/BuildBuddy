using Backend.DbContext;
using Backend.Dto;
using Backend.Interface.Tasks;
using Backend.Model; // Assuming TaskActualization is part of Backend.Model
using Microsoft.EntityFrameworkCore;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace Backend.Service.Tasks
{
    public class TaskActualizationService : ITaskActualizationService
    {
        private readonly AppDbContext _dbContext;

        public TaskActualizationService(AppDbContext dbContext)
        {
            _dbContext = dbContext;
        }

        public async Task<IEnumerable<TaskActualizationDto>> GetAllTasksActualizationAsync()
        {
            return await _dbContext.TaskActualizations 
                .Select(ta => new TaskActualizationDto
                {
                    Id = ta.Id,
                    ImageId = ta.ImageId,
                    Message = ta.Message,
                    IsDone = ta.IsDone,
                    TaskImageUrl = ta.TaskImageUrl 
                })
                .ToListAsync();
        }

        public async Task<TaskActualizationDto> GetTaskActualizationByIdAsync(int id)
        {
            var taskActualization = await _dbContext.TaskActualizations 
                .FirstOrDefaultAsync(ta => ta.Id == id);

            if (taskActualization == null)
            {
                return null;
            }

            return new TaskActualizationDto
            {
                Id = taskActualization.Id,
                ImageId = taskActualization.ImageId,
                Message = taskActualization.Message,
                IsDone = taskActualization.IsDone,
                TaskImageUrl = taskActualization.TaskImageUrl 
            };
        }

        public async Task<TaskActualizationDto> CreateTaskActualizationAsync(TaskActualizationDto taskActualizationDto)
        {
            var taskActualization = new TaskActualization
            {
                ImageId = taskActualizationDto.ImageId,
                Message = taskActualizationDto.Message,
                IsDone = taskActualizationDto.IsDone,
                TaskImageUrl = taskActualizationDto.TaskImageUrl 
            };

            _dbContext.TaskActualizations.Add(taskActualization);
            await _dbContext.SaveChangesAsync();

            taskActualizationDto.Id = taskActualization.Id;
            return taskActualizationDto;
        }

        public async Task UpdateTaskActualizationAsync(int id, TaskActualizationDto taskActualizationDto)
        {
            var taskActualization = await _dbContext.TaskActualizations
                .FirstOrDefaultAsync(ta => ta.Id == id);

            if (taskActualization != null)
            {
                taskActualization.ImageId = taskActualizationDto.ImageId;
                taskActualization.Message = taskActualizationDto.Message;
                taskActualization.IsDone = taskActualizationDto.IsDone;
                taskActualization.TaskImageUrl = taskActualizationDto.TaskImageUrl;

                await _dbContext.SaveChangesAsync();
            }
        }

        public async Task DeleteTaskActualizationAsync(int id)
        {
            var taskActualization = await _dbContext.TaskActualizations // Assuming TaskActualizations is the correct DbSet
                .FirstOrDefaultAsync(ta => ta.Id == id);

            if (taskActualization != null)
            {
                _dbContext.TaskActualizations.Remove(taskActualization);
                await _dbContext.SaveChangesAsync();
            }
        }
    }
}
