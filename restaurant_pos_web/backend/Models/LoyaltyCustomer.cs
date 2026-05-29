using System.ComponentModel.DataAnnotations;

namespace RestaurantPos.Api.Models;

public class LoyaltyCustomer
{
    [Key]
    public string Id { get; set; } = Guid.NewGuid().ToString("N");
    public string RestaurantId { get; set; } = string.Empty;
    public string Name { get; set; } = string.Empty;
    public string Phone { get; set; } = string.Empty;
    public int Points { get; set; }
    public string Rank { get; set; } = "Bronze";
    public decimal TotalSpent { get; set; }
    public DateTime CreatedAtUtc { get; set; } = DateTime.UtcNow;
}
