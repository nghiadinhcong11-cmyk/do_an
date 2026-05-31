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
public class OrdersController(AppDbContext dbContext) : ControllerBase
{
    [HttpGet]
    public async Task<ActionResult<List<Order>>> GetAll()
    {
        var restaurantId = User.FindFirstValue("restaurant_id");
        if (string.IsNullOrWhiteSpace(restaurantId)) return Unauthorized();

        return await dbContext.Orders
            .Include(o => o.Items)
            .Where(o => o.RestaurantId == restaurantId)
            .OrderByDescending(o => o.CreatedAtUtc)
            .ToListAsync();
    }

    [HttpPost]
    public async Task<ActionResult<Order>> Create(Order order)
    {
        var restaurantId = User.FindFirstValue("restaurant_id");
        if (string.IsNullOrWhiteSpace(restaurantId)) return Unauthorized();

        order.RestaurantId = restaurantId;
        if (string.IsNullOrEmpty(order.Id))
        {
            order.Id = Guid.NewGuid().ToString("N");
        }

        foreach (var item in order.Items)
        {
            item.OrderId = order.Id;

            var recipe = await dbContext.ProductIngredients
                .Where(pi => pi.ProductId == item.ProductId)
                .ToListAsync();

            foreach (var recipeItem in recipe)
            {
                var ingredient = await dbContext.Ingredients.FindAsync(recipeItem.IngredientId);
                if (ingredient != null)
                {
                    decimal totalDeduction = recipeItem.Quantity * item.Quantity;
                    ingredient.StockQuantity -= totalDeduction;

                    dbContext.InventoryTransactions.Add(new InventoryTransaction
                    {
                        IngredientId = ingredient.Id,
                        Type = "Sales",
                        Quantity = -totalDeduction,
                        DateUtc = DateTime.UtcNow,
                        ReferenceId = order.Id,
                        Note = $"Bán hàng: Order {order.InvoiceNo}"
                    });
                }
            }
        }

        dbContext.Orders.Add(order);
        await dbContext.SaveChangesAsync();
        return Ok(order);
    }

    [HttpGet("{id}")]
    public async Task<ActionResult<Order>> GetById(string id)
    {
        var restaurantId = User.FindFirstValue("restaurant_id");
        if (string.IsNullOrWhiteSpace(restaurantId)) return Unauthorized();

        var order = await dbContext.Orders
            .Include(o => o.Items)
            .FirstOrDefaultAsync(o => o.Id == id && o.RestaurantId == restaurantId);

        if (order == null) return NotFound();
        return Ok(order);
    }
}
