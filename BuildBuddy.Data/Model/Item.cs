namespace BuildBuddy.Data.Model;

public class Item : IHaveId<int>
{
    public int Id { get; set; }
    public string Name { get; set; }
    public double QuantityMax { get; set; }
    public string Metrics { get; set; }
    public double QuantityLeft { get; set; }
    public int? PlaceId { get; set; }

    public virtual Place? Place { get; set; }
}