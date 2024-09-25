namespace Backend.Model;

public class User
{
    public int Id { get; set; }
    public string Name { get; set; }
    public string Surname { get; set; }
    public int TelephoneNr { get; set; }
    public string Password { get; set; }
    public string UserImageUrl { get; set; }
    
    public int TeamId { get; set; }

    public virtual ICollection<TeamUser> Team { get; set; }
    public virtual Calendar Calendars { get; set; }
    public virtual ICollection<UserConversation> UserConversations { get; set; }
    public virtual ICollection<Message> Message { get; set; }

}