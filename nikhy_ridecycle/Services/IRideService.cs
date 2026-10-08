using Nikhy_demo.DTOs;
using Nikhy_demo.Enums;

namespace Nikhy_demo.Services
{
    public interface IRideService
    {
        Task<RideResponse> CreateRideAsync(
            CreateRideRequest request);

        Task<RideResponse?> GetRideByIdAsync(
            long rideId);

        Task<RideResponse> AcceptRideAsync(
            long rideId,
            long driverId);

        Task<RideResponse> UpdateStatusAsync(
            long rideId,
            RideStatus newStatus);

        Task<RideResponse> RiderArrivingAsync(
            long rideId);

        Task<RideResponse> ArrivedAsync(
            long rideId);

        Task<RideResponse> StartRideAsync(
            long rideId);

        Task<RideResponse> CompleteRideAsync(
            long rideId);

        Task<RideResponse> CancelRideAsync(
            long rideId,
            CancelRideRequest request);

        Task<List<RideHistoryResponse>> GetHistoryAsync(
            long? passengerId,
            long? driverId,
            RideStatus? status,
            int page,
            int pageSize);
    }
}