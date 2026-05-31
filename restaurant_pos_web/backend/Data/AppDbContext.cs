using Microsoft.EntityFrameworkCore;
using RestaurantPos.Api.Models;

namespace RestaurantPos.Api.Data;

public class AppDbContext(DbContextOptions<AppDbContext> options) : DbContext(options)
{
    public DbSet<AppUser> Users => Set<AppUser>();
    public DbSet<Restaurant> Restaurants => Set<Restaurant>();
    public DbSet<Branch> Branches => Set<Branch>();
    public DbSet<RevenueEntry> RevenueEntries => Set<RevenueEntry>();
    public DbSet<Product> Products => Set<Product>();
    public DbSet<Category> Categories => Set<Category>();
    public DbSet<RestaurantTable> Tables => Set<RestaurantTable>();
    public DbSet<Order> Orders => Set<Order>();
    public DbSet<OrderItem> OrderItems => Set<OrderItem>();
    public DbSet<Expense> Expenses => Set<Expense>();
    public DbSet<Ingredient> Ingredients => Set<Ingredient>();
    public DbSet<ProductIngredient> ProductIngredients => Set<ProductIngredient>();
    public DbSet<InventoryTransaction> InventoryTransactions => Set<InventoryTransaction>();
    public DbSet<LoyaltyCustomer> LoyaltyCustomers => Set<LoyaltyCustomer>();
    public DbSet<Voucher> Vouchers => Set<Voucher>();
    public DbSet<OrderRequest> OrderRequests => Set<OrderRequest>();
    public DbSet<OrderRequestItem> OrderRequestItems => Set<OrderRequestItem>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<AppUser>()
            .HasIndex(u => u.Username)
            .IsUnique();

        modelBuilder.Entity<AppUser>()
            .HasIndex(u => new { u.RestaurantId, u.Role });

        modelBuilder.Entity<AppUser>()
            .Property(u => u.Role)
            .HasMaxLength(30);

        modelBuilder.Entity<Restaurant>(entity =>
        {
            entity.HasIndex(r => r.OwnerId);
        });

        modelBuilder.Entity<Branch>(entity =>
        {
            entity.HasIndex(b => b.RestaurantId);
        });

        modelBuilder.Entity<RevenueEntry>()
            .Property(r => r.Amount)
            .HasPrecision(18, 2);

        modelBuilder.Entity<RevenueEntry>()
            .HasIndex(r => new { r.RestaurantId, r.CreatedAtUtc });

        modelBuilder.Entity<Product>(entity =>
        {
            entity.HasIndex(p => p.RestaurantId);
            entity.Property(p => p.Price).HasPrecision(18, 2);
            entity.Property(p => p.CostPrice).HasPrecision(18, 2);

            entity.HasOne<Category>()
                .WithMany()
                .HasForeignKey(p => p.CategoryId)
                .OnDelete(DeleteBehavior.SetNull);
        });

        modelBuilder.Entity<Category>(entity =>
        {
            entity.HasIndex(c => c.RestaurantId);
        });

        modelBuilder.Entity<RestaurantTable>(entity =>
        {
            entity.HasIndex(t => t.RestaurantId);
        });

        modelBuilder.Entity<Order>(entity =>
        {
            entity.HasIndex(o => o.RestaurantId);
            entity.Property(o => o.SubTotal).HasPrecision(18, 2);
            entity.Property(o => o.VatAmount).HasPrecision(18, 2);
            entity.Property(o => o.TotalAmount).HasPrecision(18, 2);
            entity.Property(o => o.DiscountAmount).HasPrecision(18, 2);
        });

        modelBuilder.Entity<OrderItem>(entity =>
        {
            entity.Property(oi => oi.Price).HasPrecision(18, 2);
        });

        modelBuilder.Entity<Expense>(entity =>
        {
            entity.HasIndex(e => e.RestaurantId);
            entity.Property(e => e.Amount).HasPrecision(18, 2);
        });

        modelBuilder.Entity<Ingredient>(entity =>
        {
            entity.HasIndex(i => i.RestaurantId);
            entity.Property(i => i.StockQuantity).HasPrecision(18, 3);
            entity.Property(i => i.MinStockLevel).HasPrecision(18, 3);
        });

        modelBuilder.Entity<ProductIngredient>(entity =>
        {
            entity.HasIndex(pi => pi.ProductId);
            entity.Property(pi => pi.Quantity).HasPrecision(18, 3);
        });

        modelBuilder.Entity<InventoryTransaction>(entity =>
        {
            entity.HasIndex(it => it.IngredientId);
            entity.Property(it => it.Quantity).HasPrecision(18, 3);
        });

        modelBuilder.Entity<LoyaltyCustomer>(entity =>
        {
            entity.HasIndex(l => new { l.RestaurantId, l.Phone });
            entity.Property(l => l.TotalSpent).HasPrecision(18, 2);
        });

        modelBuilder.Entity<Voucher>(entity =>
        {
            entity.HasIndex(v => new { v.RestaurantId, v.Code });
            entity.Property(v => v.DiscountValue).HasPrecision(18, 2);
            entity.Property(v => v.MinOrderValue).HasPrecision(18, 2);
        });

        modelBuilder.Entity<OrderRequest>(entity =>
        {
            entity.HasIndex(r => r.RestaurantId);
        });
    }
}
