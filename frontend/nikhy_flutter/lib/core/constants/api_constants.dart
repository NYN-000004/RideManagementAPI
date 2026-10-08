import 'package:flutter/foundation.dart';

class ApiConstants {
  // ASP.NET Core backend defaults from launchSettings.json:
  // HTTP: http://localhost:5231
  // HTTPS: https://localhost:7275
  //
  // On Android Emulator:
  // "localhost" points to the emulator itself.
  // The Windows host machine is accessible via 10.0.2.2.
  static const String androidEmulatorHost = 'http://10.0.2.2:5231';
  static const String desktopLocalHost = 'http://localhost:5231';

  /// Returns the sensible default base URL depending on target platform.
  static String get defaultBaseUrl {
    if (kIsWeb) {
      return desktopLocalHost;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return androidEmulatorHost;
      case TargetPlatform.windows:
      case TargetPlatform.linux:
      case TargetPlatform.macOS:
      case TargetPlatform.iOS:
      default:
        return desktopLocalHost;
    }
  }

  // Endpoints matching nikhy_ridecycle backend exactly
  static const String rides = '/api/rides';
  static const String rideHistory = '/api/rides/history';

  static String rideById(int id) => '/api/rides/$id';
  static String acceptRide(int id) => '/api/rides/$id/accept';
  static String updateStatus(int id) => '/api/rides/$id/status';
  static String riderArriving(int id) => '/api/rides/$id/arriving';
  static String arrived(int id) => '/api/rides/$id/arrived';
  static String startRide(int id) => '/api/rides/$id/start';
  static String completeRide(int id) => '/api/rides/$id/complete';
  static String cancelRide(int id) => '/api/rides/$id/cancel';

  // Future / Placeholder endpoints if AuthController is implemented
  static const String authLogin = '/api/auth/login';
  static const String authRegister = '/api/auth/register';

  // Storage keys
  static const String keyToken = 'nikhy_jwt_token';
  static const String keyUser = 'nikhy_user_session';
  static const String keyBaseUrl = 'nikhy_api_base_url';
  static const String keyActiveRole = 'nikhy_active_role';
  static const String keyRiderOnline = 'nikhy_rider_online_status';
}
