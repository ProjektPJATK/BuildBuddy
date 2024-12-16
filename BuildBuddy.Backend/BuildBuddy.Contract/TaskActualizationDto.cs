namespace BuildBuddy.Contract;

public class TaskActualizationDto
{
    public int Id { get; set; }
    public int Message { get; set; }
    public bool IsDone { get; set; }
    public List<string> TaskImageUrl { get; set; }
    public int? TaskId { get; set; }
    
}