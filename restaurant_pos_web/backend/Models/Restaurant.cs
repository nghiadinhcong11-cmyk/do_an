using System.ComponentModel.DataAnnotations;

namespace RestaurantPos.Api.Models;

public class Restaurant
{
    [Key]
    public string Id { get; set; } = Guid.NewGuid().ToString("N");
    public string Name { get; set; } = string.Empty;
    public string OwnerUserId { get; set; } = string.Empty;
    public string Status { get; set; } = "Pending";
    public bool IsActive { get; set; } = true;
    public string? ContactPhone { get; set; }
    public string? ContactEmail { get; set; }
    public string? Address { get; set; }
    public string? LogoUrl { get; set; }
    public decimal VatRate { get; set; } = 3.0m;
    public bool QrOrderEnabled { get; set; } = true;
    public string? SubscriptionPlan { get; set; } = "Free";

    public string? BankCode { get; set; }
    public string? BankAccountNumber { get; set; }
    public string? BankAccountName { get; set; }

    public DateTime CreatedAtUtc { get; set; } = DateTime.UtcNow;
    public DateTime UpdatedAtUtc { get; set; } = DateTime.UtcNow;
}
