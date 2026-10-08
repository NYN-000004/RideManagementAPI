using Nikhy_demo.Enums;

namespace Nikhy_demo.DTOs
{
    public class RideHistoryResponse
    {
        public long RideId { get; set; }

        public string PickupLocation { get; set; } = string.Empty;

        public string DestinationLocation { get; set; } = string.Empty;

        public RideStatus Status { get; set; }

        public decimal Fare { get; set; }

        public DateTime RequestedAt { get; set; }

        public DateTime? CompletedAt { get; set; }

        public DateTime? CancelledAt { get; set; }
    }
}