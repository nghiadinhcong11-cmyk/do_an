using System.Security.Claims;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using RestaurantPos.Api.Data;
using RestaurantPos.Api.DTOs;
using RestaurantPos.Api.Models;
using RestaurantPos.Api.Security;
using RestaurantPos.Api.Services;

using Microsoft.Extensions.Configuration;

namespace RestaurantPos.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
public class AuthController(AppDbContext dbContext, JwtTokenService jwtTokenService, IConfiguration configuration) : ControllerBase
{
    [HttpPost("register")]
    public async Task<ActionResult<AuthResponse>> Register(RegisterRequest request)
    {
        try
        {
            var username = request.Username.Trim();
            if (string.IsNullOrWhiteSpace(username) || string.IsNullOrWhiteSpace(request.Password))
            {
                return BadRequest("Username and password are required.");
            }

            var exists = await dbContext.Users.AnyAsync(x => x.Username == username);
            if (exists)
            {
                return Conflict("Tên đăng nhập đã tồn tại.");
            }

            var requestedRole = (request.Role ?? UserRoles.Owner).Trim().ToLowerInvariant();
            if (!UserRoles.All.Contains(requestedRole))
            {
                return BadRequest("Vai trò không hợp lệ.");
            }

            var callerRole = User.FindFirstValue(ClaimTypes.Role)?.ToLowerInvariant();
            var isAdminCaller = callerRole == UserRoles.Admin;

            if (requestedRole == UserRoles.Admin && !isAdminCaller)
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
                    OwnerUserId = username,
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
            var resName = resObj?.Name;

            return Ok(new AuthResponse(
                token,
                user.Username,
                user.Role,
                user.RestaurantId,
                resName,
                user.BranchId,
                status,
                resObj?.BankCode,
                resObj?.BankAccountNumber,
                resObj?.BankAccountName));
        }
        catch (Exception ex)
        {
            return StatusCode(500, new { error = "Lỗi máy chủ: " + ex.Message, detail = ex.InnerException?.Message });
        }
    }

    [HttpPost("login")]
    public async Task<ActionResult<AuthResponse>> Login(LoginRequest request)
    {
        try
        {
            var username = request.Username.Trim();
            var user = await dbContext.Users.FirstOrDefaultAsync(x => x.Username == username);

            if (user is null || !BCrypt.Net.BCrypt.Verify(request.Password, user.PasswordHash))
            {
                return Unauthorized("Tên đăng nhập hoặc mật khẩu không chính xác.");
            }

            if (!user.IsActive)
            {
                return BadRequest("Tài khoản hiện đang bị khóa.");
            }

            var token = jwtTokenService.GenerateToken(user);

            user.LastLoginUtc = DateTime.UtcNow;
            await dbContext.SaveChangesAsync();

            string status = "Approved";
            string? resName = null;
            string? bankCode = null;
            string? bankAccountNumber = null;
            string? bankAccountName = null;

            if (!string.IsNullOrWhiteSpace(user.RestaurantId))
            {
                var restaurant = await dbContext.Restaurants.FindAsync(user.RestaurantId);
                if (restaurant != null)
                {
                    status = restaurant.Status;
                    resName = restaurant.Name;
                    bankCode = restaurant.BankCode;
                    bankAccountNumber = restaurant.BankAccountNumber;
                    bankAccountName = restaurant.BankAccountName;
                }
            }

            return Ok(new AuthResponse(
                token,
                user.Username,
                user.Role,
                user.RestaurantId,
                resName,
                user.BranchId,
                status,
                bankCode,
                bankAccountNumber,
                bankAccountName));
        }
        catch (Exception ex)
        {
            return StatusCode(500, new { error = "Lỗi đăng nhập hệ thống", detail = ex.Message, inner = ex.InnerException?.Message });
        }
    }
}
