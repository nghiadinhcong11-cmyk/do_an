using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using RestaurantPos.Api.Data;
using RestaurantPos.Api.Models;
using RestaurantPos.Api.Security;

namespace RestaurantPos.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize(Policy = AuthPolicies.StaffOrAbove)]
public class IngredientsController(AppDbContext dbContext) : ControllerBase
{
    [HttpGet]
    public async Task<ActionResult<List<Ingredient>>> GetAll()
    {
        var restaurantId = User.FindFirstValue("restaurant_id");
        if (string.IsNullOrWhiteSpace(restaurantId)) return Unauthorized();

        return await dbContext.Ingredients
            .Where(i => i.RestaurantId == restaurantId)
            .OrderBy(i => i.Name)
            .ToListAsync();
    }

    [HttpPost]
    public async Task<ActionResult<Ingredient>> Create(Ingredient ingredient)
    {
        var restaurantId = User.FindFirstValue("restaurant_id");
        if (string.IsNullOrWhiteSpace(restaurantId)) return Unauthorized();

        ingredient.RestaurantId = restaurantId;
        if (string.IsNullOrEmpty(ingredient.Id)) ingredient.Id = Guid.NewGuid().ToString("N");

        dbContext.Ingredients.Add(ingredient);
        await dbContext.SaveChangesAsync();
        return Ok(ingredient);
    }

    [HttpPost("import")]
    public async Task<IActionResult> Import(string id, [FromBody] decimal quantity, [FromQuery] string? note)
    {
        var restaurantId = User.FindFirstValue("restaurant_id");
        var ingredient = await dbContext.Ingredients
            .FirstOrDefaultAsync(i => i.Id == id && i.RestaurantId == restaurantId);

        if (ingredient == null) return NotFound();

        ingredient.StockQuantity += quantity;
        ingredient.LastUpdatedUtc = DateTime.UtcNow;

        dbContext.InventoryTransactions.Add(new InventoryTransaction
        {
            IngredientId = id,
            Type = "Import",
            Quantity = quantity,
            Note = note
        });

        await dbContext.SaveChangesAsync();
        return Ok(ingredient);
    }
}
