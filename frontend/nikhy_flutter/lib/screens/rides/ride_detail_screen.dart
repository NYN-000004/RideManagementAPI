import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/rider_avatar_presets.dart';
import '../../core/storage/storage_service.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/date_formatter.dart';
import '../../models/ride_model.dart';
import '../../repositories/ride_repository.dart';
import '../../widgets/error_state.dart';
import '../../widgets/ride_status_timeline.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/user_avatar.dart';

class RideDetailScreen extends StatefulWidget {
  final int rideId;

  const RideDetailScreen({super.key, required this.rideId});

  @override
  State<RideDetailScreen> createState() => _RideDetailScreenState();
}

class _RideDetailScreenState extends State<RideDetailScreen> {
  RideModel? _ride;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchDetails();
  }

  Future<void> _fetchDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final repository = context.read<RideRepository>();
      final ride = await repository.getRideById(widget.rideId);
      setState(() {
        _ride = ride;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text('Ride #${widget.rideId} Details'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _fetchDetails,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null || _ride == null
              ? ErrorState(
                  title: 'Unable to Load Ride',
                  message: _errorMessage ?? 'Ride details could not be retrieved from the server.',
                  onRetry: _fetchDetails,
                )
              : RefreshIndicator(
                  onRefresh: _fetchDetails,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 540),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Status Header Banner
                            Container(
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: _ride!.status.color.withValues(alpha: 0.35),
                                  width: 1.5,
                                ),
                                boxShadow: AppTheme.cardShadow,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'TOTAL FARE',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: 0.8,
                                          color: AppTheme.textMuted,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '₹${_ride!.fare.toStringAsFixed(2)}',
                                        style: const TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.w900,
                                          color: AppTheme.primary,
                                          letterSpacing: -0.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                  StatusBadge(status: _ride!.status, fontSize: 13),
                                ],
                              ),
                            ),
                            const SizedBox(height: 18),

                            // Route Card
                            Card(
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                                side: const BorderSide(color: AppTheme.border),
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(18),
                                  boxShadow: AppTheme.subtleShadow,
                                ),
                                padding: const EdgeInsets.all(18),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Trip Route',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                        color: AppTheme.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Column(
                                          children: [
                                            const Icon(Icons.circle, size: 12, color: AppTheme.success),
                                            Container(
                                              width: 2,
                                              height: 38,
                                              color: const Color(0xFFCBD5E1),
                                            ),
                                            const Icon(Icons.location_on, size: 14, color: AppTheme.error),
                                          ],
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'PICKUP',
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w800,
                                                  letterSpacing: 0.8,
                                                  color: AppTheme.textMuted,
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                _ride!.pickupLocation,
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w700,
                                                  color: AppTheme.textPrimary,
                                                ),
                                              ),
                                              const SizedBox(height: 14),
                                              Text(
                                                'DESTINATION',
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w800,
                                                  letterSpacing: 0.8,
                                                  color: AppTheme.textMuted,
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                _ride!.destinationLocation,
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w700,
                                                  color: AppTheme.textPrimary,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 18),

                            // Booking Information Card
                            Card(
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                                side: const BorderSide(color: AppTheme.border),
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(18),
                                  boxShadow: AppTheme.subtleShadow,
                                ),
                                padding: const EdgeInsets.all(18),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Trip Details',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                        color: AppTheme.textPrimary,
                                      ),
                                    ),
                                    if (_ride!.driverId != null) ...[
                                      const SizedBox(height: 12),
                                      Builder(builder: (context) {
                                        final storage = context.read<StorageService>();
                                        final avatarUrl = storage.getDriverAvatar(_ride!.driverId!) ??
                                            RiderAvatarPresets.getDefaultAvatarForDriver(_ride!.driverId!);
                                        return Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: AppTheme.surfaceMuted,
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(color: AppTheme.border),
                                          ),
                                          child: Row(
                                            children: [
                                              UserAvatar(
                                                imageUrl: avatarUrl,
                                                name: 'Captain ${_ride!.driverId}',
                                                size: 46,
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Text(
                                                          'Captain #${_ride!.driverId}',
                                                          style: const TextStyle(
                                                            fontSize: 14.5,
                                                            fontWeight: FontWeight.w800,
                                                            color: AppTheme.textPrimary,
                                                          ),
                                                        ),
                                                        const SizedBox(width: 6),
                                                        Container(
                                                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                                          decoration: BoxDecoration(
                                                            color: AppTheme.success.withValues(alpha: 0.12),
                                                            borderRadius: BorderRadius.circular(4),
                                                          ),
                                                          child: const Text(
                                                            'VERIFIED',
                                                            style: TextStyle(
                                                              fontSize: 9.5,
                                                              fontWeight: FontWeight.w800,
                                                              color: AppTheme.success,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 2),
                                                    const Text(
                                                      '4.9 ★ • Motorcycle KA-05-EV-4421',
                                                      style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }),
                                    ],
                                    const SizedBox(height: 12),
                                    _buildRow('Ride ID', '#${_ride!.rideId}'),
                                    if (_ride!.bookingId != null)
                                       _buildRow('Booking ID', '#${_ride!.bookingId}'),
                                    _buildRow('Passenger ID', '#${_ride!.passengerId}'),
                                    if (_ride!.driverId != null)
                                      _buildRow('Driver ID', '#${_ride!.driverId}'),
                                    if (_ride!.distance != null)
                                      _buildRow('Distance', '${_ride!.distance} km'),
                                    if (_ride!.estimatedDuration != null)
                                      _buildRow('Estimated Time', '${_ride!.estimatedDuration} mins'),
                                    _buildRow('Requested At', DateFormatter.formatDateTime(_ride!.requestedAt)),
                                    if (_ride!.acceptedAt != null)
                                      _buildRow('Accepted At', DateFormatter.formatDateTime(_ride!.acceptedAt)),
                                    if (_ride!.startedAt != null)
                                      _buildRow('Started At', DateFormatter.formatDateTime(_ride!.startedAt)),
                                    if (_ride!.completedAt != null)
                                      _buildRow('Completed At', DateFormatter.formatDateTime(_ride!.completedAt)),
                                    if (_ride!.cancelledAt != null) ...[
                                      _buildRow('Cancelled At', DateFormatter.formatDateTime(_ride!.cancelledAt)),
                                      if (_ride!.cancellationReason != null)
                                        _buildRow('Cancel Reason', _ride!.cancellationReason!),
                                      if (_ride!.cancelledBy != null)
                                        _buildRow('Cancelled By', _ride!.cancelledBy!),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 18),

                            // Lifecycle Timeline Card
                            Card(
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                                side: const BorderSide(color: AppTheme.border),
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(18),
                                  boxShadow: AppTheme.subtleShadow,
                                ),
                                padding: const EdgeInsets.all(18),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Lifecycle History',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                        color: AppTheme.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    RideStatusTimeline(currentStatus: _ride!.status),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
