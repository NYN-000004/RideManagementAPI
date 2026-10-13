using System.ComponentModel.DataAnnotations;

namespace RideManagementAPI.Models
{
    public class Rider
    {
        public int Id { get; set; }

        [Required]
        public string Name { get; set; } = "";

        [Required]
        public string Email { get; set; } = "";

        [Required]
        public string Phone { get; set; } = "";

        public string VehicleNumber { get; set; } = "";

        public string LicenseNumber { get; set; } = "";

        // Rider Approval
        public string ApprovalStatus { get; set; } = "Pending";

        // Document Approval
        public string DocumentApprovalStatus { get; set; } = "Pending";

        public bool IsActive { get; set; } = true;
    }
}