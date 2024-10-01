namespace Backend.Dto;

public class UserDto
{
    public int Id { get; set; }
    public string Name { get; set; }
    public string Surname { get; set; }
    public int TelephoneNr { get; set; }
    public string Password { get; set; }
    public string UserImageUrl { get; set; }
    
    public int TeamId { get; set; }

}