namespace RideManagementAPI.Models
{
    public class Admin
    {
        public int Id { get; set; }

        public string Username { get; set; } = "";   // ✅ fix error

        public string Password { get; set; } = "";   // ✅ fix error
    }
}