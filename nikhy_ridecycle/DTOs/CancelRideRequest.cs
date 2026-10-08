using System.ComponentModel.DataAnnotations;

namespace Nikhy_demo.DTOs
{
    public class CancelRideRequest
    {
        [Required]
        [MaxLength(500)]
        public string Reason { get; set; } = string.Empty;

        [Required]
        [MaxLength(50)]
        public string CancelledBy { get; set; } = string.Empty;
    }
}