import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/rider_provider.dart';
import '../../../widgets/empty_state.dart';
import '../../../widgets/ride_request_card.dart';
import '../current_ride/rider_current_ride_screen.dart';

class AvailableRidesScreen extends StatefulWidget {
  const AvailableRidesScreen({super.key});

  @override
  State<AvailableRidesScreen> createState() => _AvailableRidesScreenState();
}

class _AvailableRidesScreenState extends State<AvailableRidesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RiderProvider>().fetchAvailableRides();
    });
  }

  Future<void> _handleAcceptRide(int rideId) async {
    final authProvider = context.read<AuthProvider>();
    final riderProvider = context.read<RiderProvider>();
    final driverId = authProvider.currentUser?.id ?? 201;

    final success = await riderProvider.acceptRide(
      rideId: rideId,
      driverId: driverId,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Accepted Ride #$rideId! Proceed to pickup.'),
          backgroundColor: AppTheme.success,
        ),
      );
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const RiderCurrentRideScreen()),
      );
    } else if (riderProvider.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(riderProvider.errorMessage!),
          backgroundColor: AppTheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final riderProvider = context.watch<RiderProvider>();
    final rides = riderProvider.availableRides;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Available Ride Requests'),
        actions: [
          IconButton(
            tooltip: 'Refresh Requests',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => riderProvider.fetchAvailableRides(),
          ),
        ],
      ),
      body: !riderProvider.isOnline
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceMuted,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.bedtime_outlined, size: 40, color: AppTheme.textMuted),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'You are currently Offline',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Turn your online status on to view and accept incoming ride requests.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: AppTheme.textSecondary),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.success,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: const Icon(Icons.power_settings_new_rounded, size: 18),
                      label: const Text('Switch Online', style: TextStyle(fontWeight: FontWeight.w700)),
                      onPressed: () => riderProvider.toggleOnline(true),
                    ),
                  ],
                ),
              ),
            )
          : riderProvider.isLoadingAvailable && rides.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : rides.isEmpty
                  ? EmptyState(
                      icon: Icons.hail_rounded,
                      title: 'No Pending Ride Requests',
                      message: 'There are currently no customers requesting rides in your area. Pull down to refresh.',
                      actionText: 'Refresh Requests',
                      onAction: () => riderProvider.fetchAvailableRides(),
                    )
                  : RefreshIndicator(
                      onRefresh: () => riderProvider.fetchAvailableRides(),
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        itemCount: rides.length,
                        itemBuilder: (context, index) {
                          final ride = rides[index];
                          return RideRequestCard(
                            ride: ride,
                            isAccepting: riderProvider.isAccepting,
                            onAccept: () => _handleAcceptRide(ride.rideId),
                          );
                        },
                      ),
                    ),
    );
  }
}
