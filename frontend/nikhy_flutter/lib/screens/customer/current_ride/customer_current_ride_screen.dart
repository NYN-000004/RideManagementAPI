import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/rider_avatar_presets.dart';
import '../../../core/storage/storage_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../models/ride_status.dart';
import '../../../providers/ride_provider.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/ride_status_timeline.dart';
import '../../../widgets/status_badge.dart';
import '../../../widgets/user_avatar.dart';

class CustomerCurrentRideScreen extends StatefulWidget {
  final int rideId;
  final bool isEmbedded;

  const CustomerCurrentRideScreen({
    super.key,
    required this.rideId,
    this.isEmbedded = false,
  });

  @override
  State<CustomerCurrentRideScreen> createState() => _CustomerCurrentRideScreenState();
}

class _CustomerCurrentRideScreenState extends State<CustomerCurrentRideScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RideProvider>().fetchRideDetails(widget.rideId);
    });
  }

  void _showCancelDialog() {
    final reasonController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Cancel Ride Booking'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Please provide a reason for cancelling this trip:',
                style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: reasonController,
                maxLines: 3,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Cancellation reason is required';
                  }
                  return null;
                },
                decoration: const InputDecoration(
                  hintText: 'e.g., Change of plans / Wait time too long',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Keep Ride'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.error,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                final reason = reasonController.text.trim();
                Navigator.pop(dialogCtx);

                final rideProvider = context.read<RideProvider>();
                final success = await rideProvider.cancelActiveRide(
                  rideId: widget.rideId,
                  reason: reason,
                  cancelledBy: 'Passenger',
                );

                if (mounted && success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Ride booking was cancelled.'),
                      backgroundColor: AppTheme.warning,
                    ),
                  );
                }
              }
            },
            child: const Text('Confirm Cancel'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final rideProvider = context.watch<RideProvider>();
    final ride = rideProvider.currentRide;

    final body = rideProvider.isLoadingDetails && ride == null
        ? const Center(child: CircularProgressIndicator())
        : ride == null
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline_rounded, size: 48, color: AppTheme.error),
                      const SizedBox(height: 12),
                      const Text(
                        'Failed to load ride details.',
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                      ),
                      const SizedBox(height: 14),
                      ElevatedButton(
                        onPressed: () => rideProvider.fetchRideDetails(widget.rideId),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              )
            : RefreshIndicator(
                onRefresh: () => rideProvider.fetchRideDetails(widget.rideId),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 540),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Status Header Card
                          Container(
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: ride.status.color.withValues(alpha: 0.35),
                                width: 1.5,
                              ),
                              boxShadow: AppTheme.cardShadow,
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: ride.status.color.withValues(alpha: 0.12),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(ride.status.icon, color: ride.status.color, size: 26),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Trip Status',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: 0.5,
                                          color: AppTheme.textMuted,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        ride.status.displayName,
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w900,
                                          color: ride.status.color,
                                          letterSpacing: -0.3,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                StatusBadge(status: ride.status),
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
                                              ride.pickupLocation,
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
                                              ride.destinationLocation,
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

                          // Driver / Captain Identification Card (for easy customer identification)
                          if (ride.driverId != null) ...[
                            _buildDriverIdentificationCard(context, ride.driverId!),
                            const SizedBox(height: 18),
                          ],

                          // Driver & Booking Information Card
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
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'Booking & Driver Info',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w800,
                                          color: AppTheme.textPrimary,
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: AppTheme.surfaceMuted,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          'Fare: ₹${ride.fare.toStringAsFixed(2)}',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w900,
                                            color: AppTheme.primary,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 14),
                                  _buildDetailRow('Ride ID', '#${ride.rideId}'),
                                  if (ride.bookingId != null)
                                    _buildDetailRow('Booking ID', '#${ride.bookingId}'),
                                  _buildDetailRow('Passenger ID', '#${ride.passengerId}'),
                                  _buildDetailRow(
                                    'Driver Assignment',
                                    ride.driverId != null ? 'Driver #${ride.driverId}' : 'Searching nearby drivers...',
                                    valueColor: ride.driverId != null ? AppTheme.primary : AppTheme.warning,
                                  ),
                                  if (ride.distance != null)
                                    _buildDetailRow('Estimated Distance', '${ride.distance} km'),
                                  if (ride.estimatedDuration != null)
                                    _buildDetailRow('Estimated Time', '${ride.estimatedDuration} mins'),
                                  _buildDetailRow('Requested At', DateFormatter.formatDateTime(ride.requestedAt)),
                                  if (ride.acceptedAt != null)
                                    _buildDetailRow('Accepted At', DateFormatter.formatDateTime(ride.acceptedAt)),
                                  if (ride.startedAt != null)
                                    _buildDetailRow('Started At', DateFormatter.formatDateTime(ride.startedAt)),
                                  if (ride.completedAt != null)
                                    _buildDetailRow('Completed At', DateFormatter.formatDateTime(ride.completedAt)),
                                  if (ride.cancelledAt != null) ...[
                                    _buildDetailRow('Cancelled At', DateFormatter.formatDateTime(ride.cancelledAt)),
                                    if (ride.cancellationReason != null)
                                      _buildDetailRow('Reason', ride.cancellationReason!),
                                    if (ride.cancelledBy != null)
                                      _buildDetailRow('Cancelled By', ride.cancelledBy!),
                                  ],
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),

                          // Lifecycle Progress Timeline Card
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
                                    'Ride Progress Lifecycle',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                      color: AppTheme.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  RideStatusTimeline(currentStatus: ride.status),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Cancel Ride Action (if permitted)
                          if (ride.status.canCancel) ...[
                            AppButton(
                              text: 'Cancel Ride Booking',
                              isOutlined: true,
                              backgroundColor: AppTheme.error,
                              textColor: AppTheme.error,
                              icon: Icons.cancel_outlined,
                              isLoading: rideProvider.isCancelling,
                              onPressed: _showCancelDialog,
                            ),
                            const SizedBox(height: 10),
                            const Center(
                              child: Text(
                                'Rides can be cancelled until the driver arrives at pickup.',
                                style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                              ),
                            ),
                          ] else if (ride.status == RideStatus.completed) ...[
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                color: AppTheme.success.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: AppTheme.success.withValues(alpha: 0.3)),
                              ),
                              child: Column(
                                children: const [
                                  Icon(Icons.check_circle_rounded, color: AppTheme.success, size: 36),
                                  SizedBox(height: 8),
                                  Text(
                                    'Trip Completed Successfully!',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 16,
                                      color: AppTheme.successDark,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Thank you for riding with NIKHY.',
                                    style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ),
              );

    if (widget.isEmbedded) {
      return body;
    }

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text('Ride #${widget.rideId}'),
        actions: [
          IconButton(
            tooltip: 'Refresh Status',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => rideProvider.fetchRideDetails(widget.rideId),
          ),
        ],
      ),
      body: body,
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              color: valueColor ?? AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDriverIdentificationCard(BuildContext context, int driverId) {
    final storageService = context.read<StorageService>();
    final savedAvatar = storageService.getDriverAvatar(driverId);
    final avatarUrl = savedAvatar ?? RiderAvatarPresets.getDefaultAvatarForDriver(driverId);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: AppTheme.border),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: AppTheme.cardShadow,
        ),
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                UserAvatar(
                  imageUrl: avatarUrl,
                  name: 'Captain $driverId',
                  size: 64,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              'Captain #$driverId',
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w900,
                                color: AppTheme.textPrimary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                            decoration: BoxDecoration(
                              color: AppTheme.success.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.verified_rounded, size: 12, color: AppTheme.success),
                                SizedBox(width: 3),
                                Text(
                                  'Verified',
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w800,
                                    color: AppTheme.success,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.star_rounded, size: 16, color: Color(0xFFF59E0B)),
                          const SizedBox(width: 3),
                          const Text(
                            '4.9',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '• 240+ completed trips',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      const Text(
                        'Motorcycle • KA-05-EV-4421',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppTheme.primary.withValues(alpha: 0.15)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.face_retouching_natural_rounded, size: 17, color: AppTheme.primary),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Rider Photo Identification: Verify your captain\'s face before boarding for safe transit.',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      side: const BorderSide(color: AppTheme.border),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: const Icon(Icons.call_outlined, size: 16, color: AppTheme.primary),
                    label: const Text(
                      'Call Captain',
                      style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Calling Captain #$driverId...'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      side: const BorderSide(color: AppTheme.border),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: const Icon(Icons.chat_bubble_outline_rounded, size: 16, color: AppTheme.primary),
                    label: const Text(
                      'Send Message',
                      style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Opening chat with Captain #$driverId...'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

