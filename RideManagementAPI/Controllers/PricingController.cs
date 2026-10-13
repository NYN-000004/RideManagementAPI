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
    public class PricingController : ControllerBase
    {
        private readonly AppDbContext _context;

        public PricingController(AppDbContext context)
        {
            _context = context;
        }

        // GET: api/Pricing
        [HttpGet]
        public async Task<IActionResult> GetPricing()
        {
            var pricing = await _context.PricingConfigurations
                .Where(p => p.IsActive)
                .ToListAsync();

            return Ok(pricing);
        }

        // GET: api/Pricing/1
        [HttpGet("{id}")]
        public async Task<IActionResult> GetPricingById(int id)
        {
            var pricing = await _context.PricingConfigurations
                .FindAsync(id);

            if (pricing == null)
                return NotFound(new { message = "Pricing configuration not found" });

            return Ok(pricing);
        }

        // POST: api/Pricing
        [HttpPost]
        public async Task<IActionResult> CreatePricing(
            PricingConfiguration pricing)
        {
            _context.PricingConfigurations.Add(pricing);
            await _context.SaveChangesAsync();

            return Ok(pricing);
        }

        // PUT: api/Pricing/1
        [HttpPut("{id}")]
        public async Task<IActionResult> UpdatePricing(
            int id,
            PricingConfiguration pricing)
        {
            if (id != pricing.Id)
                return BadRequest();

            _context.Entry(pricing).State = EntityState.Modified;
            await _context.SaveChangesAsync();

            return Ok(pricing);
        }

        // DELETE: api/Pricing/1
        [HttpDelete("{id}")]
        public async Task<IActionResult> DeletePricing(int id)
        {
            var pricing = await _context.PricingConfigurations
                .FindAsync(id);

            if (pricing == null)
                return NotFound(new { message = "Pricing configuration not found" });

            pricing.IsActive = false;

            await _context.SaveChangesAsync();

            return Ok(new
            {
                message = "Pricing configuration deactivated successfully"
            });
        }
    }
}
