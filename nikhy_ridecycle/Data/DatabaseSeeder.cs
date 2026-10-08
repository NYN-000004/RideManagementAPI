using Microsoft.EntityFrameworkCore;
using Nikhy_demo.Enums;
using Nikhy_demo.Models;

namespace Nikhy_demo.Data
{
    public static class DatabaseSeeder
    {
        public static async Task SeedAsync(ApplicationDbContext context)
        {
            // Apply migrations automatically if needed
            await context.Database.MigrateAsync();

            // If data already exists, skip seeding
            if (await context.Rides.AnyAsync())
            {
                return;
            }

            var now = DateTime.UtcNow;

            var demoRides = new List<Ride>
            {
                // 1. REQUESTED - Newly booked ride, waiting for matching
                new Ride
                {
                    BookingId = 1001,
                    PassengerId = 101,
                    DriverId = null,
                    PickupLocation = "Connaught Place, New Delhi",
                    DestinationLocation = "IGI Airport Terminal 3, New Delhi",
                    PickupLatitude = 28.6315m,
                    PickupLongitude = 77.2167m,
                    DestinationLatitude = 28.5562m,
                    DestinationLongitude = 77.1000m,
                    Status = RideStatus.REQUESTED,
                    Fare = 450.00m,
                    Distance = 15.20m,
                    EstimatedDuration = 35,
                    RequestedAt = now.AddMinutes(-5),
                    CreatedAt = now.AddMinutes(-5),
                    UpdatedAt = now.AddMinutes(-5)
                },

                // 2. SEARCHING - System searching for nearby available drivers
                new Ride
                {
                    BookingId = 1002,
                    PassengerId = 102,
                    DriverId = null,
                    PickupLocation = "Cyber Hub, DLF Phase 2, Gurugram",
                    DestinationLocation = "Sector 29 Market, Gurugram",
                    PickupLatitude = 28.4950m,
                    PickupLongitude = 77.0890m,
                    DestinationLatitude = 28.4680m,
                    DestinationLongitude = 77.0620m,
                    Status = RideStatus.SEARCHING,
                    Fare = 180.00m,
                    Distance = 6.50m,
                    EstimatedDuration = 18,
                    RequestedAt = now.AddMinutes(-4),
                    CreatedAt = now.AddMinutes(-4),
                    UpdatedAt = now.AddMinutes(-3)
                },

                // 3. ACCEPTED - Driver accepted the ride request
                new Ride
                {
                    BookingId = 1003,
                    PassengerId = 103,
                    DriverId = 201,
                    PickupLocation = "Hauz Khas Village, New Delhi",
                    DestinationLocation = "Select Citywalk, Saket, New Delhi",
                    PickupLatitude = 28.5535m,
                    PickupLongitude = 77.1944m,
                    DestinationLatitude = 28.5284m,
                    DestinationLongitude = 77.2192m,
                    Status = RideStatus.ACCEPTED,
                    Fare = 210.00m,
                    Distance = 7.80m,
                    EstimatedDuration = 22,
                    RequestedAt = now.AddMinutes(-10),
                    AcceptedAt = now.AddMinutes(-8),
                    CreatedAt = now.AddMinutes(-10),
                    UpdatedAt = now.AddMinutes(-8)
                },

                // 4. RIDER_ARRIVING - Driver is en route to pickup point
                new Ride
                {
                    BookingId = 1004,
                    PassengerId = 104,
                    DriverId = 202,
                    PickupLocation = "Bandra Kurla Complex (BKC), Mumbai",
                    DestinationLocation = "Chhatrapati Shivaji Maharaj Terminus (CSMT), Mumbai",
                    PickupLatitude = 19.0657m,
                    PickupLongitude = 72.8687m,
                    DestinationLatitude = 18.9401m,
                    DestinationLongitude = 72.8347m,
                    Status = RideStatus.RIDER_ARRIVING,
                    Fare = 380.00m,
                    Distance = 16.00m,
                    EstimatedDuration = 40,
                    RequestedAt = now.AddMinutes(-15),
                    AcceptedAt = now.AddMinutes(-12),
                    CreatedAt = now.AddMinutes(-15),
                    UpdatedAt = now.AddMinutes(-10)
                },

                // 5. ARRIVED - Driver reached the passenger pickup spot
                new Ride
                {
                    BookingId = 1005,
                    PassengerId = 105,
                    DriverId = 203,
                    PickupLocation = "MG Road Metro Station, Bengaluru",
                    DestinationLocation = "Indiranagar 100 Feet Road, Bengaluru",
                    PickupLatitude = 12.9756m,
                    PickupLongitude = 77.6066m,
                    DestinationLatitude = 12.9784m,
                    DestinationLongitude = 77.6408m,
                    Status = RideStatus.ARRIVED,
                    Fare = 160.00m,
                    Distance = 4.80m,
                    EstimatedDuration = 15,
                    RequestedAt = now.AddMinutes(-20),
                    AcceptedAt = now.AddMinutes(-18),
                    CreatedAt = now.AddMinutes(-20),
                    UpdatedAt = now.AddMinutes(-5)
                },

                // 6. STARTED - Trip currently underway
                new Ride
                {
                    BookingId = 1006,
                    PassengerId = 106,
                    DriverId = 204,
                    PickupLocation = "Koramangala 5th Block, Bengaluru",
                    DestinationLocation = "ITPL Main Gate, Whitefield, Bengaluru",
                    PickupLatitude = 12.9352m,
                    PickupLongitude = 77.6245m,
                    DestinationLatitude = 12.9856m,
                    DestinationLongitude = 77.7314m,
                    Status = RideStatus.STARTED,
                    Fare = 520.00m,
                    Distance = 19.50m,
                    EstimatedDuration = 50,
                    RequestedAt = now.AddMinutes(-35),
                    AcceptedAt = now.AddMinutes(-30),
                    StartedAt = now.AddMinutes(-20),
                    CreatedAt = now.AddMinutes(-35),
                    UpdatedAt = now.AddMinutes(-20)
                },

                // 7. COMPLETED - Trip successfully ended
                new Ride
                {
                    BookingId = 1007,
                    PassengerId = 107,
                    DriverId = 205,
                    PickupLocation = "Hitec City Cyber Towers, Hyderabad",
                    DestinationLocation = "Rajiv Gandhi International Airport, Hyderabad",
                    PickupLatitude = 17.4504m,
                    PickupLongitude = 78.3808m,
                    DestinationLatitude = 17.2403m,
                    DestinationLongitude = 78.4294m,
                    Status = RideStatus.COMPLETED,
                    Fare = 750.00m,
                    Distance = 32.40m,
                    EstimatedDuration = 45,
                    RequestedAt = now.AddHours(-2),
                    AcceptedAt = now.AddHours(-2).AddMinutes(2),
                    StartedAt = now.AddHours(-2).AddMinutes(10),
                    CompletedAt = now.AddHours(-1).AddMinutes(15),
                    CreatedAt = now.AddHours(-2),
                    UpdatedAt = now.AddHours(-1).AddMinutes(15)
                },

                // 8. CANCELLED - Cancelled by passenger before pickup
                new Ride
                {
                    BookingId = 1008,
                    PassengerId = 108,
                    DriverId = null,
                    PickupLocation = "Salt Lake Sector V, Kolkata",
                    DestinationLocation = "Park Street, Kolkata",
                    PickupLatitude = 22.5804m,
                    PickupLongitude = 88.4378m,
                    DestinationLatitude = 22.5516m,
                    DestinationLongitude = 88.3524m,
                    Status = RideStatus.CANCELLED,
                    Fare = 290.00m,
                    Distance = 11.20m,
                    EstimatedDuration = 30,
                    RequestedAt = now.AddMinutes(-45),
                    CancelledAt = now.AddMinutes(-40),
                    CancellationReason = "Passenger cancelled: Wait time was too long",
                    CancelledBy = "Passenger",
                    CreatedAt = now.AddMinutes(-45),
                    UpdatedAt = now.AddMinutes(-40)
                }
            };

            await context.Rides.AddRangeAsync(demoRides);
            await context.SaveChangesAsync();
        }
    }
}
