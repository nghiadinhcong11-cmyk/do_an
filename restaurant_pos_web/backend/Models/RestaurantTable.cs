using System.ComponentModel.DataAnnotations;

namespace RestaurantPos.Api.Models;

public class RestaurantTable
{
    [Key]
    public string Id { get; set; } = Guid.NewGuid().ToString("N");
    public string RestaurantId { get; set; } = string.Empty;
    public string Name { get; set; } = string.Empty;
    public int Seats { get; set; }
    public string Status { get; set; } = "TRONG";
}
