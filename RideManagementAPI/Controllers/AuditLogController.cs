using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using RideManagementAPI.Data;
using RideManagementAPI.Models;

namespace RideManagementAPI.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class AuditLogController : ControllerBase
    {
        private readonly AppDbContext _context;

        public AuditLogController(AppDbContext context)
        {
            _context = context;
        }

        // GET: api/AuditLog
        [HttpGet]
        public async Task<IActionResult> GetAuditLogs()
        {
            var logs = await _context.AuditLogs.ToListAsync();
            return Ok(logs);
        }

        // GET: api/AuditLog/1
        [HttpGet("{id}")]
        public async Task<IActionResult> GetAuditLog(int id)
        {
            var log = await _context.AuditLogs.FindAsync(id);

            if (log == null)
                return NotFound(new { message = "Audit log not found" });

            return Ok(log);
        }

        // POST: api/AuditLog
        [HttpPost]
        public async Task<IActionResult> CreateAuditLog(AuditLog auditLog)
        {
            _context.AuditLogs.Add(auditLog);
            await _context.SaveChangesAsync();

            return Ok(auditLog);
        }

        // PUT: api/AuditLog/1
        [HttpPut("{id}")]
        public async Task<IActionResult> UpdateAuditLog(int id, AuditLog auditLog)
        {
            if (id != auditLog.Id)
                return BadRequest();

            _context.Entry(auditLog).State = EntityState.Modified;
            await _context.SaveChangesAsync();

            return Ok(auditLog);
        }

        // DELETE: api/AuditLog/1
        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteAuditLog(int id)
        {
            var log = await _context.AuditLogs.FindAsync(id);

            if (log == null)
                return NotFound(new { message = "Audit log not found" });

            _context.AuditLogs.Remove(log);
            await _context.SaveChangesAsync();

            return Ok(new
            {
                message = "Audit log deleted successfully"
            });
        }
    }
}