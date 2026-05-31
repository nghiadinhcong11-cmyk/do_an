namespace RestaurantPos.Api.Models;

public class AppUser
{
    public int Id { get; set; }
    public string Username { get; set; } = string.Empty;
    public string PasswordHash { get; set; } = string.Empty;
    public string? FullName { get; set; }
    public string? Email { get; set; }
    public string? PhoneNumber { get; set; }
    public string Role { get; set; } = "owner";
    public string? RestaurantId { get; set; }
    public string? BranchId { get; set; }
    public bool IsActive { get; set; } = true;
    public DateTime? LastLoginUtc { get; set; }
    public DateTime CreatedAtUtc { get; set; } = DateTime.UtcNow;
}
