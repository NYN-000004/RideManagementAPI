import 'ride_status.dart';

class RideModel {
  final int rideId;
  final int? bookingId;
  final int passengerId;
  final int? driverId;
  final String pickupLocation;
  final String destinationLocation;
  final double pickupLatitude;
  final double pickupLongitude;
  final double destinationLatitude;
  final double destinationLongitude;
  final RideStatus status;
  final double fare;
  final double? distance;
  final int? estimatedDuration;
  final DateTime requestedAt;
  final DateTime? acceptedAt;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final DateTime? cancelledAt;
  final String? cancellationReason;
  final String? cancelledBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  const RideModel({
    required this.rideId,
    this.bookingId,
    required this.passengerId,
    this.driverId,
    required this.pickupLocation,
    required this.destinationLocation,
    required this.pickupLatitude,
    required this.pickupLongitude,
    required this.destinationLatitude,
    required this.destinationLongitude,
    required this.status,
    required this.fare,
    this.distance,
    this.estimatedDuration,
    required this.requestedAt,
    this.acceptedAt,
    this.startedAt,
    this.completedAt,
    this.cancelledAt,
    this.cancellationReason,
    this.cancelledBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory RideModel.fromJson(Map<String, dynamic> json) {
    return RideModel(
      rideId: (json['rideId'] as num).toInt(),
      bookingId: (json['bookingId'] as num?)?.toInt(),
      passengerId: (json['passengerId'] as num).toInt(),
      driverId: (json['driverId'] as num?)?.toInt(),
      pickupLocation: json['pickupLocation'] as String? ?? '',
      destinationLocation: json['destinationLocation'] as String? ?? '',
      pickupLatitude: (json['pickupLatitude'] as num?)?.toDouble() ?? 0.0,
      pickupLongitude: (json['pickupLongitude'] as num?)?.toDouble() ?? 0.0,
      destinationLatitude: (json['destinationLatitude'] as num?)?.toDouble() ?? 0.0,
      destinationLongitude: (json['destinationLongitude'] as num?)?.toDouble() ?? 0.0,
      status: RideStatus.fromDynamic(json['status']),
      fare: (json['fare'] as num?)?.toDouble() ?? 0.0,
      distance: (json['distance'] as num?)?.toDouble(),
      estimatedDuration: (json['estimatedDuration'] as num?)?.toInt(),
      requestedAt: DateTime.tryParse(json['requestedAt']?.toString() ?? '') ?? DateTime.now(),
      acceptedAt: json['acceptedAt'] != null ? DateTime.tryParse(json['acceptedAt'].toString()) : null,
      startedAt: json['startedAt'] != null ? DateTime.tryParse(json['startedAt'].toString()) : null,
      completedAt: json['completedAt'] != null ? DateTime.tryParse(json['completedAt'].toString()) : null,
      cancelledAt: json['cancelledAt'] != null ? DateTime.tryParse(json['cancelledAt'].toString()) : null,
      cancellationReason: json['cancellationReason'] as String?,
      cancelledBy: json['cancelledBy'] as String?,
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt']?.toString() ?? '') ?? DateTime.now(),
    );
  }
}
