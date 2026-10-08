using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Nikhy_demo.Enums;

namespace Nikhy_demo.Models
{
    public class Ride
    {
        [Key]
        public long RideId { get; set; }

        public long? BookingId { get; set; }

        [Required]
        public long PassengerId { get; set; }

        public long? DriverId { get; set; }

        [Required]
        [MaxLength(200)]
        public string PickupLocation { get; set; } = string.Empty;

        [Required]
        [MaxLength(200)]
        public string DestinationLocation { get; set; } = string.Empty;

        [Column(TypeName = "numeric(10,7)")]
        public decimal PickupLatitude { get; set; }

        [Column(TypeName = "numeric(10,7)")]
        public decimal PickupLongitude { get; set; }

        [Column(TypeName = "numeric(10,7)")]
        public decimal DestinationLatitude { get; set; }

        [Column(TypeName = "numeric(10,7)")]
        public decimal DestinationLongitude { get; set; }

        [Required]
        public RideStatus Status { get; set; } = RideStatus.REQUESTED;

        [Column(TypeName = "numeric(10,2)")]
        public decimal Fare { get; set; }

        [Column(TypeName = "numeric(10,2)")]
        public decimal? Distance { get; set; }

        public int? EstimatedDuration { get; set; }

        public DateTime RequestedAt { get; set; }

        public DateTime? AcceptedAt { get; set; }

        public DateTime? StartedAt { get; set; }

        public DateTime? CompletedAt { get; set; }

        public DateTime? CancelledAt { get; set; }

        [MaxLength(500)]
        public string? CancellationReason { get; set; }

        [MaxLength(50)]
        public string? CancelledBy { get; set; }

        public DateTime CreatedAt { get; set; }

        public DateTime UpdatedAt { get; set; }
    }
}