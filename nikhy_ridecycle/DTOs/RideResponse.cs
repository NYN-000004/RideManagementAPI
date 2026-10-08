using Nikhy_demo.Enums;

namespace Nikhy_demo.DTOs
{
    public class RideResponse
    {
        public long RideId { get; set; }

        public long? BookingId { get; set; }

        public long PassengerId { get; set; }

        public long? DriverId { get; set; }

        public string PickupLocation { get; set; } = string.Empty;

        public string DestinationLocation { get; set; } = string.Empty;

        public decimal PickupLatitude { get; set; }

        public decimal PickupLongitude { get; set; }

        public decimal DestinationLatitude { get; set; }

        public decimal DestinationLongitude { get; set; }

        public string Status { get; set; } = string.Empty;

        public decimal Fare { get; set; }

        public decimal? Distance { get; set; }

        public int? EstimatedDuration { get; set; }

        public DateTime RequestedAt { get; set; }

        public DateTime? AcceptedAt { get; set; }

        public DateTime? StartedAt { get; set; }

        public DateTime? CompletedAt { get; set; }

        public DateTime? CancelledAt { get; set; }

        public string? CancellationReason { get; set; }

        public string? CancelledBy { get; set; }

        public DateTime CreatedAt { get; set; }

        public DateTime UpdatedAt { get; set; }
    }
}