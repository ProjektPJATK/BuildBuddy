using Backend.Dto;

namespace Backend.Interface.Calendar;

public interface ICalendarService
{
    Task<IEnumerable<CalendarDto>> GetAllCalendarsAsync();
    Task<CalendarDto> GetCalendarByIdAsync(int id);
    Task<CalendarDto> CreateCalendarAsync(CalendarDto conversationDto);
    Task UpdateCalendarAsync(int id, CalendarDto conversationDto);
    Task DeleteCalendarAsync(int id);
    
    Task AddTaskToCalendarAsync(int calendarId, int taskId);
    Task RemoveTaskFromCalendarAsync(int calendarId, int taskId);
    Task<IEnumerable<CalendarDto>> GetCalendarByUserIdAsync(int userId);
}