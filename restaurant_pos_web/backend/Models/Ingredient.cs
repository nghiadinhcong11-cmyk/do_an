using System.ComponentModel.DataAnnotations;

namespace RestaurantPos.Api.Models;

public class Ingredient
{
    [Key]
    public string Id { get; set; } = Guid.NewGuid().ToString("N");
    public string RestaurantId { get; set; } = string.Empty;
    public string Name { get; set; } = string.Empty;
    public string Unit { get; set; } = string.Empty; // kg, g, ml, l, piece
    public decimal StockQuantity { get; set; }
    public decimal MinStockLevel { get; set; } // Alert when stock is below this
    public DateTime LastUpdatedUtc { get; set; } = DateTime.UtcNow;
}
