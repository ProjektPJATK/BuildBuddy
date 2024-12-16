namespace BuildBuddy.Data.Model;

public class TaskActualization : IHaveId<int>
{
    public int Id { get; set; }
    public int ImageId { get; set; }
    public int Message { get; set; }
    public bool IsDone { get; set; }
    public List<string> TaskImageUrl { get; set; }
    public int? TaskId { get; set; }
    public virtual Tasks Task { get; set; }
}