import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthRepository {
  final AuthService _authService;

  AuthRepository(this._authService);

  UserModel? getPersistedUser() => _authService.getPersistedUser();

  Future<UserModel> login({
    required String email,
    required String password,
    UserRole defaultRole = UserRole.customer,
  }) =>
      _authService.login(email: email, password: password, defaultRole: defaultRole);

  Future<UserModel> register({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String password,
    required UserRole role,
  }) =>
      _authService.register(
        firstName: firstName,
        lastName: lastName,
        email: email,
        phone: phone,
        password: password,
        role: role,
      );

  Future<void> logout() => _authService.logout();

  Future<void> switchRole(UserRole newRole) => _authService.switchRole(newRole);

  UserRole? getActiveRole() => _authService.getActiveRole();
}
