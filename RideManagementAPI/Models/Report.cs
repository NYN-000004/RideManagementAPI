using System;

namespace RideManagementAPI.Models
{
    public class Report
    {
        public int Id { get; set; }

        public string ReportType { get; set; } = "";

        public string Description { get; set; } = "";

        public DateTime GeneratedDate { get; set; } = DateTime.UtcNow;

        public string Data { get; set; } = "";
    }
}