namespace RestaurantPos.Api.Models;

public class ProductIngredient
{
    public int Id { get; set; }
    public string ProductId { get; set; } = string.Empty;
    public string IngredientId { get; set; } = string.Empty;
    public decimal Quantity { get; set; } // Quantity of ingredient used for 1 unit of product

    public Ingredient? Ingredient { get; set; }
}
