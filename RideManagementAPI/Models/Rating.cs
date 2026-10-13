using System;

namespace RideManagementAPI.Models
{
    public class Rating
    {
        public int Id { get; set; }

        public int RideId { get; set; }

        public int RiderId { get; set; }

        public int RatingValue { get; set; }

        public string Feedback { get; set; } = "";

        public DateTime CreatedDate { get; set; } = DateTime.UtcNow;
    }
}