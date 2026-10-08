import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../models/ride_status.dart';

class RideStatusTimeline extends StatelessWidget {
  final RideStatus currentStatus;

  const RideStatusTimeline({
    super.key,
    required this.currentStatus,
  });

  @override
  Widget build(BuildContext context) {
    if (currentStatus == RideStatus.cancelled) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.error.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.error.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.error.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.cancel_rounded, color: AppTheme.error, size: 24),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Trip Cancelled',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.error,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'This ride lifecycle has ended.',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    final steps = RideStatus.lifecycleSteps;
    final currentIndex = steps.indexOf(currentStatus);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (int i = 0; i < steps.length; i++)
            _buildTimelineStep(
              step: steps[i],
              stepIndex: i,
              currentIndex: currentIndex,
              isLast: i == steps.length - 1,
            ),
        ],
      ),
    );
  }

  Widget _buildTimelineStep({
    required RideStatus step,
    required int stepIndex,
    required int currentIndex,
    required bool isLast,
  }) {
    final bool isCompleted = stepIndex < currentIndex;
    final bool isCurrent = stepIndex == currentIndex;

    final Color dotColor = isCurrent
        ? step.color
        : (isCompleted ? AppTheme.success : const Color(0xFFCBD5E1));

    final Color textColor = isCurrent
        ? AppTheme.textPrimary
        : (isCompleted ? AppTheme.textSecondary : AppTheme.textMuted);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Indicator column (circle + connector line)
        SizedBox(
          width: 28,
          child: Column(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: isCurrent
                      ? dotColor.withValues(alpha: 0.18)
                      : (isCompleted ? dotColor : Colors.transparent),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: dotColor,
                    width: isCurrent ? 2.5 : 2,
                  ),
                ),
                child: Center(
                  child: isCompleted
                      ? const Icon(Icons.check, size: 14, color: Colors.white)
                      : (isCurrent
                          ? Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: dotColor,
                                shape: BoxShape.circle,
                              ),
                            )
                          : null),
                ),
              ),
              if (!isLast)
                Container(
                  width: 2,
                  height: 30,
                  color: isCompleted ? AppTheme.success : const Color(0xFFE2E8F0),
                ),
            ],
          ),
        ),
        const SizedBox(width: 14),

        // Step details
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      step.displayName,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: isCurrent
                            ? FontWeight.w800
                            : (isCompleted ? FontWeight.w600 : FontWeight.w500),
                        color: textColor,
                      ),
                    ),
                    if (isCurrent) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: step.color.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: step.color.withValues(alpha: 0.3)),
                        ),
                        child: Text(
                          'CURRENT',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                            color: step.color,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                if (!isLast) const SizedBox(height: 18),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
