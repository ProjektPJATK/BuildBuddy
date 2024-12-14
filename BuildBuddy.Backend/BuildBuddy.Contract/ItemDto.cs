namespace BuildBuddy.Contract;

public class ItemDto
{
    public int Id { get; set; }
    public string Name { get; set; }
    public double QuantityMax { get; set; }
    public string Metrics { get; set; }
    public double QuantityLeft { get; set; }
    public int? PlaceId { get; set; }

}