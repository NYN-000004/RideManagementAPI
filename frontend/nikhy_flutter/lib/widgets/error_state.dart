import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

class ErrorState extends StatelessWidget {
  final String title;
  final String message;
  final String actionText;
  final VoidCallback? onRetry;
  final IconData icon;

  const ErrorState({
    super.key,
    this.title = 'Something Went Wrong',
    this.message = 'Unable to connect to the server. Please check your connection and try again.',
    this.actionText = 'Try Again',
    this.onRetry,
    this.icon = Icons.error_outline_rounded,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: AppTheme.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppTheme.error.withValues(alpha: 0.25),
                  width: 1.5,
                ),
              ),
              child: Center(
                child: Icon(
                  icon,
                  size: 38,
                  color: AppTheme.error,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
                height: 1.4,
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  minimumSize: Size.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: Text(actionText),
                onPressed: onRetry,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
