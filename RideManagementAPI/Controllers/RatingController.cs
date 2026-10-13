using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using RideManagementAPI.Data;
using RideManagementAPI.Models;

namespace RideManagementAPI.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class RatingController : ControllerBase
    {
        private readonly AppDbContext _context;

        public RatingController(AppDbContext context)
        {
            _context = context;
        }

        // GET: api/Rating
        [HttpGet]
        public async Task<IActionResult> GetRatings()
        {
            var ratings = await _context.Ratings.ToListAsync();
            return Ok(ratings);
        }

        // GET: api/Rating/1
        [HttpGet("{id}")]
        public async Task<IActionResult> GetRating(int id)
        {
            var rating = await _context.Ratings.FindAsync(id);

            if (rating == null)
                return NotFound(new { message = "Rating not found" });

            return Ok(rating);
        }

        // POST: api/Rating
        [HttpPost]
        public async Task<IActionResult> CreateRating(Rating rating)
        {
            _context.Ratings.Add(rating);
            await _context.SaveChangesAsync();

            return Ok(rating);
        }

        // PUT: api/Rating/1
        [HttpPut("{id}")]
        public async Task<IActionResult> UpdateRating(int id, Rating rating)
        {
            if (id != rating.Id)
                return BadRequest();

            _context.Entry(rating).State = EntityState.Modified;
            await _context.SaveChangesAsync();

            return Ok(rating);
        }

        // DELETE: api/Rating/1
        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteRating(int id)
        {
            var rating = await _context.Ratings.FindAsync(id);

            if (rating == null)
                return NotFound(new { message = "Rating not found" });

            _context.Ratings.Remove(rating);
            await _context.SaveChangesAsync();

            return Ok(new
            {
                message = "Rating deleted successfully"
            });
        }
    }
}