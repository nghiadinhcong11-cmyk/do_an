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
public class ProductsController(AppDbContext dbContext) : ControllerBase
{
    [HttpGet]
    public async Task<ActionResult<List<Product>>> GetAll()
    {
        var restaurantId = User.FindFirstValue("restaurant_id");
        if (string.IsNullOrWhiteSpace(restaurantId)) return Unauthorized();

        return await dbContext.Products
            .Where(p => p.RestaurantId == restaurantId)
            .OrderBy(p => p.Name)
            .ToListAsync();
    }

    [HttpPost]
    [Authorize(Policy = AuthPolicies.OwnerOrAdmin)]
    public async Task<ActionResult<Product>> Create(Product product)
    {
        var restaurantId = User.FindFirstValue("restaurant_id");
        if (string.IsNullOrWhiteSpace(restaurantId)) return Unauthorized();

        product.RestaurantId = restaurantId;
        if (string.IsNullOrEmpty(product.Id) || product.Id == "0")
        {
            product.Id = Guid.NewGuid().ToString("N");
        }

        dbContext.Products.Add(product);
        await dbContext.SaveChangesAsync();
        return Ok(product);
    }

    [HttpPut("{id}")]
    [Authorize(Policy = AuthPolicies.OwnerOrAdmin)]
    public async Task<IActionResult> Update(string id, Product product)
    {
        var restaurantId = User.FindFirstValue("restaurant_id");
        if (string.IsNullOrWhiteSpace(restaurantId)) return Unauthorized();

        var existing = await dbContext.Products
            .FirstOrDefaultAsync(p => p.Id == id && p.RestaurantId == restaurantId);

        if (existing == null) return NotFound();

        existing.Name = product.Name;
        existing.Price = product.Price;
        existing.CostPrice = product.CostPrice;
        existing.CategoryId = product.CategoryId;
        existing.Unit = product.Unit;
        existing.ImageUrl = product.ImageUrl;
        existing.IsAvailable = product.IsAvailable;
        existing.IsBestSeller = product.IsBestSeller;
        existing.Description = product.Description;

        await dbContext.SaveChangesAsync();
        return NoContent();
    }

    [HttpDelete("{id}")]
    [Authorize(Policy = AuthPolicies.OwnerOrAdmin)]
    public async Task<IActionResult> Delete(string id)
    {
        var restaurantId = User.FindFirstValue("restaurant_id");
        if (string.IsNullOrWhiteSpace(restaurantId)) return Unauthorized();

        var product = await dbContext.Products
            .FirstOrDefaultAsync(p => p.Id == id && p.RestaurantId == restaurantId);

        if (product == null) return NotFound();

        dbContext.Products.Remove(product);
        await dbContext.SaveChangesAsync();
        return NoContent();
    }

    [HttpPatch("{id}/availability")]
    [Authorize(Policy = AuthPolicies.OwnerOrAdmin)]
    public async Task<IActionResult> UpdateAvailability(string id, [FromBody] UpdateAvailabilityRequest request)
    {
        var restaurantId = User.FindFirstValue("restaurant_id");
        if (string.IsNullOrWhiteSpace(restaurantId)) return Unauthorized();

        var product = await dbContext.Products
            .FirstOrDefaultAsync(p => p.Id == id && p.RestaurantId == restaurantId);

        if (product == null) return NotFound();

        product.IsAvailable = request.IsAvailable;

        await dbContext.SaveChangesAsync();
        return NoContent();
    }

    [HttpPatch("{id}/bestseller")]
    [Authorize(Policy = AuthPolicies.OwnerOrAdmin)]
    public async Task<IActionResult> UpdateBestSeller(string id, [FromBody] UpdateBestSellerRequest request)
    {
        var restaurantId = User.FindFirstValue("restaurant_id");
        if (string.IsNullOrWhiteSpace(restaurantId)) return Unauthorized();

        var product = await dbContext.Products
            .FirstOrDefaultAsync(p => p.Id == id && p.RestaurantId == restaurantId);

        if (product == null) return NotFound();

        product.IsBestSeller = request.IsBestSeller;

        await dbContext.SaveChangesAsync();
        return NoContent();
    }
}

public record UpdateAvailabilityRequest(bool IsAvailable);
public record UpdateBestSellerRequest(bool IsBestSeller);
