using System.ComponentModel.DataAnnotations;

namespace RideManagementAPI.Models
{
    public class PricingConfiguration
    {
        public int Id { get; set; }

        [Range(0, 100000)]
        public decimal BaseFare { get; set; }

        [Range(0, 100000)]
        public decimal PerKilometreFare { get; set; }

        [Range(0, 100000)]
        public decimal TimeFare { get; set; }

        [Range(0, 100000)]
        public decimal MinimumFare { get; set; }

        [Range(0, 100000)]
        public decimal PlatformFee { get; set; }

        public bool IsActive { get; set; } = true;
    }
}
