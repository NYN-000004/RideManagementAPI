using System.ComponentModel.DataAnnotations;
using Nikhy_demo.Enums;

namespace Nikhy_demo.DTOs
{
    public class UpdateRideStatusRequest
    {
        [Required]
        public RideStatus Status { get; set; }
    }
}