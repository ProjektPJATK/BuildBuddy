using Backend.DbContext;
using Backend.Dto;
using Backend.Interface.Tasks;
using Backend.Model;
using Microsoft.EntityFrameworkCore;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace Backend.Service.Tasks
{
    public class TaskService : ITaskService
    {
        private readonly AppDbContext _dbContext;

        public TaskService(AppDbContext dbContext)
        {
            _dbContext = dbContext;
        }

        public async Task<IEnumerable<TaskDto>> GetAllTasksAsync()
        {
            return await _dbContext.Tasks
                .Select(t => new TaskDto
                {
                    Id = t.Id,
                    Name = t.Name,
                    Message = t.Message,
                    StartTime = t.StartTime,
                    EndTime = t.EndTime,
                    AllDay = t.AllDay,
                    PlaceId = t.PlaceId ?? 0
                })
                .ToListAsync();
        }

        public async Task<TaskDto> GetTaskIdAsync(int id)
        {
            var task = await _dbContext.Tasks
                .FirstOrDefaultAsync(t => t.Id == id);

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
            var task = new Model.Tasks
            {
                Name = taskDto.Name,
                Message = taskDto.Message,
                StartTime = taskDto.StartTime,
                EndTime = taskDto.EndTime,
                AllDay = taskDto.AllDay,
                PlaceId = taskDto.PlaceId
            };

            _dbContext.Tasks.Add(task);
            await _dbContext.SaveChangesAsync();

            taskDto.Id = task.Id;
            return taskDto;
        }

        public async Task UpdateTaskAsync(int id, TaskDto taskDto)
        {
            var task = await _dbContext.Tasks.FirstOrDefaultAsync(t => t.Id == id);

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
            var task = await _dbContext.Tasks.FirstOrDefaultAsync(t => t.Id == id);
            if (task != null)
            {
                _dbContext.Tasks.Remove(task);
                await _dbContext.SaveChangesAsync();
            }
        }
    }
}
