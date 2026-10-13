using System.ComponentModel.DataAnnotations;

namespace RideManagementAPI.Models
{
    public class Payment
    {
        public int Id { get; set; }

        [Required]
        public int RideId { get; set; }

        [Required]
        public decimal Amount { get; set; }

        [Required]
        public string PaymentMethod { get; set; } = "";

        [Required]
        public string PaymentStatus { get; set; } = "Pending";

        public string TransactionId { get; set; } = "";

        public DateTime PaymentDate { get; set; } = DateTime.UtcNow;
    }
}