import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

enum RideStatus {
  requested(1, 'REQUESTED', 'Requested'),
  searching(2, 'SEARCHING', 'Searching Driver'),
  accepted(3, 'ACCEPTED', 'Driver Accepted'),
  riderArriving(4, 'RIDER_ARRIVING', 'Driver Arriving'),
  arrived(5, 'ARRIVED', 'Driver Arrived'),
  started(6, 'STARTED', 'Trip Started'),
  completed(7, 'COMPLETED', 'Completed'),
  cancelled(8, 'CANCELLED', 'Cancelled'),
  unknown(0, 'UNKNOWN', 'Unknown');

  final int code;
  final String apiValue;
  final String displayName;

  const RideStatus(this.code, this.apiValue, this.displayName);

  static RideStatus fromDynamic(dynamic value) {
    if (value == null) return RideStatus.unknown;

    if (value is int) {
      for (final s in RideStatus.values) {
        if (s.code == value) return s;
      }
      return RideStatus.unknown;
    }

    final str = value.toString().trim().toUpperCase();
    for (final s in RideStatus.values) {
      if (s.apiValue == str || s.name.toUpperCase() == str) {
        return s;
      }
    }

    // Try parsing if string contains integer
    final parsedInt = int.tryParse(str);
    if (parsedInt != null) {
      return fromDynamic(parsedInt);
    }

    return RideStatus.unknown;
  }

  bool get isTerminal => this == RideStatus.completed || this == RideStatus.cancelled;

  bool get canCancel =>
      this == RideStatus.requested ||
      this == RideStatus.searching ||
      this == RideStatus.accepted ||
      this == RideStatus.riderArriving;

  Color get color {
    switch (this) {
      case RideStatus.requested:
        return AppTheme.info;
      case RideStatus.searching:
        return AppTheme.warning;
      case RideStatus.accepted:
        return AppTheme.accent;
      case RideStatus.riderArriving:
        return AppTheme.purple;
      case RideStatus.arrived:
        return Colors.teal;
      case RideStatus.started:
        return Colors.indigo;
      case RideStatus.completed:
        return AppTheme.success;
      case RideStatus.cancelled:
        return AppTheme.error;
      case RideStatus.unknown:
        return Colors.grey;
    }
  }

  IconData get icon {
    switch (this) {
      case RideStatus.requested:
        return Icons.hail_rounded;
      case RideStatus.searching:
        return Icons.search_rounded;
      case RideStatus.accepted:
        return Icons.check_circle_outline_rounded;
      case RideStatus.riderArriving:
        return Icons.directions_bike_rounded;
      case RideStatus.arrived:
        return Icons.pin_drop_rounded;
      case RideStatus.started:
        return Icons.navigation_rounded;
      case RideStatus.completed:
        return Icons.task_alt_rounded;
      case RideStatus.cancelled:
        return Icons.cancel_outlined;
      case RideStatus.unknown:
        return Icons.help_outline_rounded;
    }
  }

  /// Ordered lifecycle steps for timeline visualization
  static List<RideStatus> get lifecycleSteps => [
        RideStatus.requested,
        RideStatus.searching,
        RideStatus.accepted,
        RideStatus.riderArriving,
        RideStatus.arrived,
        RideStatus.started,
        RideStatus.completed,
      ];
}
