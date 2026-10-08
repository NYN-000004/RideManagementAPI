import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/user_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/ride_provider.dart';
import '../../../widgets/empty_state.dart';
import '../../../widgets/nikhy_logo.dart';
import '../../../widgets/ride_card.dart';
import '../../../widgets/section_title.dart';
import '../../../widgets/server_config_dialog.dart';
import '../../../widgets/status_badge.dart';
import '../../../widgets/user_avatar.dart';
import '../book_ride/book_ride_screen.dart';
import '../current_ride/customer_current_ride_screen.dart';
import '../ride_history/customer_ride_history_screen.dart';
import '../../rider/dashboard/rider_dashboard_screen.dart';
import '../../profile/profile_screen.dart';
import '../../rides/ride_detail_screen.dart';

class CustomerDashboardScreen extends StatefulWidget {
  const CustomerDashboardScreen({super.key});

  @override
  State<CustomerDashboardScreen> createState() => _CustomerDashboardScreenState();
}

class _CustomerDashboardScreenState extends State<CustomerDashboardScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() {
    final user = context.read<AuthProvider>().currentUser;
    if (user != null) {
      context.read<RideProvider>().fetchHistory(user.id);
    }
  }

  String _getTimeGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good morning';
    } else if (hour < 17) {
      return 'Good afternoon';
    } else {
      return 'Good evening';
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.currentUser;

    final pages = [
      _buildHomeView(user),
      _buildRidesView(),
      const CustomerRideHistoryScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const NikhyLogo(size: NikhyLogoSize.compact, showTagline: false),
        actions: [
          // Rider mode switch if user is rider
          if (user?.role == UserRole.rider)
            Padding(
              padding: const EdgeInsets.only(right: 6),
              child: TextButton.icon(
                style: TextButton.styleFrom(
                  backgroundColor: AppTheme.primary.withValues(alpha: 0.08),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  minimumSize: Size.zero,
                ),
                icon: const Icon(Icons.swap_horiz_rounded, size: 16, color: AppTheme.primary),
                label: const Text(
                  'Rider Mode',
                  style: TextStyle(
                    color: AppTheme.primary,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
                onPressed: () {
                  authProvider.switchActiveRole(UserRole.rider);
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const RiderDashboardScreen()),
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
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.two_wheeler_outlined),
            selectedIcon: Icon(Icons.two_wheeler_rounded),
            label: 'Rides',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long_rounded),
            label: 'History',
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

  Widget _buildHomeView(UserModel? user) {
    final rideProvider = context.watch<RideProvider>();
    final currentRide = rideProvider.currentRide;
    final history = rideProvider.history;

    return RefreshIndicator(
      onRefresh: () async {
        _loadData();
        if (currentRide != null) {
          await rideProvider.refreshCurrentRide();
        }
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Greeting & User Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_getTimeGreeting()}, ${user?.firstName ?? "Passenger"}! 👋',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.textPrimary,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Where would you like to go today?',
                      style: TextStyle(
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
                    '#${user?.id ?? 101}',
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

            // "Where would you like to go?" Booking Card
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.border, width: 1.2),
                boxShadow: AppTheme.cardShadow,
              ),
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.accent.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.explore_rounded,
                          color: AppTheme.accent,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'Book a Ride',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Route Input Previews
                  InkWell(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const BookRideScreen()),
                      );
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceMuted,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.border),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: const [
                              Icon(Icons.circle, size: 10, color: AppTheme.success),
                              SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Current Location / Pickup point',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.textPrimary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                const SizedBox(width: 4),
                                Container(
                                  width: 2,
                                  height: 16,
                                  color: const Color(0xFFCBD5E1),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            children: const [
                              Icon(Icons.location_on, size: 14, color: AppTheme.error),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Where to? (Destination address)',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Route chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: AppConstants.locationPresets.take(3).map((preset) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ActionChip(
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            avatar: const Icon(Icons.near_me_rounded, size: 14, color: AppTheme.accent),
                            label: Text(
                              preset['title'],
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                            ),
                            backgroundColor: AppTheme.surfaceMuted,
                            side: const BorderSide(color: AppTheme.border),
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => BookRideScreen(initialPreset: preset),
                                ),
                              );
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // BOOK A RIDE Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      icon: const Icon(Icons.search_rounded, size: 18),
                      label: const Text(
                        'BOOK A RIDE',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                          fontSize: 14,
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const BookRideScreen()),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Active / Current Ride Banner (if active)
            if (currentRide != null) ...[
              const SectionTitle(
                title: 'Active Trip',
                subtitle: 'Your ride is currently in progress',
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
                                'Ride #${currentRide.rideId}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                            ],
                          ),
                          StatusBadge(status: currentRide.status),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'Pickup: ${currentRide.pickupLocation}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Drop: ${currentRide.destinationLocation}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 14),
                      const Divider(height: 1),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Fare: ₹${currentRide.fare.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                              color: AppTheme.primary,
                            ),
                          ),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.accent,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              minimumSize: Size.zero,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            icon: const Icon(Icons.navigation_rounded, size: 14),
                            label: const Text(
                              'Track Ride',
                              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                            ),
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => CustomerCurrentRideScreen(rideId: currentRide.rideId),
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
              const SizedBox(height: 24),
            ],

            // Quick Actions Row
            const SectionTitle(
              title: 'Quick Actions',
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildQuickActionTile(
                    icon: Icons.add_location_alt_rounded,
                    title: 'Book Ride',
                    subtitle: 'Choose destination',
                    color: AppTheme.accent,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const BookRideScreen()),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildQuickActionTile(
                    icon: Icons.history_rounded,
                    title: 'Ride History',
                    subtitle: 'Past completed trips',
                    color: AppTheme.success,
                    onTap: () {
                      setState(() => _selectedIndex = 2);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 26),

            // Recent Bookings Section
            SectionTitle(
              title: 'Recent Bookings',
              subtitle: 'Your recent rides and receipts',
              actionText: history.isNotEmpty ? 'View All' : null,
              onAction: () => setState(() => _selectedIndex = 2),
            ),
            const SizedBox(height: 8),

            if (rideProvider.isLoadingHistory && history.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (history.isEmpty)
              EmptyState(
                icon: Icons.two_wheeler_outlined,
                title: 'No Rides Yet',
                message: 'No rides booked yet. Book your first ride with NIKHY today!',
                actionText: 'Book a Ride',
                onAction: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const BookRideScreen()),
                  );
                },
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: history.take(4).length,
                itemBuilder: (context, index) {
                  final ride = history[index];
                  return RideCard(
                    ride: ride,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => RideDetailScreen(rideId: ride.rideId),
                        ),
                      );
                    },
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRidesView() {
    final rideProvider = context.watch<RideProvider>();
    final currentRide = rideProvider.currentRide;

    if (currentRide != null) {
      return CustomerCurrentRideScreen(
        rideId: currentRide.rideId,
        isEmbedded: true,
      );
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppTheme.surfaceMuted,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.electric_moped_outlined,
                size: 40,
                color: AppTheme.accent,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'No Active Ride',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'You currently do not have any ongoing ride. Request a ride to track it live here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              icon: const Icon(Icons.add_location_alt_rounded, size: 18),
              label: const Text('Book a Ride Now'),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const BookRideScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppTheme.border),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: AppTheme.subtleShadow,
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
