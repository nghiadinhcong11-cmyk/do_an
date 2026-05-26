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
public class UsersController(AppDbContext dbContext) : ControllerBase
{
    [HttpGet]
    public async Task<ActionResult<List<AppUser>>> GetMyStaff()
    {
        var restaurantId = User.FindFirstValue("restaurant_id");
        if (string.IsNullOrWhiteSpace(restaurantId)) return Unauthorized();

        return await dbContext.Users
            .Where(u => u.RestaurantId == restaurantId)
            .OrderBy(u => u.Username)
            .ToListAsync();
    }

    [HttpDelete("{id}")]
    public async Task<IActionResult> DeleteUser(int id)
    {
        var restaurantId = User.FindFirstValue("restaurant_id");
        var callerId = int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);

        var user = await dbContext.Users.FindAsync(id);
        if (user == null || user.RestaurantId != restaurantId) return NotFound();
        if (user.Id == callerId) return BadRequest("Cannot delete yourself.");

        dbContext.Users.Remove(user);
        await dbContext.SaveChangesAsync();
        return NoContent();
    }
}
