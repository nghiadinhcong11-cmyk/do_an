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
public class BranchesController(AppDbContext dbContext) : ControllerBase
{
    [HttpGet]
    public async Task<ActionResult<List<Branch>>> GetAll()
    {
        var restaurantId = User.FindFirstValue("restaurant_id");
        if (string.IsNullOrWhiteSpace(restaurantId)) return Unauthorized();

        return await dbContext.Branches
            .Where(b => b.RestaurantId == restaurantId)
            .OrderBy(b => b.Name)
            .ToListAsync();
    }

    [HttpPost]
    public async Task<ActionResult<Branch>> Create(Branch branch)
    {
        var restaurantId = User.FindFirstValue("restaurant_id");
        if (string.IsNullOrWhiteSpace(restaurantId)) return Unauthorized();

        branch.RestaurantId = restaurantId;
        if (string.IsNullOrEmpty(branch.Id)) branch.Id = Guid.NewGuid().ToString("N");

        dbContext.Branches.Add(branch);
        await dbContext.SaveChangesAsync();
        return Ok(branch);
    }

    [HttpDelete("{id}")]
    public async Task<IActionResult> Delete(string id)
    {
        var restaurantId = User.FindFirstValue("restaurant_id");
        var branch = await dbContext.Branches.FirstOrDefaultAsync(b => b.Id == id && b.RestaurantId == restaurantId);

        if (branch == null) return NotFound();

        dbContext.Branches.Remove(branch);
        await dbContext.SaveChangesAsync();
        return NoContent();
    }
}
