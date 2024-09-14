namespace Backend.Model;

public class Team
{
    public int Id { get; set; }
    public string Name { get; set; }
    public int ConversationId { get; set; }    
    public int PlaceId { get; set; }
    
    public Place Place { get; set; }
    public virtual ICollection<TeamUser> TeamUsers { get; set; }
    public virtual Conversation Conversation { get; set; }
}