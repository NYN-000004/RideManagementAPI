using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using RideManagementAPI.Data;
using RideManagementAPI.Models;

namespace RideManagementAPI.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class ReportController : ControllerBase
    {
        private readonly AppDbContext _context;

        public ReportController(AppDbContext context)
        {
            _context = context;
        }

        // GET: api/Report
        [HttpGet]
        public async Task<IActionResult> GetReports()
        {
            var reports = await _context.Reports.ToListAsync();
            return Ok(reports);
        }

        // GET: api/Report/1
        [HttpGet("{id}")]
        public async Task<IActionResult> GetReport(int id)
        {
            var report = await _context.Reports.FindAsync(id);

            if (report == null)
                return NotFound(new { message = "Report not found" });

            return Ok(report);
        }

        // POST: api/Report
        [HttpPost]
        public async Task<IActionResult> CreateReport(Report report)
        {
            _context.Reports.Add(report);
            await _context.SaveChangesAsync();

            return Ok(report);
        }

        // PUT: api/Report/1
        [HttpPut("{id}")]
        public async Task<IActionResult> UpdateReport(int id, Report report)
        {
            if (id != report.Id)
                return BadRequest();

            _context.Entry(report).State = EntityState.Modified;
            await _context.SaveChangesAsync();

            return Ok(report);
        }

        // DELETE: api/Report/1
        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteReport(int id)
        {
            var report = await _context.Reports.FindAsync(id);

            if (report == null)
                return NotFound(new { message = "Report not found" });

            _context.Reports.Remove(report);
            await _context.SaveChangesAsync();

            return Ok(new
            {
                message = "Report deleted successfully"
            });
        }
    }
}