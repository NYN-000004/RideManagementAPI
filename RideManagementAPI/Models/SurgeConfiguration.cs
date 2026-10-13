using System.ComponentModel.DataAnnotations;

namespace RideManagementAPI.Models
{
    public class SurgeConfiguration
    {
        public int Id { get; set; }

        [Required]
        public string Area { get; set; } = "";

        [Range(1, 10)]
        public decimal SurgeMultiplier { get; set; }

        public bool IsActive { get; set; } = true;
    }
}