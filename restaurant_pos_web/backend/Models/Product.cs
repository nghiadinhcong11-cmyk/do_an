using System.ComponentModel.DataAnnotations;

namespace RestaurantPos.Api.Models;

public class Product
{
    [Key]
    public string Id { get; set; } = Guid.NewGuid().ToString("N");
    public string RestaurantId { get; set; } = string.Empty;
    public string? CategoryId { get; set; }
    public string? Sku { get; set; }
    public string Name { get; set; } = string.Empty;
    public string? Description { get; set; }
    public decimal Price { get; set; }
    public decimal CostPrice { get; set; }
    public string? Unit { get; set; }
    public string? ImageUrl { get; set; }
    public bool IsAvailable { get; set; } = true;
    public bool IsVisibleToStaff { get; set; } = true;
    public bool IsBestSeller { get; set; } = false;
    public bool IsArchived { get; set; } = false;
    public int DisplayOrder { get; set; } = 0;
    public DateTime CreatedAtUtc { get; set; } = DateTime.UtcNow;
    public DateTime UpdatedAtUtc { get; set; } = DateTime.UtcNow;
}
