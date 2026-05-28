namespace RestaurantPos.Api.Security;

public static class UserRoles
{
    public const string Admin = "admin";
    public const string Owner = "owner";
    public const string Staff = "staff";
    public const string Customer = "customer";

    public static readonly HashSet<string> All =
    [
        Admin,
        Owner,
        Staff,
        Customer
    ];
}

public static class AuthPolicies
{
    public const string AdminOnly = "AdminOnly";
    public const string OwnerOrAdmin = "OwnerOrAdmin";
    public const string StaffOrAbove = "StaffOrAbove";
    public const string CustomerOrAbove = "CustomerOrAbove";
}
