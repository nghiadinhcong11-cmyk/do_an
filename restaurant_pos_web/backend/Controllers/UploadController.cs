using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace RestaurantPos.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class UploadController : ControllerBase
{
    private readonly IWebHostEnvironment _environment;

    public UploadController(IWebHostEnvironment environment)
    {
        _environment = environment;
    }

    [HttpPost("image")]
    public async Task<IActionResult> UploadImage(IFormFile file)
    {
        if (file == null || file.Length == 0)
            return BadRequest("No file uploaded.");

        // Dùng ContentRootPath để đảm bảo đường dẫn tuyệt đối trong Docker/Render
        var uploadsFolder = Path.Combine(_environment.ContentRootPath, "wwwroot", "uploads");
        if (!Directory.Exists(uploadsFolder))
            Directory.CreateDirectory(uploadsFolder);

        var fileName = $"{Guid.NewGuid()}{Path.GetExtension(file.FileName)}";
        var filePath = Path.Combine(uploadsFolder, fileName);

        using (var stream = new FileStream(filePath, FileMode.Create))
        {
            await file.CopyToAsync(stream);
        }

        // Tạo URL tuyệt đối chuẩn HTTPS
        var host = Request.Host.Value;
        var scheme = Request.Headers["X-Forwarded-Proto"].FirstOrDefault() ?? (Request.IsHttps ? "https" : "http");
        var imageUrl = $"{scheme}://{host}/uploads/{fileName}";

        return Ok(new { imageUrl });
    }
}
