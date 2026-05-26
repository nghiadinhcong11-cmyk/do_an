using System.ComponentModel.DataAnnotations;

namespace RestaurantPos.Api.Models;

public class Expense
{
    [Key]
    public string Id { get; set; } = Guid.NewGuid().ToString("N");
    public string RestaurantId { get; set; } = string.Empty;
    public string Title { get; set; } = string.Empty;
    public decimal Amount { get; set; }
    public DateTime DateUtc { get; set; } = DateTime.UtcNow;
    public string Category { get; set; } = string.Empty;
}
