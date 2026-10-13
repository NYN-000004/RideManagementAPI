using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using RideManagementAPI.Data;
using RideManagementAPI.Models;

namespace RideManagementAPI.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class SurgeController : ControllerBase
    {
        private readonly AppDbContext _context;

        public SurgeController(AppDbContext context)
        {
            _context = context;
        }

        // GET: api/Surge
        [HttpGet]
        public async Task<IActionResult> GetSurgeConfigurations()
        {
            var surgeConfigurations =
                await _context.SurgeConfigurations.ToListAsync();

            return Ok(surgeConfigurations);
        }

        // GET: api/Surge/1
        [HttpGet("{id}")]
        public async Task<IActionResult> GetSurgeConfiguration(int id)
        {
            var surge =
                await _context.SurgeConfigurations.FindAsync(id);

            if (surge == null)
                return NotFound(new
                {
                    message = "Surge configuration not found"
                });

            return Ok(surge);
        }

        // POST: api/Surge
        [HttpPost]
        public async Task<IActionResult> CreateSurgeConfiguration(
            SurgeConfiguration surge)
        {
            _context.SurgeConfigurations.Add(surge);
            await _context.SaveChangesAsync();

            return Ok(surge);
        }

        // PUT: api/Surge/1
        [HttpPut("{id}")]
        public async Task<IActionResult> UpdateSurgeConfiguration(
            int id,
            SurgeConfiguration surge)
        {
            if (id != surge.Id)
                return BadRequest();

            _context.Entry(surge).State = EntityState.Modified;

            await _context.SaveChangesAsync();

            return Ok(surge);
        }

        // DELETE: api/Surge/1
        [HttpDelete("{id}")]
        public async Task<IActionResult> DeactivateSurgeConfiguration(
            int id)
        {
            var surge =
                await _context.SurgeConfigurations.FindAsync(id);

            if (surge == null)
                return NotFound(new
                {
                    message = "Surge configuration not found"
                });

            surge.IsActive = false;

            await _context.SaveChangesAsync();

            return Ok(new
            {
                message = "Surge configuration deactivated successfully"
            });
        }
    }
}
