﻿using Backend.DbContext;
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
                    Message = ta.Message,
                    IsDone = ta.IsDone,
                    TaskImageUrl = ta.TaskImageUrl,
                    TaskId = ta.TaskId
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
                .FirstOrDefaultAsync(ta => ta.Id == id);

            if (taskActualization != null)
            {
                _dbContext.TaskActualizations.Remove(taskActualization);
                await _dbContext.SaveChangesAsync();
            }
        }
    }
}
