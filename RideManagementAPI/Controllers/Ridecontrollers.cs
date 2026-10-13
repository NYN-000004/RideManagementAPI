using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.AspNetCore.Authorization;
using RideManagementAPI.Data;
using RideManagementAPI.Models;

namespace RideManagementAPI.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class RideController : ControllerBase
    {
        private readonly AppDbContext _context;

        public RideController(AppDbContext context)
        {
            _context = context;
        }

        // 🔒 GET all rides
        [Authorize]
        [HttpGet]
        public async Task<IActionResult> GetRides()
        {
            var rides = await _context.Rides.ToListAsync();

            return Ok(rides);
        }

        // 🔒 GET ride by ID
        [Authorize]
        [HttpGet("{id}")]
        public async Task<IActionResult> GetRide(int id)
        {
            var ride = await _context.Rides.FindAsync(id);

            if (ride == null)
                return NotFound();

            return Ok(ride);
        }

        // 🔒 ADMIN - RIDE MONITORING
        [Authorize]
        [HttpGet("monitoring")]
        public async Task<IActionResult> MonitorRides()
        {
            var rides = await _context.Rides
                .OrderByDescending(r => r.RideTime)
                .ToListAsync();

            return Ok(rides);
        }

        // ➕ CREATE ride
        [HttpPost]
        public async Task<IActionResult> CreateRide(Ride ride)
        {
            _context.Rides.Add(ride);
            await _context.SaveChangesAsync();

            return Ok(ride);
        }

        // ✏ UPDATE ride
        [HttpPut("{id}")]
        public async Task<IActionResult> UpdateRide(int id, Ride ride)
        {
            if (id != ride.Id)
                return BadRequest();

            _context.Entry(ride).State = EntityState.Modified;

            await _context.SaveChangesAsync();

            return Ok(ride);
        }

        // ❌ DELETE ride
        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteRide(int id)
        {
            var ride = await _context.Rides.FindAsync(id);

            if (ride == null)
                return NotFound();

            _context.Rides.Remove(ride);

            await _context.SaveChangesAsync();

            return Ok(new
            {
                message = "Deleted successfully"
            });
        }
    }
}