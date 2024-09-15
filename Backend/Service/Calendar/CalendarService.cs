using Backend.Dto;
using Backend.Interface.Calendar;

namespace Backend.Service.Calendar;

public class CalendarService : ICalendarService
{
    public Task<IEnumerable<CalendarDto>> GetAllCalendarsAsync()
    {
        throw new NotImplementedException();
    }

    public Task<CalendarDto> GetCalendarByIdAsync(int id)
    {
        throw new NotImplementedException();
    }

    public Task<CalendarDto> CreateCalendarAsync(CalendarDto conversationDto)
    {
        throw new NotImplementedException();
    }

    public Task UpdateCalendarAsync(int id, CalendarDto conversationDto)
    {
        throw new NotImplementedException();
    }

    public Task DeleteCalendarAsync(int id)
    {
        throw new NotImplementedException();
    }

    public Task AddTaskToCalendarAsync(int calendarId, int taskId)
    {
        throw new NotImplementedException();
    }

    public Task RemoveTaskFromCalendarAsync(int calendarId, int taskId)
    {
        throw new NotImplementedException();
    }
}