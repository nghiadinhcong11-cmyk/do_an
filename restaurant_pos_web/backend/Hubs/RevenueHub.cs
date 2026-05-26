using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.SignalR;

namespace RestaurantPos.Api.Hubs;

[Authorize]
public class RevenueHub : Hub
{
    public override async Task OnConnectedAsync()
    {
        var restaurantId = Context.User?.FindFirstValue("restaurant_id");
        var branchId = Context.User?.FindFirstValue("branch_id");

        if (!string.IsNullOrWhiteSpace(restaurantId))
        {
            await Groups.AddToGroupAsync(Context.ConnectionId, $"restaurant:{restaurantId}");
            if (!string.IsNullOrWhiteSpace(branchId))
            {
                await Groups.AddToGroupAsync(Context.ConnectionId, $"branch:{restaurantId}:{branchId}");
            }
        }

        await base.OnConnectedAsync();
    }
}
