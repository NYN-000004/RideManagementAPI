import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../models/create_ride_request.dart';
import '../models/cancel_ride_request.dart';
import '../models/ride_model.dart';
import '../models/ride_history_item.dart';
import '../models/ride_status.dart';

class RideService {
  final ApiClient _apiClient;

  RideService(this._apiClient);

  /// POST /api/rides
  /// Creates a new ride booking and returns the created ride.
  Future<RideModel> createRide(CreateRideRequest request) async {
    final response = await _apiClient.post(
      ApiConstants.rides,
      data: request.toJson(),
    );
    return RideModel.fromJson(response as Map<String, dynamic>);
  }

  /// GET /api/rides/{rideId}
  /// Fetches complete ride details by ID.
  Future<RideModel> getRideById(int rideId) async {
    final response = await _apiClient.get(
      ApiConstants.rideById(rideId),
    );
    return RideModel.fromJson(response as Map<String, dynamic>);
  }

  /// POST /api/rides/{rideId}/accept?driverId={driverId}
  /// Driver accepts a searching ride.
  Future<RideModel> acceptRide(int rideId, int driverId) async {
    final response = await _apiClient.post(
      ApiConstants.acceptRide(rideId),
      queryParameters: {'driverId': driverId},
    );
    return RideModel.fromJson(response as Map<String, dynamic>);
  }

  /// PATCH /api/rides/{rideId}/status
  /// Updates ride status generically.
  Future<RideModel> updateStatus(int rideId, RideStatus status) async {
    final response = await _apiClient.patch(
      ApiConstants.updateStatus(rideId),
      data: {'status': status.code},
    );
    return RideModel.fromJson(response as Map<String, dynamic>);
  }

  /// POST /api/rides/{rideId}/arriving
  /// Driver marks status as arriving at pickup point.
  Future<RideModel> markArriving(int rideId) async {
    final response = await _apiClient.post(
      ApiConstants.riderArriving(rideId),
    );
    return RideModel.fromJson(response as Map<String, dynamic>);
  }

  /// POST /api/rides/{rideId}/arrived
  /// Driver marks status as arrived at pickup location.
  Future<RideModel> markArrived(int rideId) async {
    final response = await _apiClient.post(
      ApiConstants.arrived(rideId),
    );
    return RideModel.fromJson(response as Map<String, dynamic>);
  }

  /// POST /api/rides/{rideId}/start
  /// Driver starts the trip.
  Future<RideModel> startRide(int rideId) async {
    final response = await _apiClient.post(
      ApiConstants.startRide(rideId),
    );
    return RideModel.fromJson(response as Map<String, dynamic>);
  }

  /// POST /api/rides/{rideId}/complete
  /// Driver completes the trip.
  Future<RideModel> completeRide(int rideId) async {
    final response = await _apiClient.post(
      ApiConstants.completeRide(rideId),
    );
    return RideModel.fromJson(response as Map<String, dynamic>);
  }

  /// POST /api/rides/{rideId}/cancel
  /// Cancels ride with reason and cancelledBy.
  Future<RideModel> cancelRide(int rideId, CancelRideRequest request) async {
    final response = await _apiClient.post(
      ApiConstants.cancelRide(rideId),
      data: request.toJson(),
    );
    return RideModel.fromJson(response as Map<String, dynamic>);
  }

  /// GET /api/rides/history
  /// Fetches paginated ride history with optional passenger, driver, or status filters.
  Future<List<RideHistoryItem>> getHistory({
    int? passengerId,
    int? driverId,
    RideStatus? status,
    int page = 1,
    int pageSize = 10,
  }) async {
    final Map<String, dynamic> query = {
      'page': page,
      'pageSize': pageSize,
    };

    if (passengerId != null) query['passengerId'] = passengerId;
    if (driverId != null) query['driverId'] = driverId;
    if (status != null) query['status'] = status.apiValue;

    final response = await _apiClient.get(
      ApiConstants.rideHistory,
      queryParameters: query,
    );

    if (response is Map<String, dynamic> && response['data'] is List) {
      final list = response['data'] as List;
      return list.map((item) => RideHistoryItem.fromJson(item as Map<String, dynamic>)).toList();
    }

    return [];
  }

  /// Fetches available rides waiting for drivers (status == SEARCHING)
  Future<List<RideHistoryItem>> getAvailableRides({
    int page = 1,
    int pageSize = 20,
  }) async {
    return getHistory(
      status: RideStatus.searching,
      page: page,
      pageSize: pageSize,
    );
  }
}
