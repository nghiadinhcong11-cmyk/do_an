using System.ComponentModel.DataAnnotations;

namespace RestaurantPos.Api.Models;

public class Branch
{
    [Key]
    public string Id { get; set; } = Guid.NewGuid().ToString("N");
    public string RestaurantId { get; set; } = string.Empty;
    public string Name { get; set; } = string.Empty;
    public string? Address { get; set; }
    public string? Phone { get; set; }
    public string? Email { get; set; }
    public string? ManagerUserId { get; set; }
    public string? OpenTime { get; set; }
    public string? CloseTime { get; set; }
    public decimal VatRate { get; set; } = 3.0m;
    public bool IsActive { get; set; } = true;
    public DateTime CreatedAtUtc { get; set; } = DateTime.UtcNow;
    public DateTime UpdatedAtUtc { get; set; } = DateTime.UtcNow;
}
