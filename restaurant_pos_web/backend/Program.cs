using Microsoft.AspNetCore.HttpOverrides;
using System.Text;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using RestaurantPos.Api.Data;
using RestaurantPos.Api.Hubs;
using RestaurantPos.Api.Security;
using RestaurantPos.Api.Services;

var builder = WebApplication.CreateBuilder(new WebApplicationOptions
{
    Args = args,
    ContentRootPath = Directory.GetCurrentDirectory()
});

// Vô hiệu hóa reload on change để tránh lỗi inotify trên Render
foreach (var source in builder.Configuration.Sources.OfType<Microsoft.Extensions.Configuration.Json.JsonConfigurationSource>())
{
    source.ReloadOnChange = false;
}

var port = Environment.GetEnvironmentVariable("PORT") ?? "80";
builder.WebHost.UseUrls($"http://*:{port}");

builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();
builder.Services.AddSignalR();
builder.Services.AddScoped<JwtTokenService>();

builder.Services.Configure<ForwardedHeadersOptions>(options =>
{
    options.ForwardedHeaders = ForwardedHeaders.XForwardedFor | ForwardedHeaders.XForwardedProto;
});

builder.Services.AddDbContext<AppDbContext>(options =>
{
    var rawUrl = Environment.GetEnvironmentVariable("DATABASE_URL")
                 ?? builder.Configuration.GetConnectionString("DefaultConnection");

    if (!string.IsNullOrEmpty(rawUrl))
    {
        string connectionString = rawUrl;
        if (rawUrl.StartsWith("postgres://") || rawUrl.StartsWith("postgresql://"))
        {
            var databaseUri = new Uri(rawUrl.Replace("postgresql://", "postgres://"));
            var userInfo = databaseUri.UserInfo.Split(':');
            connectionString = $"Host={databaseUri.Host};Port={(databaseUri.Port > 0 ? databaseUri.Port : 5432)};Username={userInfo[0]};Password={userInfo[1]};Database={databaseUri.AbsolutePath.TrimStart('/')};SSL Mode=Require;Trust Server Certificate=true";
        }
        options.UseNpgsql(connectionString);
    }
});

var jwtIssuer = builder.Configuration["Jwt:Issuer"] ?? "RestaurantPos.Api";
var jwtAudience = builder.Configuration["Jwt:Audience"] ?? "RestaurantPos.Web";
var jwtSecret = Environment.GetEnvironmentVariable("Jwt__SecretKey")
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
    options.AddPolicy(AuthPolicies.StaffOrAbove, p => p.RequireRole(UserRoles.Admin, UserRoles.Owner, UserRoles.Staff));
});

// Nới lỏng CORS tối đa cho mục đích debug
builder.Services.AddCors(options =>
{
    options.AddPolicy("FrontendPolicy", policy =>
    {
        policy.AllowAnyOrigin()
              .AllowAnyHeader()
              .AllowAnyMethod();
    });
});

var app = builder.Build();

app.UseForwardedHeaders();

// Đảm bảo thư mục uploads tồn tại để không bị lỗi 404
var uploadsPath = Path.Combine(app.Environment.ContentRootPath, "wwwroot", "uploads");
if (!Directory.Exists(uploadsPath))
{
    Directory.CreateDirectory(uploadsPath);
}

if (!app.Environment.IsDevelopment())
{
    using var scope = app.Services.CreateScope();
    var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();
    try
    {
        db.Database.Migrate();
    }
    catch (Exception ex)
    {
        Console.WriteLine("Migration failed but continuing: " + ex.Message);
    }
}

app.UseCors("FrontendPolicy");

// Cấu hình Static Files cho thư mục uploads
var fileProvider = new Microsoft.Extensions.FileProviders.PhysicalFileProvider(uploadsPath);
app.UseStaticFiles(new StaticFileOptions
{
    FileProvider = fileProvider,
    RequestPath = "/uploads"
});

app.UseStaticFiles();

app.UseAuthentication();
app.UseAuthorization();
app.MapControllers();
app.MapHub<RevenueHub>("/hubs/revenues");
app.MapHub<TableHub>("/hubs/tables");

app.Run();
