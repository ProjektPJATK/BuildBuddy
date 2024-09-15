namespace Backend.Dto;

public class CalendarDto
{
    public string Name { get; set; }
    public string Description { get; set; }
    public TimeSpan Timezone { get; set; }
}