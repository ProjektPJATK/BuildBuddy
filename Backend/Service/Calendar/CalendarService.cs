using Backend.DbContext;
using Backend.Dto;
using Backend.Interface.Calendar;
using Backend.Model;
using Microsoft.EntityFrameworkCore;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace Backend.Service.Calendar
{
    public class CalendarService : ICalendarService
    {
        private readonly AppDbContext _dbContext;

        public CalendarService(AppDbContext dbContext)
        {
            _dbContext = dbContext;
        }

        public async Task<IEnumerable<CalendarDto>> GetAllCalendarsAsync()
        {
            return await _dbContext.Calendars
                .Select(c => new CalendarDto
                {
                    Name = c.Name,
                    Description = c.Description,
                    Timezone = c.Timezone,
                    UserId = c.UserId
                })
                .ToListAsync();
        }

        public async Task<CalendarDto> GetCalendarByIdAsync(int id)
        {
            var calendar = await _dbContext.Calendars
                .FirstOrDefaultAsync(c => c.Id == id);

            if (calendar == null)
            {
                return null;
            }

            return new CalendarDto
            {
                Name = calendar.Name,
                Description = calendar.Description,
                Timezone = calendar.Timezone,
                UserId = calendar.UserId
            };
        }

        public async Task<CalendarDto> CreateCalendarAsync(CalendarDto calendarDto)
        {
            var calendar = new Model.Calendar
            {
                Name = calendarDto.Name,
                Description = calendarDto.Description,
                Timezone = calendarDto.Timezone,
                UserId = calendarDto.UserId
            };

            _dbContext.Calendars.Add(calendar);
            await _dbContext.SaveChangesAsync();

            calendarDto.Id = calendar.Id; 

            return calendarDto;
        }

        public async Task UpdateCalendarAsync(int id, CalendarDto calendarDto)
        {
            var calendar = await _dbContext.Calendars.FirstOrDefaultAsync(c => c.Id == id);

            if (calendar != null)
            {
                calendar.Name = calendarDto.Name;
                calendar.Description = calendarDto.Description;
                calendar.Timezone = calendarDto.Timezone;
                calendar.UserId = calendarDto.UserId;

                await _dbContext.SaveChangesAsync();
            }
        }

        public async Task DeleteCalendarAsync(int id)
        {
            var calendar = await _dbContext.Calendars.FirstOrDefaultAsync(c => c.Id == id);
            if (calendar != null)
            {
                _dbContext.Calendars.Remove(calendar);
                await _dbContext.SaveChangesAsync();
            }
        }

        public async Task AddTaskToCalendarAsync(int calendarId, int taskId)
        {
            var calendar = await _dbContext.Calendars.Include(c => c.CalendarTasks)
                .FirstOrDefaultAsync(c => c.Id == calendarId);

            if (calendar != null && !calendar.CalendarTasks.Any(ct => ct.TaskId == taskId))
            {
                calendar.CalendarTasks.Add(new CalendarTask { CalendarId = calendarId, TaskId = taskId });
                await _dbContext.SaveChangesAsync();
            }
        }

        public async Task RemoveTaskFromCalendarAsync(int calendarId, int taskId)
        {
            var calendarTask = await _dbContext.CalendarTasks
                .FirstOrDefaultAsync(ct => ct.CalendarId == calendarId && ct.TaskId == taskId);

            if (calendarTask != null)
            {
                _dbContext.CalendarTasks.Remove(calendarTask);
                await _dbContext.SaveChangesAsync();
            }
        }
    }
}
