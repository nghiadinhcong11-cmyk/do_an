using System.ComponentModel.DataAnnotations;

namespace RestaurantPos.Api.Models;

public class OrderRequest
{
    [Key]
    public string Id { get; set; } = Guid.NewGuid().ToString("N");
    public string RestaurantId { get; set; } = string.Empty;
    public string TableId { get; set; } = string.Empty;
    public string TableName { get; set; } = string.Empty;
    public string Type { get; set; } = "order"; // order, callStaff, payment
    public string Status { get; set; } = "pending"; // pending, confirmed, cancelled
    public DateTime CreatedAtUtc { get; set; } = DateTime.UtcNow;
    public string? Note { get; set; }

    public List<OrderRequestItem> Items { get; set; } = [];
}

public class OrderRequestItem
{
    [Key]
    public int Id { get; set; }
    public string RequestId { get; set; } = string.Empty;
    public string ProductId { get; set; } = string.Empty;
    public string ProductName { get; set; } = string.Empty;
    public int Quantity { get; set; }
    public string? Note { get; set; }
}
