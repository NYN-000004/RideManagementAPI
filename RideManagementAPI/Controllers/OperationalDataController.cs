using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using RideManagementAPI.Data;
using RideManagementAPI.Models;

namespace RideManagementAPI.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class OperationalDataController : ControllerBase
    {
        private readonly AppDbContext _context;

        public OperationalDataController(AppDbContext context)
        {
            _context = context;
        }

        // GET: api/OperationalData
        [HttpGet]
        public async Task<IActionResult> GetAll()
        {
            var data = await _context.OperationalData.ToListAsync();
            return Ok(data);
        }

        // GET: api/OperationalData/1
        [HttpGet("{id}")]
        public async Task<IActionResult> GetById(int id)
        {
            var data = await _context.OperationalData.FindAsync(id);

            if (data == null)
                return NotFound(new { message = "Operational data not found" });

            return Ok(data);
        }

        // POST: api/OperationalData
        [HttpPost]
        public async Task<IActionResult> Create(OperationalData data)
        {
            _context.OperationalData.Add(data);
            await _context.SaveChangesAsync();

            return Ok(data);
        }

        // PUT: api/OperationalData/1
        [HttpPut("{id}")]
        public async Task<IActionResult> Update(int id, OperationalData data)
        {
            if (id != data.Id)
                return BadRequest();

            var existingData = await _context.OperationalData.FindAsync(id);

            if (existingData == null)
                return NotFound(new { message = "Operational data not found" });

            existingData.MetricName = data.MetricName;
            existingData.Value = data.Value;
            existingData.Description = data.Description;

            await _context.SaveChangesAsync();

            return Ok(existingData);
        }

        // DELETE: api/OperationalData/1
        [HttpDelete("{id}")]
        public async Task<IActionResult> Delete(int id)
        {
            var data = await _context.OperationalData.FindAsync(id);

            if (data == null)
                return NotFound(new { message = "Operational data not found" });

            _context.OperationalData.Remove(data);
            await _context.SaveChangesAsync();

            return Ok(new { message = "Operational data deleted successfully" });
        }
    }
}