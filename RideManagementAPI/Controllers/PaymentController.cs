using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using RideManagementAPI.Data;
using RideManagementAPI.Models;

namespace RideManagementAPI.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class PaymentController : ControllerBase
    {
        private readonly AppDbContext _context;

        public PaymentController(AppDbContext context)
        {
            _context = context;
        }

        // GET: api/Payment
        [HttpGet]
        public async Task<IActionResult> GetPayments()
        {
            var payments = await _context.Payments.ToListAsync();
            return Ok(payments);
        }

        // GET: api/Payment/1
        [HttpGet("{id}")]
        public async Task<IActionResult> GetPayment(int id)
        {
            var payment = await _context.Payments.FindAsync(id);

            if (payment == null)
                return NotFound(new { message = "Payment not found" });

            return Ok(payment);
        }

        // POST: api/Payment
        [HttpPost]
        public async Task<IActionResult> CreatePayment(Payment payment)
        {
            _context.Payments.Add(payment);
            await _context.SaveChangesAsync();

            return Ok(payment);
        }

        // PUT: api/Payment/1
        [HttpPut("{id}")]
        public async Task<IActionResult> UpdatePayment(
            int id,
            Payment payment)
        {
            if (id != payment.Id)
                return BadRequest();

            _context.Entry(payment).State = EntityState.Modified;
            await _context.SaveChangesAsync();

            return Ok(payment);
        }

        // DELETE: api/Payment/1
        [HttpDelete("{id}")]
        public async Task<IActionResult> DeletePayment(int id)
        {
            var payment = await _context.Payments.FindAsync(id);

            if (payment == null)
                return NotFound(new { message = "Payment not found" });

            _context.Payments.Remove(payment);
            await _context.SaveChangesAsync();

            return Ok(new
            {
                message = "Payment deleted successfully"
            });
        }
    }
}