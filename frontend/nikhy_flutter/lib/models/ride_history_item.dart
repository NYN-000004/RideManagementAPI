import 'ride_status.dart';

class RideHistoryItem {
  final int rideId;
  final String pickupLocation;
  final String destinationLocation;
  final RideStatus status;
  final double fare;
  final DateTime requestedAt;
  final DateTime? completedAt;
  final DateTime? cancelledAt;

  const RideHistoryItem({
    required this.rideId,
    required this.pickupLocation,
    required this.destinationLocation,
    required this.status,
    required this.fare,
    required this.requestedAt,
    this.completedAt,
    this.cancelledAt,
  });

  factory RideHistoryItem.fromJson(Map<String, dynamic> json) {
    return RideHistoryItem(
      rideId: (json['rideId'] as num).toInt(),
      pickupLocation: json['pickupLocation'] as String? ?? '',
      destinationLocation: json['destinationLocation'] as String? ?? '',
      status: RideStatus.fromDynamic(json['status']),
      fare: (json['fare'] as num?)?.toDouble() ?? 0.0,
      requestedAt: DateTime.tryParse(json['requestedAt']?.toString() ?? '') ?? DateTime.now(),
      completedAt: json['completedAt'] != null ? DateTime.tryParse(json['completedAt'].toString()) : null,
      cancelledAt: json['cancelledAt'] != null ? DateTime.tryParse(json['cancelledAt'].toString()) : null,
    );
  }
}
