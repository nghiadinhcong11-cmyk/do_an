using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using RestaurantPos.Api.Data;
using RestaurantPos.Api.Models;
using Microsoft.AspNetCore.SignalR;
using RestaurantPos.Api.Hubs;

namespace RestaurantPos.Api.Controllers;

[ApiController]
[Route("api/public")]
public class PublicController(AppDbContext dbContext, IHubContext<TableHub> hubContext) : ControllerBase
{
    [HttpGet("menu/{restaurantId}")]
    public async Task<ActionResult<object>> GetPublicMenu(string restaurantId)
    {
        var restaurant = await dbContext.Restaurants
            .FirstOrDefaultAsync(r => r.Id == restaurantId);

        if (restaurant == null || !restaurant.IsActive)
            return NotFound("Restaurant not found or inactive.");

        var products = await dbContext.Products
            .Where(p => p.RestaurantId == restaurantId && p.IsVisibleToStaff && p.IsAvailable)
            .OrderBy(p => p.CategoryId)
            .ThenBy(p => p.Name)
            .Select(p => new { p.Id, p.Name, p.Price, p.CategoryId, p.ImageUrl, p.IsBestSeller, p.Description, p.Unit })
            .ToListAsync();

        return Ok(new { restaurantName = restaurant.Name, products });
    }

    [HttpPost("request")]
    public async Task<IActionResult> CreateRequest([FromBody] OrderRequest request)
    {
        if (string.IsNullOrEmpty(request.RestaurantId) || string.IsNullOrEmpty(request.TableId))
            return BadRequest("Missing required information.");

        if (string.IsNullOrEmpty(request.Id))
            request.Id = Guid.NewGuid().ToString("N");

        request.CreatedAtUtc = DateTime.UtcNow;
        request.Status = "pending";

        dbContext.OrderRequests.Add(request);
        await dbContext.SaveChangesAsync();

        // Notify Staff via SignalR
        await hubContext.Clients.Group($"restaurant:{request.RestaurantId}")
            .SendAsync("requestReceived", request);

        return Ok(request);
    }

    [HttpGet("table-info/{tableId}")]
    public async Task<ActionResult<RestaurantTable>> GetTableInfo(string tableId)
    {
        var table = await dbContext.Tables.FindAsync(tableId);
        if (table == null) return NotFound();
        return Ok(table);
    }
}
