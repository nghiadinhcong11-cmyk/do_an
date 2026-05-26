using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using RestaurantPos.Api.Data;
using RestaurantPos.Api.Models;

namespace RestaurantPos.Api.Controllers;

[ApiController]
[Route("api/public")]
public class PublicController(AppDbContext dbContext) : ControllerBase
{
    [HttpGet("menu/{restaurantId}")]
    public async Task<ActionResult<object>> GetPublicMenu(string restaurantId)
    {
        var restaurant = await dbContext.Restaurants
            .FirstOrDefaultAsync(r => r.Id == restaurantId);

        if (restaurant == null || !restaurant.IsActive)
            return NotFound("Restaurant not found or inactive.");

        var products = await dbContext.Products
            .Where(p => p.RestaurantId == restaurantId && p.IsVisibleToStaff)
            .OrderBy(p => p.Category)
            .ThenBy(p => p.Name)
            .Select(p => new { p.Id, p.Name, p.Price, p.Category, p.ImageUrl })
            .ToListAsync();

        return Ok(new { restaurantName = restaurant.Name, products });
    }

    [HttpGet("table-info/{tableId}")]
    public async Task<ActionResult<RestaurantTable>> GetTableInfo(string tableId)
    {
        var table = await dbContext.Tables.FindAsync(tableId);
        if (table == null) return NotFound();
        return Ok(table);
    }
}
