using System.ComponentModel.DataAnnotations;

namespace RestaurantPos.Api.Models;

public class Voucher
{
    [Key]
    public string Id { get; set; } = Guid.NewGuid().ToString("N");
    public string RestaurantId { get; set; } = string.Empty;
    public string Code { get; set; } = string.Empty;
    public string Title { get; set; } = string.Empty;
    public decimal DiscountValue { get; set; }
    public bool IsPercentage { get; set; }
    public decimal MinOrderValue { get; set; }
    public DateTime ExpiryDate { get; set; }
}
