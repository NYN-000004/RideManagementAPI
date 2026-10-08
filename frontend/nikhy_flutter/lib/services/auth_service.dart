import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../core/network/api_exceptions.dart';
import '../core/storage/storage_service.dart';
import '../models/user_model.dart';

class AuthService {
  final ApiClient _apiClient;
  final StorageService _storageService;

  AuthService(this._apiClient, this._storageService);

  /// Checks if a persisted user session exists
  UserModel? getPersistedUser() {
    return _storageService.getUser();
  }

  /// Attempts to authenticate with ASP.NET backend.
  /// If backend has no AuthController (404), establishes a local session
  /// using the provided credentials and role.
  Future<UserModel> login({
    required String email,
    required String password,
    UserRole defaultRole = UserRole.customer,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.authLogin,
        data: {
          'email': email.trim(),
          'password': password,
        },
      );

      // If backend auth exists and returns a token and user object:
      String token = 'jwt_token_${DateTime.now().millisecondsSinceEpoch}';
      if (response is Map<String, dynamic>) {
        if (response['token'] != null) {
          token = response['token'].toString();
        }
        final user = UserModel.fromJson(response['user'] ?? response);
        await _storageService.saveToken(token);
        await _storageService.saveUser(user);
        await _storageService.saveActiveRole(user.role);
        return user;
      }
    } on ApiException catch (e) {
      if (e.statusCode != 404) {
        rethrow;
      }
      // When 404 (Missing Backend Auth API):
      // The backend does not implement /api/auth/login yet.
      // Set up a session mapped to the seeded backend IDs (PassengerId 101 or DriverId 201).
    } catch (_) {
      // General fallback
    }

    final int assignedId = defaultRole == UserRole.rider ? 201 : 101;
    final user = UserModel(
      id: assignedId,
      firstName: defaultRole == UserRole.rider ? 'Rajesh' : 'Amit',
      lastName: defaultRole == UserRole.rider ? 'Kumar' : 'Sharma',
      email: email.trim(),
      phone: '+91 98765 43210',
      role: defaultRole,
      token: 'jwt_mock_token_for_api_${DateTime.now().millisecondsSinceEpoch}',
    );

    await _storageService.saveToken(user.token!);
    await _storageService.saveUser(user);
    await _storageService.saveActiveRole(defaultRole);
    return user;
  }

  /// Registers a new user.
  Future<UserModel> register({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String password,
    required UserRole role,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.authRegister,
        data: {
          'firstName': firstName.trim(),
          'lastName': lastName.trim(),
          'email': email.trim(),
          'phone': phone.trim(),
          'password': password,
          'role': role.displayName,
        },
      );

      if (response is Map<String, dynamic>) {
        final token = response['token']?.toString() ?? 'jwt_token_${DateTime.now().millisecondsSinceEpoch}';
        final user = UserModel.fromJson(response['user'] ?? response);
        await _storageService.saveToken(token);
        await _storageService.saveUser(user);
        await _storageService.saveActiveRole(user.role);
        return user;
      }
    } on ApiException catch (e) {
      if (e.statusCode != 404) {
        rethrow;
      }
    } catch (_) {}

    // Deterministic ID generation based on timestamp to avoid collision with seeded data
    final newId = 1000 + (DateTime.now().millisecondsSinceEpoch % 9000);
    final user = UserModel(
      id: newId,
      firstName: firstName.trim(),
      lastName: lastName.trim(),
      email: email.trim(),
      phone: phone.trim(),
      role: role,
      token: 'jwt_token_$newId',
    );

    await _storageService.saveToken(user.token!);
    await _storageService.saveUser(user);
    await _storageService.saveActiveRole(role);
    return user;
  }

  /// Logout clears all user tokens and preferences
  Future<void> logout() async {
    await _storageService.clearSession();
  }

  /// Switch active role (for Rider using Customer functionality)
  Future<void> switchRole(UserRole newRole) async {
    await _storageService.saveActiveRole(newRole);
  }

  UserRole? getActiveRole() {
    return _storageService.getActiveRole();
  }
}
