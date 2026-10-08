using System.ComponentModel.DataAnnotations;

namespace Nikhy_demo.DTOs
{
    public class CreateRideRequest
    {
        public long? BookingId { get; set; }

        [Required]
        public long PassengerId { get; set; }

        [Required]
        [MaxLength(200)]
        public string PickupLocation { get; set; } = string.Empty;

        [Required]
        [MaxLength(200)]
        public string DestinationLocation { get; set; } = string.Empty;

        [Range(-90, 90)]
        public decimal PickupLatitude { get; set; }

        [Range(-180, 180)]
        public decimal PickupLongitude { get; set; }

        [Range(-90, 90)]
        public decimal DestinationLatitude { get; set; }

        [Range(-180, 180)]
        public decimal DestinationLongitude { get; set; }

        [Range(0, double.MaxValue)]
        public decimal Fare { get; set; }

        [Range(0, double.MaxValue)]
        public decimal? Distance { get; set; }

        [Range(1, int.MaxValue)]
        public int? EstimatedDuration { get; set; }
    }
}