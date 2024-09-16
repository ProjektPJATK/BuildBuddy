namespace Backend.Dto;

public class UserDto
{
    public string Name { get; set; }
    public string Surname { get; set; }
    public int TelephoneNr { get; set; }
    public string Password { get; set; }
    public int TeamId { get; set; }
    public int ImageId { get; set; }
    public string UserImageUrl { get; set; }
}