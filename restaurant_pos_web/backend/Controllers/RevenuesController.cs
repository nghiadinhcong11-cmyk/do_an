using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.SignalR;
using Microsoft.EntityFrameworkCore;
using RestaurantPos.Api.Data;
using RestaurantPos.Api.DTOs;
using RestaurantPos.Api.Hubs;
using RestaurantPos.Api.Models;
using RestaurantPos.Api.Security;

namespace RestaurantPos.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize(Policy = AuthPolicies.StaffOrAbove)]
public class RevenuesController(AppDbContext dbContext, IHubContext<RevenueHub> hubContext) : ControllerBase
{
    [HttpGet]
    public async Task<ActionResult<List<RevenueResponse>>> GetAll()
    {
        var restaurantId = User.FindFirstValue("restaurant_id");
        var branchId = User.FindFirstValue("branch_id");
        var role = User.FindFirstValue(ClaimTypes.Role);

        if (string.IsNullOrWhiteSpace(restaurantId))
        {
            return Unauthorized();
        }

        var query = dbContext.RevenueEntries
            .Include(x => x.CreatedByUser)
            .Where(x => x.RestaurantId == restaurantId);

        if (role is UserRoles.Staff)
        {
            query = query.Where(x => x.BranchId == branchId);
        }

        var list = await query
            .OrderByDescending(x => x.CreatedAtUtc)
            .Select(x => new RevenueResponse(x.Id, x.Amount, x.Note, x.CreatedAtUtc, x.CreatedByUser!.Username, x.RestaurantId, x.BranchId))
            .ToListAsync();

        return Ok(list);
    }

    [HttpPost]
    [Authorize(Policy = AuthPolicies.StaffOrAbove)]
    public async Task<ActionResult<RevenueResponse>> Create(CreateRevenueRequest request)
    {
        var userIdRaw = User.FindFirstValue(ClaimTypes.NameIdentifier);
        var restaurantId = User.FindFirstValue("restaurant_id");
        var branchId = User.FindFirstValue("branch_id");
        if (!int.TryParse(userIdRaw, out var userId) || string.IsNullOrWhiteSpace(restaurantId))
        {
            return Unauthorized();
        }

        var user = await dbContext.Users.FindAsync(userId);
        if (user is null)
        {
            return Unauthorized();
        }

        var entity = new RevenueEntry
        {
            Amount = request.Amount,
            Note = request.Note.Trim(),
            RestaurantId = restaurantId,
            BranchId = string.IsNullOrWhiteSpace(branchId) ? null : branchId,
            CreatedByUserId = user.Id
        };

        dbContext.RevenueEntries.Add(entity);
        await dbContext.SaveChangesAsync();

        var response = new RevenueResponse(entity.Id, entity.Amount, entity.Note, entity.CreatedAtUtc, user.Username, entity.RestaurantId, entity.BranchId);

        await hubContext.Clients.Group($"restaurant:{restaurantId}").SendAsync("revenueCreated", response);
        if (!string.IsNullOrWhiteSpace(entity.BranchId))
        {
            await hubContext.Clients.Group($"branch:{restaurantId}:{entity.BranchId}").SendAsync("revenueCreated", response);
        }

        return Ok(response);
    }
}
