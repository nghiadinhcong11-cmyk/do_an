using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using Microsoft.IdentityModel.Tokens;
using RestaurantPos.Api.Models;

namespace RestaurantPos.Api.Services;

public class JwtTokenService(IConfiguration configuration)
{
    public string GenerateToken(AppUser user)
    {
        var issuer = configuration["Jwt:Issuer"] ?? "RestaurantPos.Api";
        var audience = configuration["Jwt:Audience"] ?? "RestaurantPos.Web";
        var secret = configuration["Jwt:SecretKey"] ?? throw new InvalidOperationException("Missing JWT secret.");

        var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(secret));
        var credentials = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);

        var claims = new List<Claim>
        {
            new(JwtRegisteredClaimNames.Sub, user.Id.ToString()),
            new(JwtRegisteredClaimNames.UniqueName, user.Username),
            new(ClaimTypes.NameIdentifier, user.Id.ToString()),
            new(ClaimTypes.Name, user.Username),
            new(ClaimTypes.Role, user.Role),
            new("restaurant_id", user.RestaurantId),
            new("branch_id", user.BranchId ?? string.Empty)
        };

        var token = new JwtSecurityToken(
            issuer,
            audience,
            claims,
            expires: DateTime.UtcNow.AddDays(7),
            signingCredentials: credentials
        );

        return new JwtSecurityTokenHandler().WriteToken(token);
    }
}
