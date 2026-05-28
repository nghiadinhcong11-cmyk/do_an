using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using RestaurantPos.Api.Data;
using RestaurantPos.Api.Models;
using RestaurantPos.Api.Security;

using Microsoft.AspNetCore.SignalR;
using RestaurantPos.Api.Hubs;

namespace RestaurantPos.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize(Policy = AuthPolicies.StaffOrAbove)]
public class TablesController(AppDbContext dbContext, IHubContext<TableHub> hubContext) : ControllerBase
{
    [HttpGet]
    public async Task<ActionResult<List<RestaurantTable>>> GetAll()
    {
        var restaurantId = User.FindFirstValue("restaurant_id");
        if (string.IsNullOrWhiteSpace(restaurantId)) return Unauthorized();

        return await dbContext.Tables
            .Where(t => t.RestaurantId == restaurantId)
            .OrderBy(t => t.Name)
            .ToListAsync();
    }

    [HttpPost]
    [Authorize(Policy = AuthPolicies.OwnerOrAdmin)]
    public async Task<ActionResult<RestaurantTable>> Create(RestaurantTable table)
    {
        var restaurantId = User.FindFirstValue("restaurant_id");
        if (string.IsNullOrWhiteSpace(restaurantId)) return Unauthorized();

        table.RestaurantId = restaurantId;
        if (string.IsNullOrEmpty(table.Id))
        {
            table.Id = Guid.NewGuid().ToString("N");
        }

        dbContext.Tables.Add(table);
        await dbContext.SaveChangesAsync();
        return Ok(table);
    }

    [HttpPatch("{id}/status")]
    public async Task<IActionResult> UpdateStatus(string id, [FromBody] string status)
    {
        var restaurantId = User.FindFirstValue("restaurant_id");
        if (string.IsNullOrWhiteSpace(restaurantId)) return Unauthorized();

        var table = await dbContext.Tables
            .FirstOrDefaultAsync(t => t.Id == id && t.RestaurantId == restaurantId);

        if (table == null) return NotFound();

        table.Status = status;
        await dbContext.SaveChangesAsync();

        await hubContext.Clients.Group($"restaurant:{restaurantId}")
            .SendAsync("tableStatusChanged", id, status);

        return NoContent();
    }

    [HttpDelete("{id}")]
    [Authorize(Policy = AuthPolicies.OwnerOrAdmin)]
    public async Task<IActionResult> Delete(string id)
    {
        var restaurantId = User.FindFirstValue("restaurant_id");
        if (string.IsNullOrWhiteSpace(restaurantId)) return Unauthorized();

        var table = await dbContext.Tables
            .FirstOrDefaultAsync(t => t.Id == id && t.RestaurantId == restaurantId);

        if (table == null) return NotFound();

        dbContext.Tables.Remove(table);
        await dbContext.SaveChangesAsync();
        return NoContent();
    }
}
