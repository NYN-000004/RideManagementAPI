import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/network/api_client.dart';
import 'core/storage/storage_service.dart';
import 'core/theme/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/ride_provider.dart';
import 'providers/rider_provider.dart';
import 'repositories/auth_repository.dart';
import 'repositories/ride_repository.dart';
import 'screens/splash/splash_screen.dart';
import 'services/auth_service.dart';
import 'services/ride_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Initialize persistent storage
  final storageService = await StorageService.init();

  // 2. Global navigator key for navigation outside widget tree (e.g. 401 redirect)
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  // 3. Initialize centralized API client
  late final ApiClient apiClient;
  late final AuthProvider authProvider;

  apiClient = ApiClient(
    storageService,
    onUnauthorized: () {
      authProvider.logout();
    },
  );

  // 4. Initialize services & repositories
  final authService = AuthService(apiClient, storageService);
  final authRepository = AuthRepository(authService);

  final rideService = RideService(apiClient);
  final rideRepository = RideRepository(rideService);

  // 5. Initialize state management providers
  authProvider = AuthProvider(authRepository, apiClient, storageService);
  final rideProvider = RideProvider(rideRepository);
  final riderProvider = RiderProvider(rideRepository, storageService);

  // 6. Preload session
  await authProvider.initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
        ChangeNotifierProvider<RideProvider>.value(value: rideProvider),
        ChangeNotifierProvider<RiderProvider>.value(value: riderProvider),
        Provider<RideRepository>.value(value: rideRepository),
        Provider<AuthRepository>.value(value: authRepository),
        Provider<ApiClient>.value(value: apiClient),
        Provider<StorageService>.value(value: storageService),
      ],
      child: NikhyApp(navigatorKey: navigatorKey),
    ),
  );
}

class NikhyApp extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorKey;

  const NikhyApp({super.key, required this.navigatorKey});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'NIKHY — Ride Management',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
    );
  }
}
