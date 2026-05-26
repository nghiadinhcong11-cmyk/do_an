using System.Text;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using RestaurantPos.Api.Data;
using RestaurantPos.Api.Hubs;
using RestaurantPos.Api.Security;
using RestaurantPos.Api.Services;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();
builder.Services.AddSignalR();
builder.Services.AddScoped<JwtTokenService>();

builder.Services.AddDbContext<AppDbContext>(options =>
{
    var rawUrl = Environment.GetEnvironmentVariable("DATABASE_URL");
    string? connectionString = null;

    if (!string.IsNullOrEmpty(rawUrl))
    {
        Console.WriteLine("=> Found DATABASE_URL in environment.");
        rawUrl = rawUrl.Trim();

        if (rawUrl.StartsWith("postgres://") || rawUrl.StartsWith("postgresql://"))
        {
            try
            {
                var uri = new Uri(rawUrl.Replace("postgresql://", "postgres://"));
                var userInfo = uri.UserInfo.Split(':');
                connectionString = $"Host={uri.Host};Port={uri.Port};Username={userInfo[0]};Password={userInfo[1]};Database={uri.AbsolutePath.TrimStart('/')};SSL Mode=Require;Trust Server Certificate=true";
                Console.WriteLine("=> Successfully parsed PostgreSQL URI.");
            }
            catch (Exception ex)
            {
                Console.WriteLine($"=> Error parsing DATABASE_URL: {ex.Message}");
            }
        }
    }

    if (string.IsNullOrEmpty(connectionString))
    {
        connectionString = builder.Configuration.GetConnectionString("DefaultConnection");
        Console.WriteLine("=> Using connection string from configuration (appsettings.json).");
    }

    if (string.IsNullOrEmpty(connectionString))
    {
        throw new Exception("No database connection string found!");
    }

    options.UseNpgsql(connectionString);
});

var jwtIssuer = builder.Configuration["Jwt:Issuer"] ?? "RestaurantPos.Api";
var jwtAudience = builder.Configuration["Jwt:Audience"] ?? "RestaurantPos.Web";
var jwtSecret = Environment.GetEnvironmentVariable("Jwt__SecretKey")
                ?? builder.Configuration["Jwt:SecretKey"]
                ?? "VERY_LONG_AND_SECURE_SECRET_KEY_FOR_JWT_TOKEN_123456_CHANGE_ME";

builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
    .AddJwtBearer(options =>
    {
        options.TokenValidationParameters = new TokenValidationParameters
        {
            ValidateIssuer = true,
            ValidateAudience = true,
            ValidateIssuerSigningKey = true,
            ValidateLifetime = true,
            ValidIssuer = jwtIssuer,
            ValidAudience = jwtAudience,
            IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(jwtSecret))
        };

        options.Events = new JwtBearerEvents
        {
            OnMessageReceived = context =>
            {
                var accessToken = context.Request.Query["access_token"];
                var path = context.HttpContext.Request.Path;
                if (!string.IsNullOrEmpty(accessToken) &&
                    (path.StartsWithSegments("/hubs/revenues") || path.StartsWithSegments("/hubs/tables")))
                {
                    context.Token = accessToken;
                }
                return Task.CompletedTask;
            }
        };
    });

builder.Services.AddAuthorization(options =>
{
    options.AddPolicy(AuthPolicies.AdminOnly, p => p.RequireRole(UserRoles.Admin));
    options.AddPolicy(AuthPolicies.OwnerOrAdmin, p => p.RequireRole(UserRoles.Admin, UserRoles.Owner));
    options.AddPolicy(AuthPolicies.ManagerOrAbove, p => p.RequireRole(UserRoles.Admin, UserRoles.Owner, UserRoles.Manager));
    options.AddPolicy(AuthPolicies.StaffOrAbove, p => p.RequireRole(UserRoles.Admin, UserRoles.Owner, UserRoles.Manager, UserRoles.Staff));
});

builder.Services.AddCors(options =>
{
    options.AddPolicy("FrontendPolicy", policy =>
    {
        policy.SetIsOriginAllowed(_ => true) // Cho phép tất cả để tránh lỗi CORS khi deploy
            .AllowAnyHeader()
            .AllowAnyMethod()
            .AllowCredentials();
    });
});

var app = builder.Build();

// Migrate database on startup
using (var scope = app.Services.CreateScope())
{
    var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();
    Console.WriteLine("=> Running migrations...");
    db.Database.Migrate();
    Console.WriteLine("=> Migrations completed.");
}

if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();
app.UseCors("FrontendPolicy");
app.UseAuthentication();
app.UseAuthorization();

app.MapControllers();
app.MapHub<RevenueHub>("/hubs/revenues");
app.MapHub<TableHub>("/hubs/tables");

app.Run();
