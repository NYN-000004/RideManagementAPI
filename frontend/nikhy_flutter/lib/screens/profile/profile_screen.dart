import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/app_button.dart';
import '../../widgets/avatar_picker_dialog.dart';
import '../../widgets/section_title.dart';
import '../../widgets/server_config_dialog.dart';
import '../../widgets/user_avatar.dart';
import '../auth/login/login_screen.dart';
import '../customer/dashboard/customer_dashboard_screen.dart';
import '../rider/dashboard/rider_dashboard_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.currentUser;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          IconButton(
            tooltip: 'Server Settings',
            icon: const Icon(Icons.tune_rounded),
            onPressed: () => ServerConfigDialog.show(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // User Header Card
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppTheme.border),
                    boxShadow: AppTheme.cardShadow,
                  ),
                  child: Column(
                    children: [
                      UserAvatar(
                        user: user,
                        size: 84,
                        showEditBadge: true,
                        onEditTap: () => AvatarPickerDialog.show(context),
                        onTap: () => AvatarPickerDialog.show(context),
                        showOnlineStatus: user?.role == UserRole.rider,
                        isOnline: true,
                      ),
                      const SizedBox(height: 14),
                      Text(
                        user?.fullName ?? 'User Profile',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.textPrimary,
                          letterSpacing: -0.4,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: user?.role == UserRole.rider
                                   ? AppTheme.primary.withValues(alpha: 0.1)
                                  : AppTheme.accent.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              user?.role.displayName.toUpperCase() ?? 'CUSTOMER',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.6,
                                color: user?.role == UserRole.rider
                                    ? AppTheme.primary
                                    : AppTheme.accent,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppTheme.surfaceMuted,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'ID: #${user?.id ?? 101}',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      InkWell(
                        onTap: () => AvatarPickerDialog.show(context),
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppTheme.primary.withValues(alpha: 0.2)),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.camera_alt_rounded, size: 15, color: AppTheme.primary),
                              SizedBox(width: 7),
                              Text(
                                'Change Profile Photo',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (user?.role == UserRole.rider) ...[
                        const SizedBox(height: 10),
                        Text(
                          'Your photo is displayed to customers so they can easily verify you at pickup.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 11.5,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Account Information Section
                const SectionTitle(title: 'Account Information'),
                const SizedBox(height: 8),
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(color: AppTheme.border),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: AppTheme.subtleShadow,
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _buildTile(Icons.person_outline_rounded, 'Full Name', user?.fullName ?? '—'),
                        const Divider(height: 16),
                        _buildTile(Icons.mail_outline_rounded, 'Email', user?.email ?? '—'),
                        const Divider(height: 16),
                        _buildTile(Icons.phone_outlined, 'Phone', user?.phone ?? '—'),
                        const Divider(height: 16),
                        _buildTile(
                          user?.role == UserRole.rider
                              ? Icons.two_wheeler_rounded
                              : Icons.person_pin_circle_outlined,
                          'Account Type',
                          user?.role.displayName ?? 'Customer',
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Mode Switching (for Riders)
                if (user?.role == UserRole.rider) ...[
                  const SectionTitle(title: 'Role Switching'),
                  const SizedBox(height: 8),
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: const BorderSide(color: AppTheme.border),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.accent.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.swap_horiz_rounded, color: AppTheme.accent, size: 20),
                      ),
                      title: const Text(
                        'Switch App Mode',
                        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                      ),
                      subtitle: Text(
                        authProvider.activeRole == UserRole.rider
                            ? 'Currently in Rider Mode. Tap to use Passenger features.'
                            : 'Currently in Passenger Mode. Tap to use Rider features.',
                        style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                      onTap: () {
                        if (authProvider.activeRole == UserRole.rider) {
                          authProvider.switchActiveRole(UserRole.customer);
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(builder: (_) => const CustomerDashboardScreen()),
                            (route) => false,
                          );
                        } else {
                          authProvider.switchActiveRole(UserRole.rider);
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(builder: (_) => const RiderDashboardScreen()),
                            (route) => false,
                          );
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                // Settings Section
                const SectionTitle(title: 'Application & Server'),
                const SizedBox(height: 8),
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(color: AppTheme.border),
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.dns_rounded, color: AppTheme.primary, size: 20),
                        ),
                        title: const Text(
                          'Backend API Base URL',
                          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                        ),
                        subtitle: Text(
                          authProvider.baseUrl,
                          style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                        ),
                        trailing: const Icon(Icons.edit_outlined, size: 18),
                        onTap: () => ServerConfigDialog.show(context),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceMuted,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.info_outline_rounded, color: AppTheme.textSecondary, size: 20),
                        ),
                        title: const Text(
                          'About NIKHY',
                          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                        ),
                        subtitle: const Text(
                          '${AppConstants.appName} • ${AppConstants.appTagline}',
                          style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                        ),
                        trailing: const Text(
                          'v1.0.0',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.textMuted),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // Sign Out Button
                AppButton(
                  text: 'Sign Out',
                  icon: Icons.logout_rounded,
                  isOutlined: true,
                  backgroundColor: AppTheme.error,
                  textColor: AppTheme.error,
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Confirm Sign Out'),
                        content: const Text('Are you sure you want to end your current session?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: const Text('Cancel'),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.error,
                              foregroundColor: Colors.white,
                            ),
                            onPressed: () => Navigator.pop(ctx, true),
                            child: const Text('Sign Out'),
                          ),
                        ],
                      ),
                    );

                    if (confirm == true) {
                      await authProvider.logout();
                      if (context.mounted) {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (_) => const LoginScreen()),
                          (route) => false,
                        );
                      }
                    }
                  },
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTile(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppTheme.textMuted),
        const SizedBox(width: 12),
        Text(
          label,
          style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary, fontWeight: FontWeight.w500),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
        ),
      ],
    );
  }
}
