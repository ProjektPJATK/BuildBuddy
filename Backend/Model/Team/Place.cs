namespace Backend.Model;

public class Place
{
    public int Id { get; set; }
    public string Address { get; set; }

    public virtual Team Team { get; set; }
    public virtual ICollection<Item> Items { get; set; }
}