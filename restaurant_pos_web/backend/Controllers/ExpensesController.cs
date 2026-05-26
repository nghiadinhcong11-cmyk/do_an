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
[Authorize(Policy = AuthPolicies.ManagerOrAbove)]
public class ExpensesController(AppDbContext dbContext) : ControllerBase
{
    [HttpGet]
    public async Task<ActionResult<List<Expense>>> GetAll()
    {
        var restaurantId = User.FindFirstValue("restaurant_id");
        if (string.IsNullOrWhiteSpace(restaurantId)) return Unauthorized();

        return await dbContext.Expenses
            .Where(e => e.RestaurantId == restaurantId)
            .OrderByDescending(e => e.DateUtc)
            .ToListAsync();
    }

    [HttpPost]
    public async Task<ActionResult<Expense>> Create(Expense expense)
    {
        var restaurantId = User.FindFirstValue("restaurant_id");
        if (string.IsNullOrWhiteSpace(restaurantId)) return Unauthorized();

        expense.RestaurantId = restaurantId;
        if (string.IsNullOrEmpty(expense.Id))
        {
            expense.Id = Guid.NewGuid().ToString("N");
        }

        dbContext.Expenses.Add(expense);
        await dbContext.SaveChangesAsync();
        return Ok(expense);
    }

    [HttpDelete("{id}")]
    public async Task<IActionResult> Delete(string id)
    {
        var restaurantId = User.FindFirstValue("restaurant_id");
        if (string.IsNullOrWhiteSpace(restaurantId)) return Unauthorized();

        var expense = await dbContext.Expenses
            .FirstOrDefaultAsync(e => e.Id == id && e.RestaurantId == restaurantId);

        if (expense == null) return NotFound();

        dbContext.Expenses.Remove(expense);
        await dbContext.SaveChangesAsync();
        return NoContent();
    }
}
