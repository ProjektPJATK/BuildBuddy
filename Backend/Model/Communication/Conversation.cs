namespace Backend.Model;

public class Conversation
{
    public int Id { get; set; }
    public string Name { get; set; }

    public virtual ICollection<Message> Messages { get; set; }
    public virtual ICollection<UserConversation> UserConversations { get; set; }
}