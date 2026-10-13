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
    public class RiderController : ControllerBase
    {
        private readonly AppDbContext _context;

        public RiderController(AppDbContext context)
        {
            _context = context;
        }

        // GET: api/Rider
        [HttpGet]
        public async Task<IActionResult> GetRiders()
        {
            var riders = await _context.Riders.ToListAsync();
            return Ok(riders);
        }

        // GET: api/Rider/1
        [HttpGet("{id}")]
        public async Task<IActionResult> GetRider(int id)
        {
            var rider = await _context.Riders.FindAsync(id);

            if (rider == null)
                return NotFound(new { message = "Rider not found" });

            return Ok(rider);
        }

        // POST: api/Rider
        [HttpPost]
        public async Task<IActionResult> CreateRider(Rider rider)
        {
            _context.Riders.Add(rider);
            await _context.SaveChangesAsync();

            return Ok(rider);
        }

        // PUT: api/Rider/1
        [HttpPut("{id}")]
        public async Task<IActionResult> UpdateRider(int id, Rider rider)
        {
            if (id != rider.Id)
                return BadRequest(new { message = "ID mismatch" });

            var existingRider = await _context.Riders.FindAsync(id);

            if (existingRider == null)
                return NotFound(new { message = "Rider not found" });

            existingRider.Name = rider.Name;
            existingRider.Email = rider.Email;
            existingRider.Phone = rider.Phone;
            existingRider.VehicleNumber = rider.VehicleNumber;
            existingRider.LicenseNumber = rider.LicenseNumber;
            existingRider.ApprovalStatus = rider.ApprovalStatus;
            existingRider.IsActive = rider.IsActive;

            await _context.SaveChangesAsync();

            return Ok(existingRider);
        }

        // DELETE: api/Rider/1
        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteRider(int id)
        {
            var rider = await _context.Riders.FindAsync(id);

            if (rider == null)
                return NotFound(new { message = "Rider not found" });

            _context.Riders.Remove(rider);
            await _context.SaveChangesAsync();

            return Ok(new
            {
                message = "Rider deleted successfully"
            });
        }

        // PUT: api/Rider/approve/1
        [HttpPut("approve/{id}")]
        public async Task<IActionResult> ApproveRider(int id)
        {
            var rider = await _context.Riders.FindAsync(id);

            if (rider == null)
                return NotFound(new { message = "Rider not found" });

            rider.ApprovalStatus = "Approved";
            rider.IsActive = true;

            await _context.SaveChangesAsync();

            return Ok(new
            {
                message = "Rider approved successfully",
                rider
            });
        }

        // PUT: api/Rider/reject/1
        [HttpPut("reject/{id}")]
        public async Task<IActionResult> RejectRider(int id)
        {
            var rider = await _context.Riders.FindAsync(id);

            if (rider == null)
                return NotFound(new { message = "Rider not found" });

            rider.ApprovalStatus = "Rejected";
            rider.IsActive = false;

            await _context.SaveChangesAsync();

            return Ok(new
            {
                message = "Rider rejected successfully",
                rider
            });
        }

        // PUT: api/Rider/document-approve/1
        [HttpPut("document-approve/{id}")]
        public async Task<IActionResult> ApproveDocument(int id)
        {
            var rider = await _context.Riders.FindAsync(id);

            if (rider == null)
                return NotFound(new { message = "Rider not found" });

            rider.DocumentApprovalStatus = "Approved";

            await _context.SaveChangesAsync();

            return Ok(new
            {
                message = "Rider document approved successfully",
                rider
            });
        }

        // PUT: api/Rider/document-reject/1
        [HttpPut("document-reject/{id}")]
        public async Task<IActionResult> RejectDocument(int id)
        {
            var rider = await _context.Riders.FindAsync(id);

            if (rider == null)
                return NotFound(new { message = "Rider not found" });

            rider.DocumentApprovalStatus = "Rejected";

            await _context.SaveChangesAsync();

            return Ok(new
            {
                message = "Rider document rejected successfully",
                rider
            });
        }
    }
}