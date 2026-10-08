import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/rider_avatar_presets.dart';
import '../core/theme/app_theme.dart';
import '../providers/auth_provider.dart';
import 'app_button.dart';
import 'app_text_field.dart';

class AvatarPickerDialog extends StatefulWidget {
  final String? currentAvatarUrl;

  const AvatarPickerDialog({super.key, this.currentAvatarUrl});

  static Future<void> show(BuildContext context) async {
    final authProvider = context.read<AuthProvider>();
    final currentUrl = authProvider.currentUser?.avatarUrl;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => AvatarPickerDialog(currentAvatarUrl: currentUrl),
    );
  }

  @override
  State<AvatarPickerDialog> createState() => _AvatarPickerDialogState();
}

class _AvatarPickerDialogState extends State<AvatarPickerDialog> {
  late String? _selectedUrl;
  late final TextEditingController _customUrlController;
  bool _useCustomUrl = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _selectedUrl = widget.currentAvatarUrl;
    _customUrlController = TextEditingController(
      text: widget.currentAvatarUrl != null &&
              !RiderAvatarPresets.presets.any((p) => p.imageUrl == widget.currentAvatarUrl)
          ? widget.currentAvatarUrl
          : '',
    );
    if (_customUrlController.text.isNotEmpty) {
      _useCustomUrl = true;
    }
  }

  @override
  void dispose() {
    _customUrlController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    setState(() => _isSaving = true);
    final finalUrl = _useCustomUrl
        ? (_customUrlController.text.trim().isEmpty ? null : _customUrlController.text.trim())
        : _selectedUrl;

    try {
      await context.read<AuthProvider>().updateAvatar(finalUrl);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Text(
                  finalUrl != null
                      ? 'Profile photo updated successfully!'
                      : 'Profile photo removed.',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            backgroundColor: AppTheme.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update photo: $e'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      margin: EdgeInsets.only(
        top: 40,
        bottom: bottomInset,
        left: 8,
        right: 8,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // Title Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.add_a_photo_rounded, color: AppTheme.primary, size: 24),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Update Profile Photo',
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textPrimary,
                            letterSpacing: -0.3,
                          ),
                        ),
                        SizedBox(height: 3),
                        Text(
                          'Helps passengers easily identify you on arrival',
                          style: TextStyle(
                            fontSize: 12.5,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Curated Presets Header
              const Text(
                'Select Verified Captain Portrait',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 12),

              // Grid of presets
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.85,
                ),
                itemCount: RiderAvatarPresets.presets.length,
                itemBuilder: (context, index) {
                  final preset = RiderAvatarPresets.presets[index];
                  final isSelected = !_useCustomUrl && _selectedUrl == preset.imageUrl;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _useCustomUrl = false;
                        _selectedUrl = preset.imageUrl;
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isSelected ? AppTheme.primary.withValues(alpha: 0.05) : Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected ? AppTheme.primary : AppTheme.border,
                          width: isSelected ? 2.5 : 1,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: AppTheme.primary.withValues(alpha: 0.15),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                )
                              ]
                            : null,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              ClipOval(
                                child: Image.network(
                                  preset.imageUrl,
                                  width: 52,
                                  height: 52,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => Container(
                                    width: 52,
                                    height: 52,
                                    color: AppTheme.primaryLight,
                                    child: const Icon(Icons.person, color: Colors.white),
                                  ),
                                ),
                              ),
                              if (isSelected)
                                Positioned(
                                  right: 0,
                                  bottom: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(3),
                                    decoration: const BoxDecoration(
                                      color: AppTheme.primary,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.check_rounded,
                                      color: Colors.white,
                                      size: 14,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            preset.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                              color: isSelected ? AppTheme.primary : AppTheme.textPrimary,
                            ),
                          ),
                          Text(
                            preset.subtitle.split('•').last.trim(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 9.5,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 18),

              // Divider or Custom URL
              Row(
                children: [
                  const Expanded(child: Divider()),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      'OR CUSTOM URL',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Colors.grey.shade500,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                  const Expanded(child: Divider()),
                ],
              ),
              const SizedBox(height: 14),

              // Custom photo URL field
              NikhyTextField(
                controller: _customUrlController,
                label: 'Image Web Address (URL)',
                hint: 'https://example.com/photo.jpg',
                prefixIcon: Icons.link_rounded,
                onChanged: (val) {
                  if (val.trim().isNotEmpty) {
                    setState(() {
                      _useCustomUrl = true;
                    });
                  }
                },
              ),
              const SizedBox(height: 20),

              // Action Buttons
              Row(
                children: [
                  if (_selectedUrl != null || _customUrlController.text.isNotEmpty)
                    Expanded(
                      flex: 1,
                      child: TextButton.icon(
                        icon: const Icon(Icons.delete_outline_rounded, color: AppTheme.error, size: 18),
                        label: const Text('Remove', style: TextStyle(color: AppTheme.error, fontWeight: FontWeight.w700)),
                        onPressed: _isSaving
                            ? null
                            : () {
                                setState(() {
                                  _selectedUrl = null;
                                  _useCustomUrl = false;
                                  _customUrlController.clear();
                                });
                              },
                      ),
                    ),
                  Expanded(
                    flex: 2,
                    child: NikhyButton(
                      text: 'Save Photo',
                      icon: Icons.check_rounded,
                      isLoading: _isSaving,
                      onPressed: _handleSave,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
