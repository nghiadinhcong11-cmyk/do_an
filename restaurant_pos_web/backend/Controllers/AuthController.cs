using System.Security.Claims;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using RestaurantPos.Api.Data;
using RestaurantPos.Api.DTOs;
using RestaurantPos.Api.Models;
using RestaurantPos.Api.Security;
using RestaurantPos.Api.Services;

namespace RestaurantPos.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
public class AuthController(AppDbContext dbContext, JwtTokenService jwtTokenService) : ControllerBase
{
    [HttpPost("register")]
    public async Task<ActionResult<AuthResponse>> Register(RegisterRequest request)
    {
        var username = request.Username.Trim();
        if (string.IsNullOrWhiteSpace(username) || string.IsNullOrWhiteSpace(request.Password))
        {
            return BadRequest("Username and password are required.");
        }

        var exists = await dbContext.Users.AnyAsync(x => x.Username == username);
        if (exists)
        {
            return Conflict("Username already exists.");
        }

        var requestedRole = (request.Role ?? UserRoles.Owner).Trim().ToLowerInvariant();
        if (!UserRoles.All.Contains(requestedRole))
        {
            return BadRequest("Invalid role.");
        }

        var callerRole = User.FindFirstValue(ClaimTypes.Role)?.ToLowerInvariant();
        var isAdminCaller = callerRole == UserRoles.Admin;
        var isValidAdminCode = request.AdminCode == "FOKA@ADMIN";

        if (requestedRole == UserRoles.Admin && !isAdminCaller && !isValidAdminCode)
        {
            return Forbid();
        }

        var restaurantId = string.IsNullOrWhiteSpace(request.RestaurantId)
            ? Guid.NewGuid().ToString("N")
            : request.RestaurantId.Trim();

        if (requestedRole == UserRoles.Owner && string.IsNullOrWhiteSpace(request.RestaurantId))
        {
            var restaurant = new Restaurant
            {
                Id = restaurantId,
                Name = request.RestaurantName ?? $"{username}'s Restaurant",
                OwnerId = username,
                Status = "Pending"
            };
            dbContext.Restaurants.Add(restaurant);
        }

        var user = new AppUser
        {
            Username = username,
            PasswordHash = BCrypt.Net.BCrypt.HashPassword(request.Password),
            Role = requestedRole,
            RestaurantId = restaurantId,
            BranchId = string.IsNullOrWhiteSpace(request.BranchId) ? null : request.BranchId.Trim()
        };

        dbContext.Users.Add(user);
        await dbContext.SaveChangesAsync();

        var token = jwtTokenService.GenerateToken(user);
        var resObj = await dbContext.Restaurants.FindAsync(user.RestaurantId);
        var status = resObj?.Status ?? "Approved";

        return Ok(new AuthResponse(token, user.Username, user.Role, user.RestaurantId, user.BranchId, status));
    }

    [HttpPost("login")]
    public async Task<ActionResult<AuthResponse>> Login(LoginRequest request)
    {
        var username = request.Username.Trim();
        var user = await dbContext.Users.FirstOrDefaultAsync(x => x.Username == username);
        if (user is null || !BCrypt.Net.BCrypt.Verify(request.Password, user.PasswordHash))
        {
            return Unauthorized("Invalid credentials.");
        }

        var token = jwtTokenService.GenerateToken(user);
        var restaurant = await dbContext.Restaurants.FindAsync(user.RestaurantId);
        var status = restaurant?.Status ?? "Approved";

        return Ok(new AuthResponse(token, user.Username, user.Role, user.RestaurantId, user.BranchId, status));
    }
}
