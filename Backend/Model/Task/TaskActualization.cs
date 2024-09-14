namespace Backend.Model;

public class TaskActualization
{
    public int Id { get; set; }
    public int ImageId { get; set; }
    public int Message { get; set; }
    public bool IsDone { get; set; }

    public virtual ICollection<UserImage> Image { get; set; }
    public virtual Task Task { get; set; }
}