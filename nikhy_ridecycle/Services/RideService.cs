using Microsoft.EntityFrameworkCore;
using Nikhy_demo.Data;
using Nikhy_demo.DTOs;
using Nikhy_demo.Enums;
using Nikhy_demo.Models;

namespace Nikhy_demo.Services
{
    public class RideService : IRideService
    {
        private readonly ApplicationDbContext _context;

        public RideService(ApplicationDbContext context)
        {
            _context = context;
        }

        // =========================================================
        // DAY 1
        // CREATE RIDE
        // =========================================================

        public async Task<RideResponse> CreateRideAsync(
            CreateRideRequest request)
        {
            if (string.IsNullOrWhiteSpace(request.PickupLocation))
            {
                throw new ArgumentException(
                    "Pickup location is required.");
            }

            if (string.IsNullOrWhiteSpace(request.DestinationLocation))
            {
                throw new ArgumentException(
                    "Destination location is required.");
            }

            if (request.PickupLocation.Trim()
                .Equals(
                    request.DestinationLocation.Trim(),
                    StringComparison.OrdinalIgnoreCase))
            {
                throw new ArgumentException(
                    "Pickup and destination cannot be the same.");
            }

            ValidateCoordinates(
                request.PickupLatitude,
                request.PickupLongitude,
                request.DestinationLatitude,
                request.DestinationLongitude);

            var now = DateTime.UtcNow;

            var ride = new Ride
            {
                BookingId = request.BookingId,

                PassengerId = request.PassengerId,

                PickupLocation = request.PickupLocation.Trim(),

                DestinationLocation =
                    request.DestinationLocation.Trim(),

                PickupLatitude = request.PickupLatitude,

                PickupLongitude = request.PickupLongitude,

                DestinationLatitude =
                    request.DestinationLatitude,

                DestinationLongitude =
                    request.DestinationLongitude,

                Fare = request.Fare,

                Distance = request.Distance,

                EstimatedDuration =
                    request.EstimatedDuration,

                Status = RideStatus.REQUESTED,

                RequestedAt = now,

                CreatedAt = now,

                UpdatedAt = now
            };

            _context.Rides.Add(ride);

            await _context.SaveChangesAsync();

            // Generate/search for ride request.
            // At this stage the ride becomes available
            // for rider searching.
            ride.Status = RideStatus.SEARCHING;
            ride.UpdatedAt = DateTime.UtcNow;

            await _context.SaveChangesAsync();

            return MapToResponse(ride);
        }


        // =========================================================
        // GET RIDE DETAILS
        // =========================================================

        public async Task<RideResponse?> GetRideByIdAsync(
            long rideId)
        {
            var ride = await _context.Rides
                .AsNoTracking()
                .FirstOrDefaultAsync(r => r.RideId == rideId);

            if (ride == null)
            {
                return null;
            }

            return MapToResponse(ride);
        }


        // =========================================================
        // DAY 2
        // ACCEPT RIDE
        // =========================================================

        public async Task<RideResponse> AcceptRideAsync(
            long rideId,
            long driverId)
        {
            if (driverId <= 0)
            {
                throw new ArgumentException(
                    "Valid driver ID is required.");
            }

            var ride = await _context.Rides
                .FirstOrDefaultAsync(r => r.RideId == rideId);

            if (ride == null)
            {
                throw new KeyNotFoundException(
                    "Ride not found.");
            }

            // Critical concurrency protection.
            // Only SEARCHING rides can be accepted.
            if (ride.Status != RideStatus.SEARCHING)
            {
                throw new InvalidOperationException(
                    "Ride is no longer available for acceptance.");
            }

            // Prevent invalid driver assignment.
            if (ride.DriverId.HasValue)
            {
                throw new InvalidOperationException(
                    "Ride already has a driver.");
            }

            ride.DriverId = driverId;

            ride.AcceptedAt = DateTime.UtcNow;

            ride.Status = RideStatus.ACCEPTED;

            ride.UpdatedAt = DateTime.UtcNow;

            await _context.SaveChangesAsync();

            return MapToResponse(ride);
        }


        // =========================================================
        // CENTRALIZED STATE MANAGEMENT
        // =========================================================

        public async Task<RideResponse> UpdateStatusAsync(
            long rideId,
            RideStatus newStatus)
        {
            var ride = await _context.Rides
                .FirstOrDefaultAsync(r => r.RideId == rideId);

            if (ride == null)
            {
                throw new KeyNotFoundException(
                    "Ride not found.");
            }

            ValidateTransition(
                ride.Status,
                newStatus);

            if (newStatus == RideStatus.ACCEPTED &&
                !ride.DriverId.HasValue)
            {
                throw new InvalidOperationException(
                    "Driver must be assigned before accepting ride.");
            }

            ApplyStatusTimestamp(
                ride,
                newStatus);

            ride.Status = newStatus;

            ride.UpdatedAt = DateTime.UtcNow;

            await _context.SaveChangesAsync();

            return MapToResponse(ride);
        }


        // =========================================================
        // RIDER ARRIVING
        // ACCEPTED -> RIDER_ARRIVING
        // =========================================================

        public async Task<RideResponse> RiderArrivingAsync(
            long rideId)
        {
            return await UpdateStatusAsync(
                rideId,
                RideStatus.RIDER_ARRIVING);
        }


        // =========================================================
        // ARRIVED
        // RIDER_ARRIVING -> ARRIVED
        // =========================================================

        public async Task<RideResponse> ArrivedAsync(
            long rideId)
        {
            return await UpdateStatusAsync(
                rideId,
                RideStatus.ARRIVED);
        }


        // =========================================================
        // DAY 3
        // START RIDE
        // =========================================================

        public async Task<RideResponse> StartRideAsync(
            long rideId)
        {
            var ride = await _context.Rides
                .FirstOrDefaultAsync(r => r.RideId == rideId);

            if (ride == null)
            {
                throw new KeyNotFoundException(
                    "Ride not found.");
            }

            if (ride.Status != RideStatus.ARRIVED)
            {
                throw new InvalidOperationException(
                    "Ride can only be started after rider has arrived.");
            }

            if (!ride.DriverId.HasValue)
            {
                throw new InvalidOperationException(
                    "Ride cannot start without an assigned driver.");
            }

            ride.Status = RideStatus.STARTED;

            ride.StartedAt = DateTime.UtcNow;

            ride.UpdatedAt = DateTime.UtcNow;

            await _context.SaveChangesAsync();

            return MapToResponse(ride);
        }


        // =========================================================
        // COMPLETE RIDE
        // STARTED -> COMPLETED
        // =========================================================

        public async Task<RideResponse> CompleteRideAsync(
            long rideId)
        {
            var ride = await _context.Rides
                .FirstOrDefaultAsync(r => r.RideId == rideId);

            if (ride == null)
            {
                throw new KeyNotFoundException(
                    "Ride not found.");
            }

            if (ride.Status != RideStatus.STARTED)
            {
                throw new InvalidOperationException(
                    "Only started rides can be completed.");
            }

            if (!ride.DriverId.HasValue)
            {
                throw new InvalidOperationException(
                    "Ride has no assigned driver.");
            }

            ride.Status = RideStatus.COMPLETED;

            ride.CompletedAt = DateTime.UtcNow;

            ride.UpdatedAt = DateTime.UtcNow;

            await _context.SaveChangesAsync();

            return MapToResponse(ride);
        }


        // =========================================================
        // CANCEL RIDE
        // =========================================================

        public async Task<RideResponse> CancelRideAsync(
            long rideId,
            CancelRideRequest request)
        {
            if (string.IsNullOrWhiteSpace(request.Reason))
            {
                throw new ArgumentException(
                    "Cancellation reason is required.");
            }

            if (string.IsNullOrWhiteSpace(request.CancelledBy))
            {
                throw new ArgumentException(
                    "CancelledBy is required.");
            }

            var ride = await _context.Rides
                .FirstOrDefaultAsync(r => r.RideId == rideId);

            if (ride == null)
            {
                throw new KeyNotFoundException(
                    "Ride not found.");
            }

            if (!CanCancel(ride.Status))
            {
                throw new InvalidOperationException(
                    $"Ride cannot be cancelled from {ride.Status} state.");
            }

            ride.Status = RideStatus.CANCELLED;

            ride.CancelledAt = DateTime.UtcNow;

            ride.CancellationReason =
                request.Reason.Trim();

            ride.CancelledBy =
                request.CancelledBy.Trim();

            ride.UpdatedAt = DateTime.UtcNow;

            await _context.SaveChangesAsync();

            return MapToResponse(ride);
        }


        // =========================================================
        // RIDE HISTORY
        // =========================================================

        public async Task<List<RideHistoryResponse>> GetHistoryAsync(
            long? passengerId,
            long? driverId,
            RideStatus? status,
            int page,
            int pageSize)
        {
            if (page < 1)
            {
                page = 1;
            }

            if (pageSize < 1)
            {
                pageSize = 10;
            }

            if (pageSize > 100)
            {
                pageSize = 100;
            }

            IQueryable<Ride> query =
                _context.Rides.AsNoTracking();

            if (passengerId.HasValue)
            {
                query = query.Where(
                    r => r.PassengerId == passengerId.Value);
            }

            if (driverId.HasValue)
            {
                query = query.Where(
                    r => r.DriverId == driverId.Value);
            }

            if (status.HasValue)
            {
                query = query.Where(
                    r => r.Status == status.Value);
            }

            var rides = await query
                .OrderByDescending(r => r.CreatedAt)
                .Skip((page - 1) * pageSize)
                .Take(pageSize)
                .Select(r => new RideHistoryResponse
                {
                    RideId = r.RideId,

                    PickupLocation = r.PickupLocation,

                    DestinationLocation =
                        r.DestinationLocation,

                    Status = r.Status,

                    Fare = r.Fare,

                    RequestedAt = r.RequestedAt,

                    CompletedAt = r.CompletedAt,

                    CancelledAt = r.CancelledAt
                })
                .ToListAsync();

            return rides;
        }


        // =========================================================
        // VALIDATE STATE TRANSITIONS
        // =========================================================

        private static void ValidateTransition(
            RideStatus current,
            RideStatus next)
        {
            if (current == next)
            {
                throw new InvalidOperationException(
                    $"Ride is already in {current} state.");
            }

            if (current == RideStatus.COMPLETED)
            {
                throw new InvalidOperationException(
                    "Completed ride is a terminal state.");
            }

            if (current == RideStatus.CANCELLED)
            {
                throw new InvalidOperationException(
                    "Cancelled ride is a terminal state.");
            }

            bool valid = current switch
            {
                RideStatus.REQUESTED =>
                    next == RideStatus.SEARCHING ||
                    next == RideStatus.CANCELLED,

                RideStatus.SEARCHING =>
                    next == RideStatus.ACCEPTED ||
                    next == RideStatus.CANCELLED,

                RideStatus.ACCEPTED =>
                    next == RideStatus.RIDER_ARRIVING ||
                    next == RideStatus.CANCELLED,

                RideStatus.RIDER_ARRIVING =>
                    next == RideStatus.ARRIVED ||
                    next == RideStatus.CANCELLED,

                RideStatus.ARRIVED =>
                    next == RideStatus.STARTED,

                RideStatus.STARTED =>
                    next == RideStatus.COMPLETED,

                _ => false
            };

            if (!valid)
            {
                throw new InvalidOperationException(
                    $"Invalid ride state transition: " +
                    $"{current} -> {next}");
            }
        }


        // =========================================================
        // CANCELLATION RULE
        // =========================================================

        private static bool CanCancel(
            RideStatus status)
        {
            return status == RideStatus.REQUESTED ||
                   status == RideStatus.SEARCHING ||
                   status == RideStatus.ACCEPTED ||
                   status == RideStatus.RIDER_ARRIVING;
        }


        // =========================================================
        // TIMESTAMP MANAGEMENT
        // =========================================================

        private static void ApplyStatusTimestamp(
            Ride ride,
            RideStatus status)
        {
            var now = DateTime.UtcNow;

            switch (status)
            {
                case RideStatus.ACCEPTED:
                    ride.AcceptedAt = now;
                    break;

                case RideStatus.STARTED:
                    ride.StartedAt = now;
                    break;

                case RideStatus.COMPLETED:
                    ride.CompletedAt = now;
                    break;

                case RideStatus.CANCELLED:
                    ride.CancelledAt = now;
                    break;
            }
        }


        // =========================================================
        // COORDINATE VALIDATION
        // =========================================================

        private static void ValidateCoordinates(
            decimal pickupLatitude,
            decimal pickupLongitude,
            decimal destinationLatitude,
            decimal destinationLongitude)
        {
            if (pickupLatitude < -90 ||
                pickupLatitude > 90)
            {
                throw new ArgumentException(
                    "Invalid pickup latitude.");
            }

            if (pickupLongitude < -180 ||
                pickupLongitude > 180)
            {
                throw new ArgumentException(
                    "Invalid pickup longitude.");
            }

            if (destinationLatitude < -90 ||
                destinationLatitude > 90)
            {
                throw new ArgumentException(
                    "Invalid destination latitude.");
            }

            if (destinationLongitude < -180 ||
                destinationLongitude > 180)
            {
                throw new ArgumentException(
                    "Invalid destination longitude.");
            }
        }


        // =========================================================
        // ENTITY -> DTO
        // =========================================================

        private static RideResponse MapToResponse(
            Ride ride)
        {
            return new RideResponse
            {
                RideId = ride.RideId,

                BookingId = ride.BookingId,

                PassengerId = ride.PassengerId,

                DriverId = ride.DriverId,

                PickupLocation =
                    ride.PickupLocation,

                DestinationLocation =
                    ride.DestinationLocation,

                PickupLatitude =
                    ride.PickupLatitude,

                PickupLongitude =
                    ride.PickupLongitude,

                DestinationLatitude =
                    ride.DestinationLatitude,

                DestinationLongitude =
                    ride.DestinationLongitude,

                Status =
                    ride.Status.ToString(),

                Fare =
                    ride.Fare,

                Distance =
                    ride.Distance,

                EstimatedDuration =
                    ride.EstimatedDuration,

                RequestedAt =
                    ride.RequestedAt,

                AcceptedAt =
                    ride.AcceptedAt,

                StartedAt =
                    ride.StartedAt,

                CompletedAt =
                    ride.CompletedAt,

                CancelledAt =
                    ride.CancelledAt,

                CancellationReason =
                    ride.CancellationReason,

                CancelledBy =
                    ride.CancelledBy,

                CreatedAt =
                    ride.CreatedAt,

                UpdatedAt =
                    ride.UpdatedAt
            };
        }
    }
}