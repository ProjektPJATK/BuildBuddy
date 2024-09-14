namespace Backend.Model;

public class CalendarTask
{
    public int CalendarId { get; set; }
    public int TaskId { get; set; }
    public string Role { get; set; }

    public virtual Calendar Calendar { get; set; }
    public virtual Task Task { get; set; }
}