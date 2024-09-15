namespace Backend.Dto;

public class ItemDto
{
    public string Name { get; set; }
    public double QuantityMax { get; set; }
    public string Metrics { get; set; }
    public double QuantityLeft { get; set; }
    public int PlaceId { get; set; }

}