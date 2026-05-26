namespace RestaurantPos.Api.DTOs;

public record RegisterRequest(
    string Username,
    string Password,
    string? RestaurantId,
    string? RestaurantName,
    string? BranchId,
    string? Role
);

public record LoginRequest(string Username, string Password);

public record AuthResponse(
    string Token,
    string Username,
    string Role,
    string RestaurantId,
    string? BranchId,
    string? RestaurantStatus = "Approved"
);

public record CreateRevenueRequest(decimal Amount, string Note);
public record RevenueResponse(int Id, decimal Amount, string Note, DateTime CreatedAtUtc, string CreatedBy, string RestaurantId, string? BranchId);
public record UserSummaryResponse(int Id, string Username, string Role, string RestaurantId, string? BranchId);
