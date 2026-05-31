using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using RestaurantPos.Api.Data;
using RestaurantPos.Api.Security;

namespace RestaurantPos.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize(Policy = AuthPolicies.OwnerOrAdmin)]
public class StatsController(AppDbContext dbContext) : ControllerBase
{
    [HttpGet("revenue-chart")]
    public async Task<IActionResult> GetRevenueChart()
    {
        var restaurantId = User.FindFirstValue("restaurant_id");
        if (string.IsNullOrWhiteSpace(restaurantId)) return Unauthorized();

        var startDate = DateTime.UtcNow.Date.AddDays(-6);

        var stats = await dbContext.Orders
            .Where(o => o.RestaurantId == restaurantId && o.CreatedAtUtc >= startDate)
            .GroupBy(o => o.CreatedAtUtc.Date)
            .Select(g => new
            {
                Date = g.Key,
                Total = g.Sum(o => o.TotalAmount)
            })
            .OrderBy(x => x.Date)
            .ToListAsync();

        // Fill missing days with 0
        var result = Enumerable.Range(0, 7)
            .Select(offset => startDate.AddDays(offset))
            .Select(date => new
            {
                Date = date.ToString("dd/MM"),
                Amount = stats.FirstOrDefault(s => s.Date == date)?.Total ?? 0
            });

        return Ok(result);
    }

    [HttpGet("top-products")]
    public async Task<IActionResult> GetTopProducts()
    {
        var restaurantId = User.FindFirstValue("restaurant_id");
        if (string.IsNullOrWhiteSpace(restaurantId)) return Unauthorized();

        var topProducts = await (from oi in dbContext.OrderItems
                                join o in dbContext.Orders on oi.OrderId equals o.Id
                                join p in dbContext.Products on oi.ProductId equals p.Id
                                where o.RestaurantId == restaurantId
                                group oi by new { p.Id, p.Name } into g
                                orderby g.Sum(x => x.Quantity) descending
                                select new
                                {
                                    Name = g.Key.Name,
                                    Value = g.Sum(x => x.Quantity)
                                })
                                .Take(5)
                                .ToListAsync();

        return Ok(topProducts);
    }

    [HttpGet("summary")]
    public async Task<IActionResult> GetSummary()
    {
        var restaurantId = User.FindFirstValue("restaurant_id");
        if (string.IsNullOrWhiteSpace(restaurantId)) return Unauthorized();

        var today = DateTime.UtcNow.Date;

        var todayRevenue = await dbContext.Orders
            .Where(o => o.RestaurantId == restaurantId && o.CreatedAtUtc >= today)
            .SumAsync(o => (decimal?)o.TotalAmount) ?? 0;

        var todayOrders = await dbContext.Orders
            .Where(o => o.RestaurantId == restaurantId && o.CreatedAtUtc >= today)
            .CountAsync();

        var totalProducts = await dbContext.Products
            .Where(p => p.RestaurantId == restaurantId)
            .CountAsync();

        return Ok(new { todayRevenue, todayOrders, totalProducts });
    }
}
