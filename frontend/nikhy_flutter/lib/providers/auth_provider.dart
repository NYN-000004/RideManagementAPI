import 'package:flutter/material.dart';
import '../core/network/api_client.dart';
import '../core/network/api_exceptions.dart';
import '../core/storage/storage_service.dart';
import '../models/user_model.dart';
import '../repositories/auth_repository.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepository;
  final ApiClient _apiClient;
  final StorageService _storageService;

  UserModel? _currentUser;
  UserRole _activeRole = UserRole.customer;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isInitialized = false;

  AuthProvider(this._authRepository, this._apiClient, this._storageService);

  UserModel? get currentUser => _currentUser;
  UserRole get activeRole => _activeRole;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null;
  bool get isInitialized => _isInitialized;
  String get baseUrl => _apiClient.baseUrl;

  /// Restores session on app startup
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      _currentUser = _authRepository.getPersistedUser();
      if (_currentUser != null) {
        if (_currentUser!.avatarUrl == null) {
          final savedAvatar = _storageService.getDriverAvatar(_currentUser!.id);
          if (savedAvatar != null) {
            _currentUser = _currentUser!.copyWith(avatarUrl: savedAvatar);
          }
        }
        _activeRole = _authRepository.getActiveRole() ?? _currentUser!.role;
      }
    } catch (_) {
      _currentUser = null;
    } finally {
      _isLoading = false;
      _isInitialized = true;
      notifyListeners();
    }
  }

  Future<bool> login({
    required String email,
    required String password,
    UserRole defaultRole = UserRole.customer,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentUser = await _authRepository.login(
        email: email,
        password: password,
        defaultRole: defaultRole,
      );
      _activeRole = _currentUser!.role;
      _isLoading = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String password,
    required UserRole role,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentUser = await _authRepository.register(
        firstName: firstName,
        lastName: lastName,
        email: email,
        phone: phone,
        password: password,
        role: role,
      );
      _activeRole = role;
      _isLoading = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    await _authRepository.logout();
    _currentUser = null;
    _activeRole = UserRole.customer;
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }

  /// Rider can switch into Customer mode to book a ride, and switch back
  void switchActiveRole(UserRole newRole) {
    if (_activeRole != newRole) {
      _activeRole = newRole;
      _authRepository.switchRole(newRole);
      notifyListeners();
    }
  }

  void updateServerUrl(String newUrl) {
    _apiClient.updateBaseUrl(newUrl);
    notifyListeners();
  }

  void resetServerUrl() {
    _storageService.resetBaseUrl();
    _apiClient.updateBaseUrl(_storageService.getBaseUrl());
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> updateAvatar(String? avatarUrl) async {
    if (_currentUser == null) return;
    final updated = _currentUser!.copyWith(avatarUrl: avatarUrl);
    _currentUser = updated;
    await _storageService.saveUser(updated);
    if (avatarUrl != null) {
      await _storageService.saveDriverAvatar(updated.id, avatarUrl);
    }
    notifyListeners();
  }
}
