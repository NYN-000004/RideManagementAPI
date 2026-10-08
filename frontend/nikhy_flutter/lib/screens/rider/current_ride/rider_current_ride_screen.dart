import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../models/ride_status.dart';
import '../../../providers/rider_provider.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/empty_state.dart';
import '../../../widgets/ride_status_timeline.dart';
import '../../../widgets/status_badge.dart';

class RiderCurrentRideScreen extends StatefulWidget {
  const RiderCurrentRideScreen({super.key});

  @override
  State<RiderCurrentRideScreen> createState() => _RiderCurrentRideScreenState();
}

class _RiderCurrentRideScreenState extends State<RiderCurrentRideScreen> {
  void _showCancelDialog() {
    final reasonController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Cancel Accepted Ride'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Please specify the reason for cancelling this booking:',
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
                  hintText: 'e.g., Vehicle mechanical issue / Road blocked',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Keep Trip'),
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

                final riderProvider = context.read<RiderProvider>();
                final success = await riderProvider.cancelRide(reason);

                if (mounted && success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Trip was cancelled.'),
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
    final riderProvider = context.watch<RiderProvider>();
    final ride = riderProvider.currentAcceptedRide;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(ride != null ? 'Trip #${ride.rideId}' : 'Current Trip'),
        actions: [
          if (ride != null)
            IconButton(
              tooltip: 'Refresh Ride',
              icon: const Icon(Icons.refresh_rounded),
              onPressed: () => riderProvider.refreshCurrentRide(),
            ),
        ],
      ),
      body: ride == null
          ? EmptyState(
              icon: Icons.electric_moped_outlined,
              title: 'No Active Accepted Trip',
              message: 'You currently have no active ride assigned. Go to Available Requests to accept a booking.',
              actionText: 'Find Rides',
              onAction: () => Navigator.pop(context),
            )
          : RefreshIndicator(
              onRefresh: () => riderProvider.refreshCurrentRide(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 540),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Error Banner if update fails
                        if (riderProvider.errorMessage != null) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            decoration: BoxDecoration(
                              color: AppTheme.error.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppTheme.error.withValues(alpha: 0.3)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.error_outline_rounded, color: AppTheme.error, size: 20),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    riderProvider.errorMessage!,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: AppTheme.error,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],

                        // Top Status Header Card
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

                        // Route & Navigation Card
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
                                  'Navigation & Addresses',
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
                                          height: 48,
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
                                            'PICKUP (Customer Waiting)',
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
                                          Text(
                                            'GPS: ${ride.pickupLatitude.toStringAsFixed(4)}, ${ride.pickupLongitude.toStringAsFixed(4)}',
                                            style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
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
                                          Text(
                                            'GPS: ${ride.destinationLatitude.toStringAsFixed(4)}, ${ride.destinationLongitude.toStringAsFixed(4)}',
                                            style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
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

                        // Booking & Fare Information Card
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
                                      'Trip Details',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                        color: AppTheme.textPrimary,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: AppTheme.success.withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        'Fare: ₹${ride.fare.toStringAsFixed(2)}',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w900,
                                          color: AppTheme.successDark,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                _buildInfoRow('Passenger ID', '#${ride.passengerId}'),
                                _buildInfoRow('Driver ID', '#${ride.driverId ?? "You"}'),
                                if (ride.distance != null)
                                  _buildInfoRow('Trip Distance', '${ride.distance} km'),
                                if (ride.estimatedDuration != null)
                                  _buildInfoRow('Estimated Duration', '${ride.estimatedDuration} mins'),
                                _buildInfoRow('Requested At', DateFormatter.formatDateTime(ride.requestedAt)),
                                if (ride.acceptedAt != null)
                                  _buildInfoRow('Accepted At', DateFormatter.formatDateTime(ride.acceptedAt)),
                                if (ride.startedAt != null)
                                  _buildInfoRow('Started At', DateFormatter.formatDateTime(ride.startedAt)),
                                if (ride.completedAt != null)
                                  _buildInfoRow('Completed At', DateFormatter.formatDateTime(ride.completedAt)),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),

                        // Lifecycle Progress Card
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
                                  'Lifecycle Status',
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

                        // Action Buttons based on Lifecycle state (Step 14)
                        _buildDriverActionButtons(ride, riderProvider),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildDriverActionButtons(dynamic ride, RiderProvider provider) {
    switch (ride.status) {
      case RideStatus.accepted:
        return Column(
          children: [
            AppButton(
              text: 'MARK ARRIVING AT PICKUP',
              icon: Icons.directions_bike_rounded,
              backgroundColor: AppTheme.accent,
              isLoading: provider.isUpdatingStatus,
              onPressed: () => provider.markArriving(),
            ),
            const SizedBox(height: 12),
            AppButton(
              text: 'Cancel Ride',
              isOutlined: true,
              backgroundColor: AppTheme.error,
              textColor: AppTheme.error,
              isLoading: provider.isUpdatingStatus,
              onPressed: _showCancelDialog,
            ),
          ],
        );

      case RideStatus.riderArriving:
        return Column(
          children: [
            AppButton(
              text: 'MARK ARRIVED AT PICKUP',
              icon: Icons.pin_drop_rounded,
              backgroundColor: Colors.teal,
              isLoading: provider.isUpdatingStatus,
              onPressed: () => provider.markArrived(),
            ),
            const SizedBox(height: 12),
            AppButton(
              text: 'Cancel Ride',
              isOutlined: true,
              backgroundColor: AppTheme.error,
              textColor: AppTheme.error,
              isLoading: provider.isUpdatingStatus,
              onPressed: _showCancelDialog,
            ),
          ],
        );

      case RideStatus.arrived:
        return AppButton(
          text: 'START TRIP',
          icon: Icons.navigation_rounded,
          backgroundColor: Colors.indigo,
          isLoading: provider.isUpdatingStatus,
          onPressed: () => provider.startTrip(),
        );

      case RideStatus.started:
        return AppButton(
          text: 'COMPLETE TRIP',
          icon: Icons.task_alt_rounded,
          backgroundColor: AppTheme.success,
          isLoading: provider.isUpdatingStatus,
          onPressed: () => provider.completeTrip(),
        );

      case RideStatus.completed:
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.success.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppTheme.success.withValues(alpha: 0.3)),
          ),
          child: Column(
            children: [
              const Icon(Icons.check_circle_rounded, color: AppTheme.success, size: 40),
              const SizedBox(height: 10),
              const Text(
                'Trip Completed Successfully!',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17, color: AppTheme.successDark),
              ),
              const SizedBox(height: 4),
              Text(
                'Fare Earned: ₹${ride.fare.toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: AppTheme.textPrimary),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  provider.clearCurrentRide();
                  Navigator.pop(context);
                },
                child: const Text('Back to Dashboard'),
              ),
            ],
          ),
        );

      case RideStatus.cancelled:
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.error.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppTheme.error.withValues(alpha: 0.3)),
          ),
          child: Column(
            children: [
              const Icon(Icons.cancel_outlined, color: AppTheme.error, size: 40),
              const SizedBox(height: 10),
              const Text(
                'Trip Was Cancelled',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17, color: AppTheme.error),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  provider.clearCurrentRide();
                  Navigator.pop(context);
                },
                child: const Text('Back to Dashboard'),
              ),
            ],
          ),
        );

      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
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
