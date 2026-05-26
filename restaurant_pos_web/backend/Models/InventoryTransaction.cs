namespace RestaurantPos.Api.Models;

public class InventoryTransaction
{
    public int Id { get; set; }
    public string IngredientId { get; set; } = string.Empty;
    public string Type { get; set; } = "Import"; // Import, Adjustment, Sales
    public decimal Quantity { get; set; }
    public DateTime DateUtc { get; set; } = DateTime.UtcNow;
    public string? Note { get; set; }
    public string? ReferenceId { get; set; } // Link to OrderId if type is Sales
}
