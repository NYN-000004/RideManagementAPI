import 'package:flutter/material.dart';
import '../core/network/api_exceptions.dart';
import '../models/create_ride_request.dart';
import '../models/cancel_ride_request.dart';
import '../models/ride_model.dart';
import '../models/ride_history_item.dart';
import '../repositories/ride_repository.dart';

class RideProvider extends ChangeNotifier {
  final RideRepository _rideRepository;

  RideModel? _currentRide;
  List<RideHistoryItem> _history = [];
  bool _isBooking = false;
  bool _isLoadingHistory = false;
  bool _isLoadingDetails = false;
  bool _isCancelling = false;
  String? _errorMessage;

  RideProvider(this._rideRepository);

  RideModel? get currentRide => _currentRide;
  List<RideHistoryItem> get history => _history;
  bool get isBooking => _isBooking;
  bool get isLoadingHistory => _isLoadingHistory;
  bool get isLoadingDetails => _isLoadingDetails;
  bool get isCancelling => _isCancelling;
  String? get errorMessage => _errorMessage;

  void setCurrentRide(RideModel? ride) {
    _currentRide = ride;
    notifyListeners();
  }

  void clearCurrentRide() {
    _currentRide = null;
    notifyListeners();
  }

  /// Customer books a new ride
  Future<RideModel?> bookRide(CreateRideRequest request) async {
    _isBooking = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final ride = await _rideRepository.createRide(request);
      _currentRide = ride;
      _isBooking = false;
      notifyListeners();
      return ride;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _isBooking = false;
      notifyListeners();
      return null;
    } catch (e) {
      _errorMessage = e.toString();
      _isBooking = false;
      notifyListeners();
      return null;
    }
  }

  /// Refreshes current ride status
  Future<void> refreshCurrentRide() async {
    if (_currentRide == null) return;
    await fetchRideDetails(_currentRide!.rideId);
  }

  /// Fetch single ride details by ID
  Future<RideModel?> fetchRideDetails(int rideId) async {
    _isLoadingDetails = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final ride = await _rideRepository.getRideById(rideId);
      if (_currentRide?.rideId == rideId || _currentRide == null) {
        _currentRide = ride;
      }
      _isLoadingDetails = false;
      notifyListeners();
      return ride;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _isLoadingDetails = false;
      notifyListeners();
      return null;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoadingDetails = false;
      notifyListeners();
      return null;
    }
  }

  /// Customer cancels active ride
  Future<bool> cancelActiveRide({
    required int rideId,
    required String reason,
    String cancelledBy = 'Passenger',
  }) async {
    _isCancelling = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final request = CancelRideRequest(
        reason: reason,
        cancelledBy: cancelledBy,
      );
      final updatedRide = await _rideRepository.cancelRide(rideId, request);
      _currentRide = updatedRide;
      _isCancelling = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _isCancelling = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      _isCancelling = false;
      notifyListeners();
      return false;
    }
  }

  /// Fetches customer's ride history
  Future<void> fetchHistory(int passengerId) async {
    _isLoadingHistory = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final items = await _rideRepository.getCustomerHistory(passengerId);
      _history = items;
      _isLoadingHistory = false;
      notifyListeners();
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _isLoadingHistory = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoadingHistory = false;
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
