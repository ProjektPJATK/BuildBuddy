namespace Backend.Model;

public class TeamUser
{
    public int Id { get; set; }
    public int UserId { get; set; }
    public int TeamId { get; set; }

    public virtual User User { get; set; }
    public virtual Team Team { get; set; }
}