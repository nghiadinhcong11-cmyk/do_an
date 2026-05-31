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
public class CategoriesController(AppDbContext dbContext) : ControllerBase
{
    [HttpGet]
    public async Task<ActionResult<List<Category>>> GetAll()
    {
        var restaurantId = User.FindFirstValue("restaurant_id");
        if (string.IsNullOrWhiteSpace(restaurantId)) return Unauthorized();

        return await dbContext.Categories
            .Where(c => c.RestaurantId == restaurantId)
            .OrderBy(c => c.DisplayOrder)
            .ThenBy(c => c.Name)
            .ToListAsync();
    }

    [HttpPost]
    [Authorize(Policy = AuthPolicies.OwnerOrAdmin)]
    public async Task<ActionResult<Category>> Create(Category category)
    {
        var restaurantId = User.FindFirstValue("restaurant_id");
        if (string.IsNullOrWhiteSpace(restaurantId)) return Unauthorized();

        category.RestaurantId = restaurantId;
        if (string.IsNullOrEmpty(category.Id))
        {
            category.Id = Guid.NewGuid().ToString("N");
        }

        dbContext.Categories.Add(category);
        await dbContext.SaveChangesAsync();
        return Ok(category);
    }

    [HttpPut("{id}")]
    [Authorize(Policy = AuthPolicies.OwnerOrAdmin)]
    public async Task<IActionResult> Update(string id, Category category)
    {
        var restaurantId = User.FindFirstValue("restaurant_id");
        var existing = await dbContext.Categories
            .FirstOrDefaultAsync(c => c.Id == id && c.RestaurantId == restaurantId);

        if (existing == null) return NotFound();

        existing.Name = category.Name.Trim();
        existing.DisplayOrder = category.DisplayOrder;
        existing.IsActive = category.IsActive;

        await dbContext.SaveChangesAsync();
        return NoContent();
    }

    [HttpDelete("{id}")]
    [Authorize(Policy = AuthPolicies.OwnerOrAdmin)]
    public async Task<IActionResult> Delete(string id)
    {
        var restaurantId = User.FindFirstValue("restaurant_id");
        var category = await dbContext.Categories
            .FirstOrDefaultAsync(c => c.Id == id && c.RestaurantId == restaurantId);

        if (category == null) return NotFound();

        dbContext.Categories.Remove(category);
        await dbContext.SaveChangesAsync();
        return NoContent();
    }
}
