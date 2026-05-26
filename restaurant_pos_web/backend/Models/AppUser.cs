namespace RestaurantPos.Api.Models;

public class AppUser
{
    public int Id { get; set; }
    public string Username { get; set; } = string.Empty;
    public string PasswordHash { get; set; } = string.Empty;
    public string Role { get; set; } = "owner";
    public string RestaurantId { get; set; } = string.Empty;
    public string? BranchId { get; set; }
    public DateTime CreatedAtUtc { get; set; } = DateTime.UtcNow;
}
