using System.ComponentModel.DataAnnotations;

namespace RestaurantPos.Api.Models;

public class Category
{
    [Key]
    public string Id { get; set; } = Guid.NewGuid().ToString("N");
    public string RestaurantId { get; set; } = string.Empty;
    public string Name { get; set; } = string.Empty;
    public string? Description { get; set; }
    public string? ImageUrl { get; set; }
    public int DisplayOrder { get; set; } = 0;
    public bool IsActive { get; set; } = true;
    public DateTime CreatedAtUtc { get; set; } = DateTime.UtcNow;
    public DateTime UpdatedAtUtc { get; set; } = DateTime.UtcNow;
}
