using System.ComponentModel.DataAnnotations;

namespace RestaurantPos.Api.Models;

public class Product
{
    [Key]
    public string Id { get; set; } = Guid.NewGuid().ToString("N");
    public string RestaurantId { get; set; } = string.Empty;
    public string Name { get; set; } = string.Empty;
    public decimal Price { get; set; }
    public decimal CostPrice { get; set; }
    public string? Category { get; set; }
    public string? ImageUrl { get; set; }
    public bool IsVisibleToStaff { get; set; } = true;
    public bool IsAvailable { get; set; } = true;
    public bool IsBestSeller { get; set; } = false;
    public DateTime CreatedAtUtc { get; set; } = DateTime.UtcNow;
}
