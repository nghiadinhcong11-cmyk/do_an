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
public class RecipesController(AppDbContext dbContext) : ControllerBase
{
    [HttpGet("{productId}")]
    public async Task<ActionResult<List<ProductIngredient>>> GetRecipe(string productId)
    {
        return await dbContext.ProductIngredients
            .Include(pi => pi.Ingredient)
            .Where(pi => pi.ProductId == productId)
            .ToListAsync();
    }

    [HttpPost("{productId}")]
    public async Task<IActionResult> UpdateRecipe(string productId, List<ProductIngredient> items)
    {
        var restaurantId = User.FindFirstValue("restaurant_id");

        // Verify product belongs to restaurant
        var product = await dbContext.Products.AnyAsync(p => p.Id == productId && p.RestaurantId == restaurantId);
        if (!product) return NotFound("Product not found");

        // Remove old recipe
        var existing = await dbContext.ProductIngredients.Where(pi => pi.ProductId == productId).ToListAsync();
        dbContext.ProductIngredients.RemoveRange(existing);

        // Add new recipe
        foreach (var item in items)
        {
            item.ProductId = productId;
            dbContext.ProductIngredients.Add(item);
        }

        await dbContext.SaveChangesAsync();
        return Ok();
    }
}
