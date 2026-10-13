using System;

namespace RideManagementAPI.Models
{
    public class AuditLog
    {
        public int Id { get; set; }

        public string Action { get; set; } = "";

        public string EntityName { get; set; } = "";

        public int EntityId { get; set; }

        public string PerformedBy { get; set; } = "";

        public DateTime PerformedAt { get; set; } = DateTime.UtcNow;

        public string Description { get; set; } = "";
    }
}