using System.ComponentModel.DataAnnotations;

namespace RestaurantPos.Api.Models;

public class RestaurantTable
{
    [Key]
    public string Id { get; set; } = Guid.NewGuid().ToString("N");
    public string RestaurantId { get; set; } = string.Empty;
    public string? BranchId { get; set; }
    public string Name { get; set; } = string.Empty;
    public int Seats { get; set; }
    public int DisplayOrder { get; set; } = 0;
    public string? QrToken { get; set; }
    public string Status { get; set; } = "TRONG";
    public bool IsActive { get; set; } = true;
    public DateTime CreatedAtUtc { get; set; } = DateTime.UtcNow;
    public DateTime UpdatedAtUtc { get; set; } = DateTime.UtcNow;
}
