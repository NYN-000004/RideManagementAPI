using Microsoft.AspNetCore.Mvc;
using Microsoft.IdentityModel.Tokens;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;

namespace RideManagementAPI.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class AdminController : ControllerBase
    {
        // SAME KEY USED IN Program.cs
        private readonly string _jwtKey;

        public AdminController(IConfiguration configuration)
        {
            _jwtKey = configuration["Jwt:Key"]
                ?? throw new InvalidOperationException("JWT key is not configured");
        }

        

        private const string JwtIssuer = "RideApp";
        private const string JwtAudience = "RideUsers";

        [HttpPost("login")]
        public IActionResult Login([FromBody] LoginRequest request)
        {
            // Check login
            if (request.Username != "admin" ||
                request.Password != "1234")
            {
                return Unauthorized(new
                {
                    message = "Invalid username or password"
                });
            }

            // Security key
            var securityKey = new SymmetricSecurityKey(
                Encoding.UTF8.GetBytes(_jwtKey)
            );

            var credentials = new SigningCredentials(
                securityKey,
                SecurityAlgorithms.HmacSha256
            );

            // Claims
            var claims = new[]
            {
                new Claim(ClaimTypes.Name, request.Username),
                new Claim(ClaimTypes.Role, "Admin")
            };

            // Create token
            var token = new JwtSecurityToken(
                issuer: JwtIssuer,
                audience: JwtAudience,
                claims: claims,
                expires: DateTime.UtcNow.AddHours(2),
                signingCredentials: credentials
            );

            var tokenString =
                new JwtSecurityTokenHandler().WriteToken(token);

            return Ok(new
            {
                token = tokenString
            });
        }
    }

    public class LoginRequest
    {
        public string Username { get; set; } = "";
        public string Password { get; set; } = "";
    }
}