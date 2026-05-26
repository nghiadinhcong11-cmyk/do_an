namespace RestaurantPos.Api.Security;

public static class UserRoles
{
    public const string Admin = "admin";
    public const string Owner = "owner";
    public const string Manager = "manager";
    public const string Staff = "staff";

    public static readonly HashSet<string> All =
    [
        Admin,
        Owner,
        Manager,
        Staff
    ];
}

public static class AuthPolicies
{
    public const string AdminOnly = "AdminOnly";
    public const string OwnerOrAdmin = "OwnerOrAdmin";
    public const string ManagerOrAbove = "ManagerOrAbove";
    public const string StaffOrAbove = "StaffOrAbove";
}
