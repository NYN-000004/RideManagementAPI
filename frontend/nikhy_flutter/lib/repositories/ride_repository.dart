import '../models/create_ride_request.dart';
import '../models/cancel_ride_request.dart';
import '../models/ride_model.dart';
import '../models/ride_history_item.dart';
import '../models/ride_status.dart';
import '../services/ride_service.dart';

class RideRepository {
  final RideService _rideService;

  RideRepository(this._rideService);

  Future<RideModel> createRide(CreateRideRequest request) =>
      _rideService.createRide(request);

  Future<RideModel> getRideById(int rideId) =>
      _rideService.getRideById(rideId);

  Future<RideModel> acceptRide(int rideId, int driverId) =>
      _rideService.acceptRide(rideId, driverId);

  Future<RideModel> updateStatus(int rideId, RideStatus status) =>
      _rideService.updateStatus(rideId, status);

  Future<RideModel> markArriving(int rideId) =>
      _rideService.markArriving(rideId);

  Future<RideModel> markArrived(int rideId) =>
      _rideService.markArrived(rideId);

  Future<RideModel> startRide(int rideId) =>
      _rideService.startRide(rideId);

  Future<RideModel> completeRide(int rideId) =>
      _rideService.completeRide(rideId);

  Future<RideModel> cancelRide(int rideId, CancelRideRequest request) =>
      _rideService.cancelRide(rideId, request);

  Future<List<RideHistoryItem>> getCustomerHistory(int passengerId, {int page = 1, int pageSize = 20}) =>
      _rideService.getHistory(passengerId: passengerId, page: page, pageSize: pageSize);

  Future<List<RideHistoryItem>> getRiderHistory(int driverId, {int page = 1, int pageSize = 20}) =>
      _rideService.getHistory(driverId: driverId, page: page, pageSize: pageSize);

  Future<List<RideHistoryItem>> getAvailableRides({int page = 1, int pageSize = 20}) =>
      _rideService.getAvailableRides(page: page, pageSize: pageSize);
}
