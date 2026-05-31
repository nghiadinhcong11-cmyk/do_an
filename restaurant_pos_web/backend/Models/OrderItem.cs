using System.ComponentModel.DataAnnotations;

namespace RestaurantPos.Api.Models;

public class OrderItem
{
    [Key]
    public int Id { get; set; }
    public string OrderId { get; set; } = string.Empty;
    public string ProductId { get; set; } = string.Empty;
    public string? ProductName { get; set; }
    public decimal UnitPrice { get; set; }
    public int Quantity { get; set; }
    public decimal LineTotal { get; set; }
    public string? Notes { get; set; }
    public DateTime CreatedAtUtc { get; set; } = DateTime.UtcNow;
}
