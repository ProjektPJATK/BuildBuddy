namespace Backend.Dto;

public class CalendarDto
{
    public int Id { get; set; }
    public string Name { get; set; }
    public string Description { get; set; }
    public TimeSpan Timezone { get; set; }
    public int UserId { get; set; }
}