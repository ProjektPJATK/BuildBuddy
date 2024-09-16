namespace Backend.Dto;

public class TaskDto
{
    public string Name { get; set; }
    public string Message { get; set; }
    public DateTime StartTime { get; set; }
    public DateTime EndTime { get; set; }
    public bool AllDay { get; set; }
    public int PlaceId {get; set;}
    
}