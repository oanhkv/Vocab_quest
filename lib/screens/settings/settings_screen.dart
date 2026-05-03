import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../config/design_tokens.dart';
import '../../config/theme.dart';
import '../../config/constants.dart';
import '../../providers/settings_provider.dart';
import '../../providers/user_provider.dart';
import '../../services/audio_service.dart';
import '../../utils/app_localizations.dart';
import '../../utils/helpers.dart';
import '../../widgets/bubble_back_button.dart';
import '../../widgets/user_avatar.dart';

/// ⚙️ Màn hình Cài đặt - đầy đủ các tuỳ chọn
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  String _t(SettingsProvider s, String key) =>
      AppLocalizations.tr(s.language, key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BubbleBackButton(),
        title: Consumer<SettingsProvider>(
          builder: (context, settings, _) => Text(
            _t(settings, 'settings_title'),
            style: AppText.title.copyWith(fontSize: 20),
          ),
        ),
        centerTitle: true,
      ),
      body: Consumer<SettingsProvider>(
        builder: (context, settings, _) {
          return ListView(
            padding: const EdgeInsets.all(AppSizes.padding),
            children: [
              _buildUserHeader(context),
              const SizedBox(height: 24),

              // === GIAO DIỆN ===
              _buildSectionTitle(
                  _t(settings, 'section_appearance'), LucideIcons.palette),
              _buildSettingCard(context, children: [
                _buildSwitchTile(
                  icon: LucideIcons.moon,
                  iconColor: Colors.indigo,
                  title: _t(settings, 'dark_mode'),
                  subtitle: _t(settings, 'dark_mode_sub'),
                  value: settings.isDarkMode,
                  onChanged: (v) {
                    _clickFeedback(settings);
                    settings.toggleDarkMode(v);
                  },
                ),
              ]),
              const SizedBox(height: 20),

              // === ÂM THANH ===
              _buildSectionTitle(
                  _t(settings, 'section_sound'), LucideIcons.volume2),
              _buildSettingCard(context, children: [
                _buildSwitchTile(
                  icon: LucideIcons.volume2,
                  iconColor: Colors.orange,
                  title: _t(settings, 'sound_effect'),
                  subtitle: _t(settings, 'sound_effect_sub'),
                  value: settings.soundEnabled,
                  onChanged: (v) => settings.toggleSound(v),
                ),
                const Divider(height: 1, indent: 72),
                _buildSwitchTile(
                  icon: LucideIcons.music,
                  iconColor: Colors.purple,
                  title: _t(settings, 'bg_music'),
                  subtitle: _t(settings, 'bg_music_sub'),
                  value: settings.musicEnabled,
                  onChanged: (v) {
                    _clickFeedback(settings);
                    settings.toggleMusic(v);
                  },
                ),
              ]),
              const SizedBox(height: 20),

              // === THÔNG BÁO ===
              _buildSectionTitle(
                  _t(settings, 'section_notification'), LucideIcons.bell),
              _buildSettingCard(context, children: [
                _buildSwitchTile(
                  icon: LucideIcons.bell,
                  iconColor: Colors.red,
                  title: _t(settings, 'notification_reminder'),
                  subtitle: _t(settings, 'notification_reminder_sub'),
                  value: settings.notificationEnabled,
                  onChanged: (v) =>
                      _handleToggleNotification(context, settings, v),
                ),
                if (settings.notificationEnabled) ...[
                  const Divider(height: 1, indent: 72),
                  _buildActionTile(
                    icon: LucideIcons.clock,
                    iconColor: Colors.pink,
                    title: _t(settings, 'reminder_time'),
                    subtitle: _formatTime(settings.reminderTime),
                    onTap: () => _pickReminderTime(context, settings),
                  ),
                ],
              ]),
              const SizedBox(height: 20),

              // === NGÔN NGỮ ===
              _buildSectionTitle(
                  _t(settings, 'section_language'), LucideIcons.globe),
              _buildSettingCard(context, children: [
                _buildActionTile(
                  icon: LucideIcons.languages,
                  iconColor: Colors.blue,
                  title: _t(settings, 'language_label'),
                  subtitle: _getLanguageName(settings.language),
                  onTap: () => _showLanguagePicker(context, settings),
                ),
              ]),
              const SizedBox(height: 20),

              // === VỀ APP ===
              _buildSectionTitle(
                  _t(settings, 'section_info'), LucideIcons.info),
              _buildSettingCard(context, children: [
                _buildActionTile(
                  icon: LucideIcons.info,
                  iconColor: Colors.cyan,
                  title: _t(settings, 'about_app'),
                  subtitle:
                      '${_t(settings, 'about_app_sub')} ${AppConstants.appVersion}',
                  onTap: () => _showAboutDialog(context, settings),
                ),
                const Divider(height: 1, indent: 72),
                _buildActionTile(
                  icon: LucideIcons.star,
                  iconColor: Colors.amber,
                  title: _t(settings, 'rate_app'),
                  subtitle: settings.userRating > 0
                      ? '⭐ ' * settings.userRating
                      : _t(settings, 'rate_app_sub'),
                  onTap: () => _showRatingDialog(context, settings),
                ),
                const Divider(height: 1, indent: 72),
                _buildActionTile(
                  icon: LucideIcons.share2,
                  iconColor: Colors.green,
                  title: _t(settings, 'share_app'),
                  subtitle: _t(settings, 'share_app_sub'),
                  onTap: () => _shareApp(context, settings),
                ),
              ]),
              const SizedBox(height: 32),

              // === NÚT ĐĂNG XUẤT ===
              _buildLogoutButton(context, settings),
              const SizedBox(height: 16),

              // Footer
              Center(
                child: Text(
                  _t(settings, 'footer'),
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textLight,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          );
        },
      ),
    );
  }

  void _clickFeedback(SettingsProvider settings) {
    AudioService.instance.playClick();
  }

  String _formatTime(TimeOfDay t) {
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  Future<void> _pickReminderTime(
      BuildContext context, SettingsProvider settings) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: settings.reminderTime,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context)
            .copyWith(alwaysUse24HourFormat: true),
        child: child!,
      ),
    );
    if (picked != null) {
      await settings.setReminderTime(picked);
      if (context.mounted) {
        final msg = _t(settings, 'notification_scheduled')
            .replaceFirst('%s', _formatTime(picked));
        Helpers.showSuccess(context, msg);
      }
    }
  }

  Future<void> _handleToggleNotification(
      BuildContext context, SettingsProvider settings, bool value) async {
    _clickFeedback(settings);
    final ok = await settings.toggleNotification(value);
    if (!context.mounted) return;
    if (value && !ok) {
      Helpers.showError(
          context, _t(settings, 'notification_permission_denied'));
    } else if (value && ok) {
      final msg = _t(settings, 'notification_scheduled')
          .replaceFirst('%s', _formatTime(settings.reminderTime));
      Helpers.showSuccess(context, msg);
    } else if (!value) {
      Helpers.showSuccess(context, _t(settings, 'notification_cancelled'));
    }
  }

  /// Header hiển thị thông tin user
  Widget _buildUserHeader(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, _) {
        final user = userProvider.user;
        return Container(
          padding: const EdgeInsets.all(AppSizes.padding),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: AppColors.gradientPurple,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              UserAvatar(
                avatarUrl: user?.avatarUrl ?? '',
                displayName: user?.displayName ?? '',
                radius: 32,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user?.displayName ?? 'User',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user?.email ?? '',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildMiniStat(
                            LucideIcons.trophy, '${user?.totalScore ?? 0}'),
                        const SizedBox(width: 12),
                        _buildMiniStat(
                            LucideIcons.zap, '${user?.totalXP ?? 0} XP'),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMiniStat(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 14),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.textSecondary),
          const SizedBox(width: 8),
          Text(
            title.toUpperCase(),
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingCard(BuildContext context,
      {required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color ?? Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.md),
        boxShadow: AppShadow.soft,
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      secondary: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        ),
        child: Icon(icon, color: iconColor, size: 22),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          fontSize: 12,
          color: AppColors.textSecondary,
        ),
      ),
      value: value,
      onChanged: onChanged,
      activeThumbColor: AppColors.primary,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        ),
        child: Icon(icon, color: iconColor, size: 22),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          fontSize: 12,
          color: AppColors.textSecondary,
        ),
      ),
      trailing: const Icon(Icons.chevron_right,
          color: AppColors.textLight, size: 22),
      onTap: onTap,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }

  Widget _buildLogoutButton(BuildContext context, SettingsProvider settings) {
    return InkWell(
      onTap: () => _confirmLogout(context, settings),
      borderRadius: BorderRadius.circular(AppSizes.radius),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppSizes.radius),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(LucideIcons.logOut, color: Colors.red, size: 22),
            const SizedBox(width: 12),
            Text(
              _t(settings, 'logout'),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getLanguageName(String code) {
    switch (code) {
      case 'vi':
        return 'Tiếng Việt';
      case 'en':
        return 'English';
      default:
        return code;
    }
  }

  void _showLanguagePicker(BuildContext context, SettingsProvider settings) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppSizes.radiusLarge)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(AppSizes.padding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _t(settings, 'choose_language'),
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 16),
            _languageOption(context, settings, '🇻🇳', 'Tiếng Việt', 'vi'),
            _languageOption(context, settings, '🇺🇸', 'English', 'en'),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _languageOption(BuildContext context, SettingsProvider settings,
      String flag, String name, String code) {
    final isSelected = settings.language == code;
    return ListTile(
      leading: Text(flag, style: const TextStyle(fontSize: 28)),
      title: Text(name,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
      trailing: isSelected
          ? const Icon(Icons.check_circle, color: AppColors.primary)
          : null,
      onTap: () {
        settings.setLanguage(code);
        Navigator.pop(context);
      },
    );
  }

  void _showAboutDialog(BuildContext context, SettingsProvider settings) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(colors: AppColors.gradientPurple),
                  shape: BoxShape.circle,
                ),
                child: const Icon(FontAwesomeIcons.graduationCap,
                    color: Colors.white, size: 36),
              ),
              const SizedBox(height: 16),
              const Text(
                AppConstants.appName,
                style:
                    TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              Text(
                '${_t(settings, 'about_app_sub')} ${AppConstants.appVersion}',
                style: const TextStyle(
                    fontSize: 13, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),
              const Text(
                AppConstants.appTagline,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 14, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: Text(_t(settings, 'close')),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showRatingDialog(BuildContext context, SettingsProvider settings) {
    int tempRating = settings.userRating == 0 ? 5 : settings.userRating;
    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (ctx, setState) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.amber.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(LucideIcons.star,
                        color: Colors.amber, size: 40),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    _t(settings, 'rate_app_dialog_title'),
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _t(settings, 'rate_app_dialog_sub'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 13, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (i) {
                      final filled = i < tempRating;
                      return IconButton(
                        onPressed: () {
                          setState(() => tempRating = i + 1);
                          HapticFeedback.selectionClick();
                        },
                        icon: Icon(
                          filled ? Icons.star_rounded : Icons.star_outline_rounded,
                          color: Colors.amber,
                          size: 36,
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.pop(dialogContext),
                          child: Text(_t(settings, 'cancel')),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            await settings.setUserRating(tempRating);
                            if (!dialogContext.mounted) return;
                            Navigator.pop(dialogContext);
                            final msg = _t(settings, 'rate_app_thanks')
                                .replaceAll('%d', '$tempRating');
                            Helpers.showSuccess(context, msg);
                          },
                          child: Text(_t(settings, 'save')),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _shareApp(
      BuildContext context, SettingsProvider settings) async {
    final text = _t(settings, 'share_text');
    await Clipboard.setData(ClipboardData(text: text));
    if (context.mounted) {
      Helpers.showSuccess(context, _t(settings, 'share_copied'));
    }
  }

  void _confirmLogout(BuildContext context, SettingsProvider settings) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radius)),
        title: Text(_t(settings, 'logout')),
        content: Text(_t(settings, 'logout_confirm')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(_t(settings, 'cancel')),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(context);
              await context.read<UserProvider>().logout();
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(
                    context, '/login', (r) => false);
              }
            },
            child: Text(_t(settings, 'logout')),
          ),
        ],
      ),
    );
  }
}
