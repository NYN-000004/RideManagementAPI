import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/ride_status.dart';
import '../../../models/user_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/rider_provider.dart';
import '../../../widgets/empty_state.dart';
import '../../../widgets/nikhy_logo.dart';
import '../../../widgets/ride_request_card.dart';
import '../../../widgets/section_title.dart';
import '../../../widgets/server_config_dialog.dart';
import '../../../widgets/status_badge.dart';
import '../../../widgets/user_avatar.dart';
import '../available_rides/available_rides_screen.dart';
import '../current_ride/rider_current_ride_screen.dart';
import '../ride_history/rider_ride_history_screen.dart';
import '../../customer/dashboard/customer_dashboard_screen.dart';
import '../../profile/profile_screen.dart';

class RiderDashboardScreen extends StatefulWidget {
  const RiderDashboardScreen({super.key});

  @override
  State<RiderDashboardScreen> createState() => _RiderDashboardScreenState();
}

class _RiderDashboardScreenState extends State<RiderDashboardScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() {
    final riderProvider = context.read<RiderProvider>();
    final user = context.read<AuthProvider>().currentUser;

    if (riderProvider.isOnline) {
      riderProvider.fetchAvailableRides();
    }
    if (user != null) {
      riderProvider.fetchHistory(user.id);
    }
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
    final authProvider = context.watch<AuthProvider>();
    final riderProvider = context.watch<RiderProvider>();
    final user = authProvider.currentUser;

    final pages = [
      _buildHomeView(user, riderProvider),
      const AvailableRidesScreen(),
      const RiderRideHistoryScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Row(
          children: [
            const NikhyLogo(size: NikhyLogoSize.compact, showTagline: false),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: AppTheme.primary,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'RIDER',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.8,
                ),
              ),
            ),
          ],
        ),
        actions: [
          // Switcher to Customer Mode
          Padding(
            padding: const EdgeInsets.only(right: 6),
            child: TextButton.icon(
              style: TextButton.styleFrom(
                backgroundColor: AppTheme.accent.withValues(alpha: 0.1),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                minimumSize: Size.zero,
              ),
              icon: const Icon(Icons.swap_horiz_rounded, size: 16, color: AppTheme.accent),
              label: const Text(
                'Passenger Mode',
                style: TextStyle(
                  color: AppTheme.accent,
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                ),
              ),
              onPressed: () {
                authProvider.switchActiveRole(UserRole.customer);
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const CustomerDashboardScreen()),
                );
              },
            ),
          ),
          IconButton(
            tooltip: 'Server Settings',
            icon: const Icon(Icons.tune_rounded),
            onPressed: () => ServerConfigDialog.show(context),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 14, left: 4),
            child: UserAvatar(
              user: user,
              size: 34,
              showOnlineStatus: true,
              isOnline: riderProvider.isOnline,
              onTap: () {
                setState(() => _selectedIndex = 3);
              },
            ),
          ),
        ],
      ),
      body: pages[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard_rounded),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.hail_outlined),
            selectedIcon: Icon(Icons.hail_rounded),
            label: 'Requests',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long_rounded),
            label: 'Trips',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildHomeView(UserModel? user, RiderProvider riderProvider) {
    final activeRide = riderProvider.currentAcceptedRide;
    final availableRides = riderProvider.availableRides;
    final history = riderProvider.history;

    // Calculate Summary from actual history
    final completedCount = history.where((r) => r.status == RideStatus.completed).length;
    final double totalEarnings = history
        .where((r) => r.status == RideStatus.completed)
        .fold(0.0, (sum, item) => sum + item.fare);

    return RefreshIndicator(
      onRefresh: () async {
        _loadData();
        if (activeRide != null) {
          await riderProvider.refreshCurrentRide();
        }
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Greeting Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hello, ${user?.firstName ?? "Driver"}! 🛵',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.textPrimary,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      riderProvider.isOnline
                          ? 'You are active and ready for rides'
                          : 'You are currently offline',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppTheme.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceMuted,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: Text(
                    'Driver #${user?.id ?? 201}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // Online / Offline Status Control Card (Step 12)
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: riderProvider.isOnline ? AppTheme.success : AppTheme.border,
                  width: 1.5,
                ),
                boxShadow: riderProvider.isOnline ? AppTheme.glowSuccess : AppTheme.cardShadow,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: riderProvider.isOnline
                              ? AppTheme.success.withValues(alpha: 0.14)
                              : AppTheme.surfaceMuted,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          riderProvider.isOnline
                              ? Icons.power_settings_new_rounded
                              : Icons.bedtime_outlined,
                          color: riderProvider.isOnline ? AppTheme.successDark : AppTheme.textMuted,
                          size: 26,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: riderProvider.isOnline ? AppTheme.success : AppTheme.textMuted,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                riderProvider.isOnline ? 'ONLINE' : 'OFFLINE',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                  color: riderProvider.isOnline ? AppTheme.successDark : AppTheme.textSecondary,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            riderProvider.isOnline
                                ? 'Receiving customer requests'
                                : 'Switch online to accept rides',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Transform.scale(
                    scale: 1.1,
                    child: Switch.adaptive(
                      value: riderProvider.isOnline,
                      activeColor: AppTheme.success,
                      activeTrackColor: AppTheme.success.withValues(alpha: 0.35),
                      onChanged: (val) {
                        riderProvider.toggleOnline(val);
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Today's Performance Summary (Step 11)
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppTheme.border),
                boxShadow: AppTheme.subtleShadow,
              ),
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text(
                        "TRIP SUMMARY",
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                          color: AppTheme.textMuted,
                        ),
                      ),
                      Text(
                        'All-Time Stats',
                        style: TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: _buildSummaryItem(
                          label: 'Total Trips',
                          value: '${history.length}',
                          color: AppTheme.primary,
                        ),
                      ),
                      Container(width: 1, height: 36, color: AppTheme.border),
                      Expanded(
                        child: _buildSummaryItem(
                          label: 'Completed',
                          value: '$completedCount',
                          color: AppTheme.successDark,
                        ),
                      ),
                      Container(width: 1, height: 36, color: AppTheme.border),
                      Expanded(
                        child: _buildSummaryItem(
                          label: 'Earned',
                          value: '₹${totalEarnings.toStringAsFixed(0)}',
                          color: AppTheme.accent,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),

            // Active Accepted Ride Card (if currently assigned)
            if (activeRide != null) ...[
              const SectionTitle(
                title: 'Current Assigned Trip',
                subtitle: 'Active ride requires your action',
              ),
              const SizedBox(height: 8),
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                  side: const BorderSide(color: AppTheme.accent, width: 1.5),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: AppTheme.cardShadow,
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppTheme.accent.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.electric_moped_rounded,
                                  color: AppTheme.accent,
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'Ride #${activeRide.rideId}',
                                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                              ),
                            ],
                          ),
                          StatusBadge(status: activeRide.status),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text('Pickup: ${activeRide.pickupLocation}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      Text('Drop: ${activeRide.destinationLocation}', style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
                      const SizedBox(height: 14),
                      const Divider(height: 1),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Fare: ₹${activeRide.fare.toStringAsFixed(2)}',
                            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: AppTheme.primary),
                          ),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              minimumSize: Size.zero,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            icon: const Icon(Icons.navigation_rounded, size: 14),
                            label: const Text('Manage Trip', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const RiderCurrentRideScreen(),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 22),
            ],

            // Available Ride Requests Section (Step 11 & 13)
            SectionTitle(
              title: 'Available Ride Requests',
              subtitle: riderProvider.isOnline
                  ? '${availableRides.length} incoming requests nearby'
                  : 'You are currently offline',
              actionText: riderProvider.isOnline && availableRides.isNotEmpty ? 'View All' : null,
              onAction: () => setState(() => _selectedIndex = 1),
            ),
            const SizedBox(height: 8),

            if (!riderProvider.isOnline)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppTheme.border),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.bedtime_outlined, size: 40, color: AppTheme.textMuted),
                    const SizedBox(height: 12),
                    const Text(
                      'You are Offline',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Switch online using the switch above or the button below to start receiving passenger bookings.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.success,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        minimumSize: Size.zero,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      icon: const Icon(Icons.power_settings_new_rounded, size: 16),
                      label: const Text('Go Online Now', style: TextStyle(fontWeight: FontWeight.w700)),
                      onPressed: () => riderProvider.toggleOnline(true),
                    ),
                  ],
                ),
              )
            else if (riderProvider.isLoadingAvailable && availableRides.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (availableRides.isEmpty)
              EmptyState(
                icon: Icons.hail_rounded,
                title: 'No Pending Requests',
                message: 'No ride requests available right now. Pull down to refresh.',
                actionText: 'Refresh Requests',
                onAction: () => riderProvider.fetchAvailableRides(),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: availableRides.take(3).length,
                itemBuilder: (context, index) {
                  final ride = availableRides[index];
                  return RideRequestCard(
                    ride: ride,
                    isAccepting: riderProvider.isAccepting,
                    onAccept: () => _handleAcceptRide(ride.rideId),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem({
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: color,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }
}
