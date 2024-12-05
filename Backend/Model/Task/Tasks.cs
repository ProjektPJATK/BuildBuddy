namespace Backend.Model;

public class Tasks
{
    public int Id { get; set; }
    public string Name { get; set; }
    public string Message { get; set; }
    public DateTime StartTime { get; set; }
    public DateTime EndTime { get; set; }
    public bool AllDay { get; set; }
    public int? PlaceId {get; set;}
    
    public virtual TaskActualization TaskActualization { get; set; }
    public virtual Place Place { get; set; }
}