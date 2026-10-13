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
    public class CustomerController : ControllerBase
    {
        private readonly AppDbContext _context;

        public CustomerController(AppDbContext context)
        {
            _context = context;
        }

        // GET: api/Customer
        [HttpGet]
        public async Task<IActionResult> GetCustomers()
        {
            var customers = await _context.Customers.ToListAsync();
            return Ok(customers);
        }

        // GET: api/Customer/1
        [HttpGet("{id}")]
        public async Task<IActionResult> GetCustomer(int id)
        {
            var customer = await _context.Customers.FindAsync(id);

            if (customer == null)
                return NotFound(new { message = "Customer not found" });

            return Ok(customer);
        }

        // POST: api/Customer
        [HttpPost]
        public async Task<IActionResult> CreateCustomer(Customer customer)
        {
            _context.Customers.Add(customer);
            await _context.SaveChangesAsync();

            return Ok(customer);
        }

        // PUT: api/Customer/1
        [HttpPut("{id}")]
        public async Task<IActionResult> UpdateCustomer(
            int id,
            Customer customer)
        {
            if (id != customer.Id)
                return BadRequest(new { message = "ID mismatch" });

            var existingCustomer =
                await _context.Customers.FindAsync(id);

            if (existingCustomer == null)
                return NotFound(new { message = "Customer not found" });

            existingCustomer.Name = customer.Name;
            existingCustomer.Email = customer.Email;
            existingCustomer.Phone = customer.Phone;
            existingCustomer.IsActive = customer.IsActive;

            await _context.SaveChangesAsync();

            return Ok(existingCustomer);
        }

        // DELETE: api/Customer/1
        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteCustomer(int id)
        {
            var customer =
                await _context.Customers.FindAsync(id);

            if (customer == null)
                return NotFound(new { message = "Customer not found" });

            _context.Customers.Remove(customer);
            await _context.SaveChangesAsync();

            return Ok(new { message = "Customer deleted successfully" });
        }
    }
}