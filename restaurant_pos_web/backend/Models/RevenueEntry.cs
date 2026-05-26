namespace RestaurantPos.Api.Models;

public class RevenueEntry
{
    public int Id { get; set; }
    public decimal Amount { get; set; }
    public string Note { get; set; } = string.Empty;
    public DateTime CreatedAtUtc { get; set; } = DateTime.UtcNow;
    public string RestaurantId { get; set; } = string.Empty;
    public string? BranchId { get; set; }
    public int CreatedByUserId { get; set; }
    public AppUser? CreatedByUser { get; set; }
}
