using Microsoft.AspNetCore.SignalR;

namespace RestaurantPos.Api.Hubs;

public class TableHub : Hub
{
    public async Task JoinRestaurantGroup(string restaurantId)
    {
        await Groups.AddToGroupAsync(Context.ConnectionId, $"restaurant:{restaurantId}");
    }
}
