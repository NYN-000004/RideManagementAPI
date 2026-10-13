using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using RideManagementAPI.Data;
using RideManagementAPI.Models;

namespace RideManagementAPI.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize]
    public class PlatformSettingsController : ControllerBase
    {
        private readonly AppDbContext _context;

        public PlatformSettingsController(AppDbContext context)
        {
            _context = context;
        }

        [HttpGet]
        public async Task<IActionResult> GetSettings()
        {
            var settings = await _context.PlatformSettings.ToListAsync();
            return Ok(settings);
        }

        [HttpGet("{id}")]
        public async Task<IActionResult> GetSetting(int id)
        {
            var setting = await _context.PlatformSettings.FindAsync(id);

            if (setting == null)
                return NotFound(new { message = "Platform setting not found" });

            return Ok(setting);
        }

        [HttpPost]
        public async Task<IActionResult> CreateSetting(PlatformSetting setting)
        {
            _context.PlatformSettings.Add(setting);
            await _context.SaveChangesAsync();

            return Ok(setting);
        }

        [HttpPut("{id}")]
        public async Task<IActionResult> UpdateSetting(
            int id,
            PlatformSetting setting)
        {
            if (id != setting.Id)
                return BadRequest();

            _context.Entry(setting).State = EntityState.Modified;
            await _context.SaveChangesAsync();

            return Ok(setting);
        }

        [HttpDelete("{id}")]
        public async Task<IActionResult> DeactivateSetting(int id)
        {
            var setting = await _context.PlatformSettings.FindAsync(id);

            if (setting == null)
                return NotFound(new { message = "Platform setting not found" });

            setting.IsActive = false;
            await _context.SaveChangesAsync();

            return Ok(new
            {
                message = "Platform setting deactivated successfully"
            });
        }
    }
}