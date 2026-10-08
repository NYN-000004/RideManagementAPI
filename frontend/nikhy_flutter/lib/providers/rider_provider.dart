import 'package:flutter/material.dart';
import '../core/network/api_exceptions.dart';
import '../core/storage/storage_service.dart';
import '../models/cancel_ride_request.dart';
import '../models/ride_model.dart';
import '../models/ride_history_item.dart';
import '../repositories/ride_repository.dart';

class RiderProvider extends ChangeNotifier {
  final RideRepository _rideRepository;
  final StorageService _storageService;

  bool _isOnline = false;
  List<RideHistoryItem> _availableRides = [];
  RideModel? _currentAcceptedRide;
  List<RideHistoryItem> _history = [];

  bool _isLoadingAvailable = false;
  bool _isAccepting = false;
  bool _isUpdatingStatus = false;
  bool _isLoadingHistory = false;
  String? _errorMessage;

  RiderProvider(this._rideRepository, this._storageService) {
    _isOnline = _storageService.getRiderOnline();
  }

  bool get isOnline => _isOnline;
  List<RideHistoryItem> get availableRides => _availableRides;
  RideModel? get currentAcceptedRide => _currentAcceptedRide;
  List<RideHistoryItem> get history => _history;

  bool get isLoadingAvailable => _isLoadingAvailable;
  bool get isAccepting => _isAccepting;
  bool get isUpdatingStatus => _isUpdatingStatus;
  bool get isLoadingHistory => _isLoadingHistory;
  String? get errorMessage => _errorMessage;

  void toggleOnline(bool val) {
    _isOnline = val;
    _storageService.saveRiderOnline(val);
    notifyListeners();
    if (_isOnline) {
      fetchAvailableRides();
    }
  }

  void setCurrentAcceptedRide(RideModel? ride) {
    _currentAcceptedRide = ride;
    notifyListeners();
  }

  void clearCurrentRide() {
    _currentAcceptedRide = null;
    notifyListeners();
  }

  /// Rider fetches available rides in SEARCHING state
  Future<void> fetchAvailableRides() async {
    _isLoadingAvailable = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final rides = await _rideRepository.getAvailableRides();
      _availableRides = rides;
      _isLoadingAvailable = false;
      notifyListeners();
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _isLoadingAvailable = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoadingAvailable = false;
      notifyListeners();
    }
  }

  /// Rider accepts a ride
  Future<bool> acceptRide({
    required int rideId,
    required int driverId,
  }) async {
    _isAccepting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final ride = await _rideRepository.acceptRide(rideId, driverId);
      _currentAcceptedRide = ride;
      _availableRides.removeWhere((item) => item.rideId == rideId);
      _isAccepting = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _isAccepting = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      _isAccepting = false;
      notifyListeners();
      return false;
    }
  }

  /// Rider marks arriving at pickup
  Future<bool> markArriving() async {
    if (_currentAcceptedRide == null) return false;
    _isUpdatingStatus = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final ride = await _rideRepository.markArriving(_currentAcceptedRide!.rideId);
      _currentAcceptedRide = ride;
      _isUpdatingStatus = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _isUpdatingStatus = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      _isUpdatingStatus = false;
      notifyListeners();
      return false;
    }
  }

  /// Rider marks arrived at pickup
  Future<bool> markArrived() async {
    if (_currentAcceptedRide == null) return false;
    _isUpdatingStatus = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final ride = await _rideRepository.markArrived(_currentAcceptedRide!.rideId);
      _currentAcceptedRide = ride;
      _isUpdatingStatus = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _isUpdatingStatus = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      _isUpdatingStatus = false;
      notifyListeners();
      return false;
    }
  }

  /// Rider starts the trip
  Future<bool> startTrip() async {
    if (_currentAcceptedRide == null) return false;
    _isUpdatingStatus = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final ride = await _rideRepository.startRide(_currentAcceptedRide!.rideId);
      _currentAcceptedRide = ride;
      _isUpdatingStatus = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _isUpdatingStatus = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      _isUpdatingStatus = false;
      notifyListeners();
      return false;
    }
  }

  /// Rider completes the trip
  Future<bool> completeTrip() async {
    if (_currentAcceptedRide == null) return false;
    _isUpdatingStatus = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final ride = await _rideRepository.completeRide(_currentAcceptedRide!.rideId);
      _currentAcceptedRide = ride;
      _isUpdatingStatus = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _isUpdatingStatus = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      _isUpdatingStatus = false;
      notifyListeners();
      return false;
    }
  }

  /// Rider cancels the ride (only permitted before ARRIVED)
  Future<bool> cancelRide(String reason) async {
    if (_currentAcceptedRide == null) return false;
    _isUpdatingStatus = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final request = CancelRideRequest(
        reason: reason,
        cancelledBy: 'Driver',
      );
      final ride = await _rideRepository.cancelRide(_currentAcceptedRide!.rideId, request);
      _currentAcceptedRide = ride;
      _isUpdatingStatus = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _isUpdatingStatus = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      _isUpdatingStatus = false;
      notifyListeners();
      return false;
    }
  }

  /// Refreshes current accepted ride from backend
  Future<void> refreshCurrentRide() async {
    if (_currentAcceptedRide == null) return;
    try {
      final ride = await _rideRepository.getRideById(_currentAcceptedRide!.rideId);
      _currentAcceptedRide = ride;
      notifyListeners();
    } catch (_) {}
  }

  /// Fetches rider's trip history
  Future<void> fetchHistory(int driverId) async {
    _isLoadingHistory = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final items = await _rideRepository.getRiderHistory(driverId);
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
