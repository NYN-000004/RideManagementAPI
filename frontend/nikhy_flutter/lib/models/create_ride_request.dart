class CreateRideRequest {
  final int? bookingId;
  final int passengerId;
  final String pickupLocation;
  final String destinationLocation;
  final double pickupLatitude;
  final double pickupLongitude;
  final double destinationLatitude;
  final double destinationLongitude;
  final double fare;
  final double? distance;
  final int? estimatedDuration;

  const CreateRideRequest({
    this.bookingId,
    required this.passengerId,
    required this.pickupLocation,
    required this.destinationLocation,
    required this.pickupLatitude,
    required this.pickupLongitude,
    required this.destinationLatitude,
    required this.destinationLongitude,
    required this.fare,
    this.distance,
    this.estimatedDuration,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'passengerId': passengerId,
      'pickupLocation': pickupLocation.trim(),
      'destinationLocation': destinationLocation.trim(),
      'pickupLatitude': pickupLatitude,
      'pickupLongitude': pickupLongitude,
      'destinationLatitude': destinationLatitude,
      'destinationLongitude': destinationLongitude,
      'fare': fare,
    };

    if (bookingId != null) {
      map['bookingId'] = bookingId;
    }
    if (distance != null) {
      map['distance'] = distance;
    }
    if (estimatedDuration != null) {
      map['estimatedDuration'] = estimatedDuration;
    }

    return map;
  }
}
