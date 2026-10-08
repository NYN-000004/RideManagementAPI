class CancelRideRequest {
  final String reason;
  final String cancelledBy;

  const CancelRideRequest({
    required this.reason,
    required this.cancelledBy,
  });

  Map<String, dynamic> toJson() {
    return {
      'reason': reason.trim(),
      'cancelledBy': cancelledBy.trim(),
    };
  }
}
