namespace BuildBuddy.Data.Model;

public class UserTask : IHaveId<int>
{
    public int Id { get; set; }
    public int UserId { get; set; }
    public int TasksId { get; set; }

    public virtual User User { get; set; }
    public virtual Tasks Tasks { get; set; }
}