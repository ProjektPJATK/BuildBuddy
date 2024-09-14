namespace Backend.Model;

public class Calendar
{
    public int Id { get; set; }
    public string Name { get; set; }
    public string Description { get; set; }
    public TimeSpan Timezone { get; set; }

    public virtual ICollection<CalendarTask> CalendarTasks { get; set; }
}