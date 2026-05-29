using System.ComponentModel.DataAnnotations;

namespace RestaurantPos.Api.Models;

public class Order
{
    [Key]
    public string Id { get; set; } = Guid.NewGuid().ToString("N");
    public string RestaurantId { get; set; } = string.Empty;
    public string TableId { get; set; } = string.Empty;
    public DateTime DateTimeUtc { get; set; } = DateTime.UtcNow;
    public string InvoiceNo { get; set; } = string.Empty;
    public string LookupCode { get; set; } = string.Empty;
    public decimal SubTotal { get; set; }
    public decimal VatAmount { get; set; }
    public decimal TotalAmount { get; set; }
    public string? Type { get; set; }
    public string? Status { get; set; }
    public int ItemCount { get; set; }

    public string? CustomerId { get; set; }
    public string? VoucherId { get; set; }
    public decimal DiscountAmount { get; set; }

    public List<OrderItem> Items { get; set; } = [];
}
