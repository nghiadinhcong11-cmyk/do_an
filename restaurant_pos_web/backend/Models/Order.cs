using System.ComponentModel.DataAnnotations;

namespace RestaurantPos.Api.Models;

public class Order
{
    [Key]
    public string Id { get; set; } = Guid.NewGuid().ToString("N");
    public string RestaurantId { get; set; } = string.Empty;
    public string? BranchId { get; set; }
    public string TableId { get; set; } = string.Empty;
    public string? CustomerId { get; set; }
    public string? VoucherId { get; set; }
    public int? CreatedByUserId { get; set; }
    public string InvoiceNo { get; set; } = string.Empty;
    public string LookupCode { get; set; } = string.Empty;
    public string? Type { get; set; }
    public string? Status { get; set; }
    public string? PaymentMethod { get; set; }
    public string? PaymentStatus { get; set; }
    public string? PaymentContent { get; set; }
    public string? PaymentReference { get; set; }
    public int ItemCount { get; set; }
    public decimal SubTotal { get; set; }
    public decimal DiscountAmount { get; set; }
    public decimal VatAmount { get; set; }
    public decimal TotalAmount { get; set; }
    public string? Notes { get; set; }
    public DateTime? PaidAtUtc { get; set; }
    public DateTime CreatedAtUtc { get; set; } = DateTime.UtcNow;
    public DateTime UpdatedAtUtc { get; set; } = DateTime.UtcNow;

    public List<OrderItem> Items { get; set; } = [];
}
