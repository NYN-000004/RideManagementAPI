using System;

namespace RideManagementAPI.Models
{
    public class OperationalData
    {
        public int Id { get; set; }

        public string MetricName { get; set; } = "";

        public string Value { get; set; } = "";

        public string Description { get; set; } = "";

        public DateTime RecordedDate { get; set; } = DateTime.UtcNow;
    }
}