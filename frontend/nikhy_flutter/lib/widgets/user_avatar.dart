import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../models/user_model.dart';

class UserAvatar extends StatelessWidget {
  final UserModel? user;
  final String? imageUrl;
  final String? name;
  final double size;
  final bool showOnlineStatus;
  final bool isOnline;
  final bool showEditBadge;
  final VoidCallback? onTap;
  final VoidCallback? onEditTap;

  const UserAvatar({
    super.key,
    this.user,
    this.imageUrl,
    this.name,
    this.size = 44,
    this.showOnlineStatus = false,
    this.isOnline = false,
    this.showEditBadge = false,
    this.onTap,
    this.onEditTap,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveName = name ?? (user != null ? '${user!.firstName} ${user!.lastName}'.trim() : '');
    final String initial = effectiveName.isNotEmpty
        ? effectiveName[0].toUpperCase()
        : 'U';

    final isRider = user?.role == UserRole.rider;
    final String? resolvedUrl = (imageUrl != null && imageUrl!.trim().isNotEmpty)
        ? imageUrl!.trim()
        : (user?.avatarUrl != null && user!.avatarUrl!.trim().isNotEmpty)
            ? user!.avatarUrl!.trim()
            : null;

    Widget avatarContent;

    if (resolvedUrl != null) {
      avatarContent = Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: [
            BoxShadow(
              color: (isRider ? AppTheme.primary : AppTheme.accent).withValues(alpha: 0.25),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ClipOval(
          child: Image.network(
            resolvedUrl,
            width: size,
            height: size,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                color: isRider ? AppTheme.primaryLight.withValues(alpha: 0.15) : AppTheme.accentLight.withValues(alpha: 0.15),
                child: Center(
                  child: SizedBox(
                    width: size * 0.4,
                    height: size * 0.4,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isRider ? AppTheme.primary : AppTheme.accent,
                      ),
                    ),
                  ),
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return _buildInitials(initial, isRider);
            },
          ),
        ),
      );
    } else {
      avatarContent = _buildInitials(initial, isRider);
    }

    final avatar = Stack(
      clipBehavior: Clip.none,
      children: [
        avatarContent,
        if (showOnlineStatus && !showEditBadge)
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: size * 0.32,
              height: size * 0.32,
              decoration: BoxDecoration(
                color: isOnline ? AppTheme.success : const Color(0xFF94A3B8),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: isOnline ? AppTheme.glowSuccess : null,
              ),
            ),
          ),
        if (showEditBadge)
          Positioned(
            right: -2,
            bottom: -2,
            child: Material(
              color: Colors.transparent,
              shape: const CircleBorder(),
              child: InkWell(
                onTap: onEditTap ?? onTap,
                customBorder: const CircleBorder(),
                child: Container(
                  padding: EdgeInsets.all(size * 0.08),
                  decoration: BoxDecoration(
                    color: AppTheme.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.25),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.camera_alt_rounded,
                    color: Colors.white,
                    size: size * 0.28,
                  ),
                ),
              ),
            ),
          ),
      ],
    );

    if (onTap != null && !showEditBadge) {
      return GestureDetector(onTap: onTap, child: avatar);
    }
    return avatar;
  }

  Widget _buildInitials(String initial, bool isRider) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isRider
              ? [AppTheme.primary, AppTheme.indigo]
              : [AppTheme.accent, AppTheme.accentLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: (isRider ? AppTheme.primary : AppTheme.accent).withValues(alpha: 0.25),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Center(
        child: Text(
          initial,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: size * 0.42,
          ),
        ),
      ),
    );
  }
}
