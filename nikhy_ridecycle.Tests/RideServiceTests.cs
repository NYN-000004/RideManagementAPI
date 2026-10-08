using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging.Abstractions;
using Nikhy_demo.Data;
using Nikhy_demo.DTOs;
using Nikhy_demo.Enums;
using Nikhy_demo.Services;
using Xunit;

namespace nikhy_ridecycle.Tests
{
    public class RideServiceTests
    {
        private ApplicationDbContext CreateInMemoryDbContext()
        {
            var options = new DbContextOptionsBuilder<ApplicationDbContext>()
                .UseInMemoryDatabase(databaseName: Guid.NewGuid().ToString())
                .Options;

            return new ApplicationDbContext(options);
        }

        private RideService CreateService(ApplicationDbContext context)
        {
            return new RideService(context);
        }

        [Fact]
        public async Task CreateRideAsync_ValidRequest_CreatesRideInSearchingState()
        {
            using var context = CreateInMemoryDbContext();
            var service = CreateService(context);

            var request = new CreateRideRequest
            {
                PassengerId = 101,
                PickupLocation = "Hitec City Cyber Towers, Hyderabad",
                DestinationLocation = "RGIA Airport, Hyderabad",
                PickupLatitude = 17.4504m,
                PickupLongitude = 78.3808m,
                DestinationLatitude = 17.2403m,
                DestinationLongitude = 78.4294m,
                Fare = 750.00m,
                Distance = 32.5m,
                EstimatedDuration = 45
            };

            var result = await service.CreateRideAsync(request);

            Assert.NotNull(result);
            Assert.Equal("SEARCHING", result.Status);
            Assert.Equal(101, result.PassengerId);
            Assert.Equal(750.00m, result.Fare);
            Assert.True(result.RequestedAt > DateTime.MinValue);
        }

        [Theory]
        [InlineData(95.0, 78.0, 17.0, 78.0)]
        [InlineData(-95.0, 78.0, 17.0, 78.0)]
        [InlineData(17.0, 185.0, 17.0, 78.0)]
        [InlineData(17.0, -185.0, 17.0, 78.0)]
        [InlineData(17.0, 78.0, 95.0, 78.0)]
        [InlineData(17.0, 78.0, 17.0, 185.0)]
        public async Task CreateRideAsync_InvalidCoordinates_ThrowsArgumentException(
            decimal pLat, decimal pLng, decimal dLat, decimal dLng)
        {
            using var context = CreateInMemoryDbContext();
            var service = CreateService(context);

            var request = new CreateRideRequest
            {
                PassengerId = 101,
                PickupLocation = "Location A",
                DestinationLocation = "Location B",
                PickupLatitude = pLat,
                PickupLongitude = pLng,
                DestinationLatitude = dLat,
                DestinationLongitude = dLng
            };

            await Assert.ThrowsAsync<ArgumentException>(() => service.CreateRideAsync(request));
        }

        [Fact]
        public async Task AcceptRideAsync_ValidDriver_TransitionsToAccepted()
        {
            using var context = CreateInMemoryDbContext();
            var service = CreateService(context);

            var created = await service.CreateRideAsync(new CreateRideRequest
            {
                PassengerId = 101,
                PickupLocation = "A",
                DestinationLocation = "B",
                PickupLatitude = 17.44m,
                PickupLongitude = 78.37m,
                DestinationLatitude = 17.24m,
                DestinationLongitude = 78.42m
            });

            var accepted = await service.AcceptRideAsync(created.RideId, 201);

            Assert.Equal("ACCEPTED", accepted.Status);
            Assert.Equal(201, accepted.DriverId);
            Assert.NotNull(accepted.AcceptedAt);
        }

        [Fact]
        public async Task AcceptRideAsync_SecondDriverAccepts_ThrowsInvalidOperationException()
        {
            using var context = CreateInMemoryDbContext();
            var service = CreateService(context);

            var created = await service.CreateRideAsync(new CreateRideRequest
            {
                PassengerId = 101,
                PickupLocation = "A",
                DestinationLocation = "B",
                PickupLatitude = 17.44m,
                PickupLongitude = 78.37m,
                DestinationLatitude = 17.24m,
                DestinationLongitude = 78.42m
            });

            await service.AcceptRideAsync(created.RideId, 201);

            await Assert.ThrowsAsync<InvalidOperationException>(() =>
                service.AcceptRideAsync(created.RideId, 202));
        }

        [Fact]
        public async Task RideLifecycle_CompleteFlow_TransitionsThroughAllStates()
        {
            using var context = CreateInMemoryDbContext();
            var service = CreateService(context);

            // 1. Create (REQUESTED -> SEARCHING)
            var ride = await service.CreateRideAsync(new CreateRideRequest
            {
                PassengerId = 101,
                PickupLocation = "A",
                DestinationLocation = "B",
                PickupLatitude = 17.44m,
                PickupLongitude = 78.37m,
                DestinationLatitude = 17.24m,
                DestinationLongitude = 78.42m
            });
            Assert.Equal("SEARCHING", ride.Status);

            // 2. Accept
            ride = await service.AcceptRideAsync(ride.RideId, 201);
            Assert.Equal("ACCEPTED", ride.Status);

            // 3. Arriving
            ride = await service.RiderArrivingAsync(ride.RideId);
            Assert.Equal("RIDER_ARRIVING", ride.Status);

            // 4. Arrived
            ride = await service.ArrivedAsync(ride.RideId);
            Assert.Equal("ARRIVED", ride.Status);

            // 5. Start
            ride = await service.StartRideAsync(ride.RideId);
            Assert.Equal("STARTED", ride.Status);
            Assert.NotNull(ride.StartedAt);

            // 6. Complete
            ride = await service.CompleteRideAsync(ride.RideId);
            Assert.Equal("COMPLETED", ride.Status);
            Assert.NotNull(ride.CompletedAt);
        }

        [Fact]
        public async Task StartRideAsync_BeforeDriverArrived_ThrowsInvalidOperationException()
        {
            using var context = CreateInMemoryDbContext();
            var service = CreateService(context);

            var ride = await service.CreateRideAsync(new CreateRideRequest
            {
                PassengerId = 101,
                PickupLocation = "A",
                DestinationLocation = "B",
                PickupLatitude = 17.44m,
                PickupLongitude = 78.37m,
                DestinationLatitude = 17.24m,
                DestinationLongitude = 78.42m
            });

            await service.AcceptRideAsync(ride.RideId, 201);
            await Assert.ThrowsAsync<InvalidOperationException>(() =>
                service.StartRideAsync(ride.RideId));
        }

        [Fact]
        public async Task CancelRideAsync_WhenSearching_Succeeds()
        {
            using var context = CreateInMemoryDbContext();
            var service = CreateService(context);

            var ride = await service.CreateRideAsync(new CreateRideRequest
            {
                PassengerId = 101,
                PickupLocation = "A",
                DestinationLocation = "B",
                PickupLatitude = 17.44m,
                PickupLongitude = 78.37m,
                DestinationLatitude = 17.24m,
                DestinationLongitude = 78.42m
            });

            var result = await service.CancelRideAsync(ride.RideId, new CancelRideRequest
            {
                Reason = "Cancelled by user",
                CancelledBy = "CUSTOMER"
            });

            Assert.Equal("CANCELLED", result.Status);
            Assert.NotNull(result.CancelledAt);
        }

        [Fact]
        public async Task CancelRideAsync_WhenArrived_ThrowsInvalidOperationException()
        {
            using var context = CreateInMemoryDbContext();
            var service = CreateService(context);

            var ride = await service.CreateRideAsync(new CreateRideRequest
            {
                PassengerId = 101,
                PickupLocation = "A",
                DestinationLocation = "B",
                PickupLatitude = 17.44m,
                PickupLongitude = 78.37m,
                DestinationLatitude = 17.24m,
                DestinationLongitude = 78.42m
            });

            await service.AcceptRideAsync(ride.RideId, 201);
            await service.RiderArrivingAsync(ride.RideId);
            await service.ArrivedAsync(ride.RideId);

            // Once arrived, cancellation is forbidden by backend rules
            await Assert.ThrowsAsync<InvalidOperationException>(() =>
                service.CancelRideAsync(ride.RideId, new CancelRideRequest
                {
                    Reason = "Driver arrived but cancel wanted",
                    CancelledBy = "CUSTOMER"
                }));
        }

        [Fact]
        public async Task CancelRideAsync_WhenStarted_ThrowsInvalidOperationException()
        {
            using var context = CreateInMemoryDbContext();
            var service = CreateService(context);

            var ride = await service.CreateRideAsync(new CreateRideRequest
            {
                PassengerId = 101,
                PickupLocation = "A",
                DestinationLocation = "B",
                PickupLatitude = 17.44m,
                PickupLongitude = 78.37m,
                DestinationLatitude = 17.24m,
                DestinationLongitude = 78.42m
            });

            await service.AcceptRideAsync(ride.RideId, 201);
            await service.RiderArrivingAsync(ride.RideId);
            await service.ArrivedAsync(ride.RideId);
            await service.StartRideAsync(ride.RideId);

            await Assert.ThrowsAsync<InvalidOperationException>(() =>
                service.CancelRideAsync(ride.RideId, new CancelRideRequest
                {
                    Reason = "Cancel during ride",
                    CancelledBy = "CUSTOMER"
                }));
        }
    }
}
