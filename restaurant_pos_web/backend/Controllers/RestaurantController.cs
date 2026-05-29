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
[Authorize(Policy = AuthPolicies.OwnerOrAdmin)]
public class RestaurantController(AppDbContext dbContext) : ControllerBase
{
    [HttpGet("my-restaurant")]
    public async Task<ActionResult<Restaurant>> GetMyRestaurant()
    {
        var restaurantId = User.FindFirstValue("restaurant_id");
        if (string.IsNullOrEmpty(restaurantId)) return Unauthorized();

        var restaurant = await dbContext.Restaurants.FindAsync(restaurantId);
        if (restaurant == null) return NotFound();

        return Ok(restaurant);
    }

    [HttpPut("update-profile")]
    public async Task<IActionResult> UpdateProfile(UpdateRestaurantProfileRequest request)
    {
        var restaurantId = User.FindFirstValue("restaurant_id");
        if (string.IsNullOrEmpty(restaurantId)) return Unauthorized();

        var restaurant = await dbContext.Restaurants.FindAsync(restaurantId);
        if (restaurant == null) return NotFound();

        restaurant.Name = request.Name.Trim();
        restaurant.ContactPhone = request.ContactPhone?.Trim();
        restaurant.Address = request.Address?.Trim();

        await dbContext.SaveChangesAsync();
        return Ok(restaurant);
    }
}

public record UpdateRestaurantProfileRequest(string Name, string? ContactPhone, string? Address);
