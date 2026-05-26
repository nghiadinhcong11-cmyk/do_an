using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using RestaurantPos.Api.Data;
using RestaurantPos.Api.Models;
using RestaurantPos.Api.Security;

namespace RestaurantPos.Api.Controllers;

[ApiController]
[Route("api/system-admin")]
[Authorize(Policy = AuthPolicies.AdminOnly)]
public class SystemAdminController(AppDbContext dbContext) : ControllerBase
{
    [HttpGet("restaurants")]
    public async Task<ActionResult<List<Restaurant>>> GetRestaurants()
    {
        return await dbContext.Restaurants.OrderByDescending(r => r.CreatedAtUtc).ToListAsync();
    }

    [HttpPatch("restaurants/{id}/toggle-lock")]
    public async Task<IActionResult> ToggleLock(string id)
    {
        var restaurant = await dbContext.Restaurants.FindAsync(id);
        if (restaurant == null) return NotFound();

        restaurant.IsActive = !restaurant.IsActive;
        await dbContext.SaveChangesAsync();
        return Ok(new { restaurant.IsActive });
    }

    [HttpPost("restaurants/{id}/approve")]
    public async Task<IActionResult> ApproveRestaurant(string id)
    {
        var restaurant = await dbContext.Restaurants.FindAsync(id);
        if (restaurant == null) return NotFound();

        restaurant.Status = "Approved";
        await dbContext.SaveChangesAsync();
        return Ok();
    }

    [HttpPost("restaurants/{id}/reject")]
    public async Task<IActionResult> RejectRestaurant(string id)
    {
        var restaurant = await dbContext.Restaurants.FindAsync(id);
        if (restaurant == null) return NotFound();

        restaurant.Status = "Rejected";
        await dbContext.SaveChangesAsync();
        return Ok();
    }

    [HttpGet("stats")]
    public async Task<IActionResult> GetGlobalStats()
    {
        var totalRestaurants = await dbContext.Restaurants.CountAsync();
        var totalUsers = await dbContext.Users.CountAsync();
        var totalOrders = await dbContext.Orders.CountAsync();

        return Ok(new { totalRestaurants, totalUsers, totalOrders });
    }
}
