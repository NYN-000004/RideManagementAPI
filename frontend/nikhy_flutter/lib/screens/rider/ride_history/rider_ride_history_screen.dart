import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/ride_status.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/rider_provider.dart';
import '../../../widgets/empty_state.dart';
import '../../../widgets/ride_card.dart';
import '../../rides/ride_detail_screen.dart';

class RiderRideHistoryScreen extends StatefulWidget {
  const RiderRideHistoryScreen({super.key});

  @override
  State<RiderRideHistoryScreen> createState() => _RiderRideHistoryScreenState();
}

class _RiderRideHistoryScreenState extends State<RiderRideHistoryScreen> {
  String _selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadHistory();
    });
  }

  void _loadHistory() {
    final user = context.read<AuthProvider>().currentUser;
    final driverId = user?.id ?? 201;
    context.read<RiderProvider>().fetchHistory(driverId);
  }

  @override
  Widget build(BuildContext context) {
    final riderProvider = context.watch<RiderProvider>();
    final allHistory = riderProvider.history;

    final filteredHistory = allHistory.where((ride) {
      if (_selectedFilter == 'All') return true;
      if (_selectedFilter == 'Completed') return ride.status == RideStatus.completed;
      if (_selectedFilter == 'Cancelled') return ride.status == RideStatus.cancelled;
      if (_selectedFilter == 'In Progress') {
        return ride.status != RideStatus.completed && ride.status != RideStatus.cancelled;
      }
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Driver Trip History'),
        actions: [
          IconButton(
            tooltip: 'Refresh History',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _loadHistory,
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Chips
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['All', 'Completed', 'In Progress', 'Cancelled'].map((filter) {
                  final isSelected = _selectedFilter == filter;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(
                        filter,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                          color: isSelected ? Colors.white : AppTheme.textPrimary,
                        ),
                      ),
                      selected: isSelected,
                      selectedColor: AppTheme.primary,
                      backgroundColor: AppTheme.surfaceMuted,
                      side: BorderSide(
                        color: isSelected ? AppTheme.primary : AppTheme.border,
                      ),
                      onSelected: (_) {
                        setState(() => _selectedFilter = filter);
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const Divider(height: 1),

          // List content
          Expanded(
            child: riderProvider.isLoadingHistory && allHistory.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : filteredHistory.isEmpty
                    ? EmptyState(
                        icon: Icons.history_edu_rounded,
                        title: _selectedFilter == 'All'
                            ? 'No Trip History'
                            : 'No $_selectedFilter Trips',
                        message: _selectedFilter == 'All'
                            ? 'Trips you accept and complete will appear here with fare records.'
                            : 'You have no trips under the "$_selectedFilter" status filter.',
                        actionText: _selectedFilter == 'All' ? 'Find Rides' : null,
                        onAction: _selectedFilter == 'All'
                            ? () {
                                Navigator.pop(context);
                              }
                            : null,
                      )
                    : RefreshIndicator(
                        onRefresh: () async => _loadHistory(),
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          itemCount: filteredHistory.length,
                          itemBuilder: (context, index) {
                            final item = filteredHistory[index];
                            return RideCard(
                              ride: item,
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => RideDetailScreen(rideId: item.rideId),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}
