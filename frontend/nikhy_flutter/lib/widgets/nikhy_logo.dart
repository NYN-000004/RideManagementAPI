import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

enum NikhyLogoSize {
  compact, // For AppBars (height ~32)
  normal,  // For section headers / cards (height ~48)
  large,   // For splash & auth screens (height ~96)
}

class NikhyLogo extends StatelessWidget {
  final NikhyLogoSize size;
  final bool isLight; // White text / light mode on dark background
  final bool showTagline;

  const NikhyLogo({
    super.key,
    this.size = NikhyLogoSize.normal,
    this.isLight = false,
    this.showTagline = true,
  });

  @override
  Widget build(BuildContext context) {
    switch (size) {
      case NikhyLogoSize.compact:
        return _buildCompact();
      case NikhyLogoSize.normal:
        return _buildNormal();
      case NikhyLogoSize.large:
        return _buildLarge();
    }
  }

  Widget _buildCompact() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppTheme.primary, AppTheme.indigo],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(9),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primary.withValues(alpha: 0.2),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Center(
            child: Icon(
              Icons.two_wheeler_rounded,
              color: Colors.white,
              size: 18,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          'NIKHY',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.2,
            color: isLight ? Colors.white : AppTheme.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildNormal() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppTheme.primary, AppTheme.accent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(13),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primary.withValues(alpha: 0.25),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Center(
            child: Icon(
              Icons.two_wheeler_rounded,
              color: Colors.white,
              size: 26,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'NIKHY',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
                color: isLight ? Colors.white : AppTheme.primary,
                height: 1.1,
              ),
            ),
            if (showTagline)
              Text(
                'RIDE MANAGEMENT',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                  color: isLight ? Colors.white70 : AppTheme.accent,
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildLarge() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppTheme.primaryLight, AppTheme.primaryDark],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.15),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                right: 12,
                top: 12,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppTheme.success,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              const Center(
                child: Icon(
                  Icons.two_wheeler_rounded,
                  color: Colors.white,
                  size: 50,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'NIKHY',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w900,
            letterSpacing: 3,
            color: isLight ? Colors.white : AppTheme.primary,
          ),
        ),
        if (showTagline) ...[
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: (isLight ? Colors.white : AppTheme.accent).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'RIDE MANAGEMENT',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 2,
                color: isLight ? Colors.white.withValues(alpha: 0.9) : AppTheme.accent,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
