using System.ComponentModel.DataAnnotations;

namespace RestaurantPos.Api.Models;

public class Restaurant
{
    [Key]
    public string Id { get; set; } = Guid.NewGuid().ToString("N");
    public string Name { get; set; } = string.Empty;
    public string OwnerId { get; set; } = string.Empty; // Username or Id of the creator
    public string Status { get; set; } = "Pending"; // Pending, Approved, Rejected
    public bool IsActive { get; set; } = true;
    public DateTime CreatedAtUtc { get; set; } = DateTime.UtcNow;
    public string? ContactPhone { get; set; }
    public string? Address { get; set; }
}
