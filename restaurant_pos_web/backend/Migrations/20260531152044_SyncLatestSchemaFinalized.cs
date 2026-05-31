using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace RestaurantPos.Api.Migrations
{
    /// <inheritdoc />
    public partial class SyncLatestSchemaFinalized : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.RenameColumn(
                name: "OwnerId",
                table: "Restaurants",
                newName: "OwnerUserId");

            migrationBuilder.RenameIndex(
                name: "IX_Restaurants_OwnerId",
                table: "Restaurants",
                newName: "IX_Restaurants_OwnerUserId");

            migrationBuilder.RenameColumn(
                name: "DateTimeUtc",
                table: "Orders",
                newName: "UpdatedAtUtc");

            migrationBuilder.RenameColumn(
                name: "Price",
                table: "OrderItems",
                newName: "UnitPrice");

            migrationBuilder.AlterColumn<string>(
                name: "RestaurantId",
                table: "Users",
                type: "text",
                nullable: true,
                oldClrType: typeof(string),
                oldType: "text");

            migrationBuilder.AddColumn<string>(
                name: "Email",
                table: "Users",
                type: "text",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "FullName",
                table: "Users",
                type: "text",
                nullable: true);

            migrationBuilder.AddColumn<bool>(
                name: "IsActive",
                table: "Users",
                type: "boolean",
                nullable: false,
                defaultValue: false);

            migrationBuilder.AddColumn<bool>(
                name: "IsDeleted",
                table: "Users",
                type: "boolean",
                nullable: false,
                defaultValue: false);

            migrationBuilder.AddColumn<DateTime>(
                name: "LastLoginUtc",
                table: "Users",
                type: "timestamp with time zone",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "PhoneNumber",
                table: "Users",
                type: "text",
                nullable: true);

            migrationBuilder.AddColumn<DateTime>(
                name: "UpdatedAtUtc",
                table: "Users",
                type: "timestamp with time zone",
                nullable: false,
                defaultValue: new DateTime(1, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified));

            migrationBuilder.AddColumn<string>(
                name: "BranchId",
                table: "Tables",
                type: "text",
                nullable: true);

            migrationBuilder.AddColumn<DateTime>(
                name: "CreatedAtUtc",
                table: "Tables",
                type: "timestamp with time zone",
                nullable: false,
                defaultValue: new DateTime(1, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified));

            migrationBuilder.AddColumn<int>(
                name: "DisplayOrder",
                table: "Tables",
                type: "integer",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.AddColumn<bool>(
                name: "IsActive",
                table: "Tables",
                type: "boolean",
                nullable: false,
                defaultValue: false);

            migrationBuilder.AddColumn<string>(
                name: "QrToken",
                table: "Tables",
                type: "text",
                nullable: true);

            migrationBuilder.AddColumn<DateTime>(
                name: "UpdatedAtUtc",
                table: "Tables",
                type: "timestamp with time zone",
                nullable: false,
                defaultValue: new DateTime(1, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified));

            migrationBuilder.AddColumn<string>(
                name: "ContactEmail",
                table: "Restaurants",
                type: "text",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "LogoUrl",
                table: "Restaurants",
                type: "text",
                nullable: true);

            migrationBuilder.AddColumn<bool>(
                name: "QrOrderEnabled",
                table: "Restaurants",
                type: "boolean",
                nullable: false,
                defaultValue: false);

            migrationBuilder.AddColumn<string>(
                name: "SubscriptionPlan",
                table: "Restaurants",
                type: "text",
                nullable: true);

            migrationBuilder.AddColumn<DateTime>(
                name: "UpdatedAtUtc",
                table: "Restaurants",
                type: "timestamp with time zone",
                nullable: false,
                defaultValue: new DateTime(1, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified));

            migrationBuilder.AddColumn<decimal>(
                name: "VatRate",
                table: "Restaurants",
                type: "numeric",
                nullable: false,
                defaultValue: 0m);

            migrationBuilder.AddColumn<int>(
                name: "DisplayOrder",
                table: "Products",
                type: "integer",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.AddColumn<bool>(
                name: "IsArchived",
                table: "Products",
                type: "boolean",
                nullable: false,
                defaultValue: false);

            migrationBuilder.AddColumn<string>(
                name: "Sku",
                table: "Products",
                type: "text",
                nullable: true);

            migrationBuilder.AddColumn<DateTime>(
                name: "UpdatedAtUtc",
                table: "Products",
                type: "timestamp with time zone",
                nullable: false,
                defaultValue: new DateTime(1, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified));

            migrationBuilder.AddColumn<string>(
                name: "BranchId",
                table: "Orders",
                type: "text",
                nullable: true);

            migrationBuilder.AddColumn<DateTime>(
                name: "CreatedAtUtc",
                table: "Orders",
                type: "timestamp with time zone",
                nullable: false,
                defaultValue: new DateTime(1, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified));

            migrationBuilder.AddColumn<int>(
                name: "CreatedByUserId",
                table: "Orders",
                type: "integer",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "Notes",
                table: "Orders",
                type: "text",
                nullable: true);

            migrationBuilder.AddColumn<DateTime>(
                name: "PaidAtUtc",
                table: "Orders",
                type: "timestamp with time zone",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "PaymentContent",
                table: "Orders",
                type: "text",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "PaymentMethod",
                table: "Orders",
                type: "text",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "PaymentReference",
                table: "Orders",
                type: "text",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "PaymentStatus",
                table: "Orders",
                type: "text",
                nullable: true);

            migrationBuilder.AddColumn<DateTime>(
                name: "CreatedAtUtc",
                table: "OrderItems",
                type: "timestamp with time zone",
                nullable: false,
                defaultValue: new DateTime(1, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified));

            migrationBuilder.AddColumn<decimal>(
                name: "LineTotal",
                table: "OrderItems",
                type: "numeric",
                nullable: false,
                defaultValue: 0m);

            migrationBuilder.AddColumn<string>(
                name: "Notes",
                table: "OrderItems",
                type: "text",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "ProductName",
                table: "OrderItems",
                type: "text",
                nullable: true);

            migrationBuilder.AddColumn<DateTime>(
                name: "CreatedAtUtc",
                table: "Categories",
                type: "timestamp with time zone",
                nullable: false,
                defaultValue: new DateTime(1, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified));

            migrationBuilder.AddColumn<string>(
                name: "Description",
                table: "Categories",
                type: "text",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "ImageUrl",
                table: "Categories",
                type: "text",
                nullable: true);

            migrationBuilder.AddColumn<DateTime>(
                name: "UpdatedAtUtc",
                table: "Categories",
                type: "timestamp with time zone",
                nullable: false,
                defaultValue: new DateTime(1, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified));

            migrationBuilder.AddColumn<string>(
                name: "CloseTime",
                table: "Branches",
                type: "text",
                nullable: true);

            migrationBuilder.AddColumn<DateTime>(
                name: "CreatedAtUtc",
                table: "Branches",
                type: "timestamp with time zone",
                nullable: false,
                defaultValue: new DateTime(1, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified));

            migrationBuilder.AddColumn<string>(
                name: "Email",
                table: "Branches",
                type: "text",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "ManagerUserId",
                table: "Branches",
                type: "text",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "OpenTime",
                table: "Branches",
                type: "text",
                nullable: true);

            migrationBuilder.AddColumn<DateTime>(
                name: "UpdatedAtUtc",
                table: "Branches",
                type: "timestamp with time zone",
                nullable: false,
                defaultValue: new DateTime(1, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified));

            migrationBuilder.AddColumn<decimal>(
                name: "VatRate",
                table: "Branches",
                type: "numeric",
                nullable: false,
                defaultValue: 0m);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "Email",
                table: "Users");

            migrationBuilder.DropColumn(
                name: "FullName",
                table: "Users");

            migrationBuilder.DropColumn(
                name: "IsActive",
                table: "Users");

            migrationBuilder.DropColumn(
                name: "IsDeleted",
                table: "Users");

            migrationBuilder.DropColumn(
                name: "LastLoginUtc",
                table: "Users");

            migrationBuilder.DropColumn(
                name: "PhoneNumber",
                table: "Users");

            migrationBuilder.DropColumn(
                name: "UpdatedAtUtc",
                table: "Users");

            migrationBuilder.DropColumn(
                name: "BranchId",
                table: "Tables");

            migrationBuilder.DropColumn(
                name: "CreatedAtUtc",
                table: "Tables");

            migrationBuilder.DropColumn(
                name: "DisplayOrder",
                table: "Tables");

            migrationBuilder.DropColumn(
                name: "IsActive",
                table: "Tables");

            migrationBuilder.DropColumn(
                name: "QrToken",
                table: "Tables");

            migrationBuilder.DropColumn(
                name: "UpdatedAtUtc",
                table: "Tables");

            migrationBuilder.DropColumn(
                name: "ContactEmail",
                table: "Restaurants");

            migrationBuilder.DropColumn(
                name: "LogoUrl",
                table: "Restaurants");

            migrationBuilder.DropColumn(
                name: "QrOrderEnabled",
                table: "Restaurants");

            migrationBuilder.DropColumn(
                name: "SubscriptionPlan",
                table: "Restaurants");

            migrationBuilder.DropColumn(
                name: "UpdatedAtUtc",
                table: "Restaurants");

            migrationBuilder.DropColumn(
                name: "VatRate",
                table: "Restaurants");

            migrationBuilder.DropColumn(
                name: "DisplayOrder",
                table: "Products");

            migrationBuilder.DropColumn(
                name: "IsArchived",
                table: "Products");

            migrationBuilder.DropColumn(
                name: "Sku",
                table: "Products");

            migrationBuilder.DropColumn(
                name: "UpdatedAtUtc",
                table: "Products");

            migrationBuilder.DropColumn(
                name: "BranchId",
                table: "Orders");

            migrationBuilder.DropColumn(
                name: "CreatedAtUtc",
                table: "Orders");

            migrationBuilder.DropColumn(
                name: "CreatedByUserId",
                table: "Orders");

            migrationBuilder.DropColumn(
                name: "Notes",
                table: "Orders");

            migrationBuilder.DropColumn(
                name: "PaidAtUtc",
                table: "Orders");

            migrationBuilder.DropColumn(
                name: "PaymentContent",
                table: "Orders");

            migrationBuilder.DropColumn(
                name: "PaymentMethod",
                table: "Orders");

            migrationBuilder.DropColumn(
                name: "PaymentReference",
                table: "Orders");

            migrationBuilder.DropColumn(
                name: "PaymentStatus",
                table: "Orders");

            migrationBuilder.DropColumn(
                name: "CreatedAtUtc",
                table: "OrderItems");

            migrationBuilder.DropColumn(
                name: "LineTotal",
                table: "OrderItems");

            migrationBuilder.DropColumn(
                name: "Notes",
                table: "OrderItems");

            migrationBuilder.DropColumn(
                name: "ProductName",
                table: "OrderItems");

            migrationBuilder.DropColumn(
                name: "CreatedAtUtc",
                table: "Categories");

            migrationBuilder.DropColumn(
                name: "Description",
                table: "Categories");

            migrationBuilder.DropColumn(
                name: "ImageUrl",
                table: "Categories");

            migrationBuilder.DropColumn(
                name: "UpdatedAtUtc",
                table: "Categories");

            migrationBuilder.DropColumn(
                name: "CloseTime",
                table: "Branches");

            migrationBuilder.DropColumn(
                name: "CreatedAtUtc",
                table: "Branches");

            migrationBuilder.DropColumn(
                name: "Email",
                table: "Branches");

            migrationBuilder.DropColumn(
                name: "ManagerUserId",
                table: "Branches");

            migrationBuilder.DropColumn(
                name: "OpenTime",
                table: "Branches");

            migrationBuilder.DropColumn(
                name: "UpdatedAtUtc",
                table: "Branches");

            migrationBuilder.DropColumn(
                name: "VatRate",
                table: "Branches");

            migrationBuilder.RenameColumn(
                name: "OwnerUserId",
                table: "Restaurants",
                newName: "OwnerId");

            migrationBuilder.RenameIndex(
                name: "IX_Restaurants_OwnerUserId",
                table: "Restaurants",
                newName: "IX_Restaurants_OwnerId");

            migrationBuilder.RenameColumn(
                name: "UpdatedAtUtc",
                table: "Orders",
                newName: "DateTimeUtc");

            migrationBuilder.RenameColumn(
                name: "UnitPrice",
                table: "OrderItems",
                newName: "Price");

            migrationBuilder.AlterColumn<string>(
                name: "RestaurantId",
                table: "Users",
                type: "text",
                nullable: false,
                defaultValue: "",
                oldClrType: typeof(string),
                oldType: "text",
                oldNullable: true);
        }
    }
}
