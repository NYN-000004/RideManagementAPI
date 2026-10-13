using System.ComponentModel.DataAnnotations;

public class Ride
{
    public int Id { get; set; }

    [Required]
    public string PickupLocation { get; set; }

    [Required]
    public string DropLocation { get; set; }

    [Required]
    public DateTime RideTime { get; set; }

    [Range(1, 10)]
    public int AvailableSeats { get; set; }

    [Range(1, 10000)]
    public int Price { get; set; }   // ✅ FIXED

    public int Status { get; set; }
}