using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using RestaurantPos.Api.Data;
using RestaurantPos.Api.DTOs;
using RestaurantPos.Api.Security;

namespace RestaurantPos.Api.Controllers;

[ApiController]
[Route("api/admin")]
[Authorize(Policy = AuthPolicies.AdminOnly)]
public class AdminController(AppDbContext dbContext) : ControllerBase
{
    [HttpGet("users")]
    public async Task<ActionResult<List<UserSummaryResponse>>> GetUsers()
    {
        var users = await dbContext.Users
            .OrderBy(x => x.Id)
            .Select(x => new UserSummaryResponse(x.Id, x.Username, x.Role, x.RestaurantId, x.BranchId))
            .ToListAsync();

        return Ok(users);
    }
}
