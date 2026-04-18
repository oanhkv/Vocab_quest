import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../config/theme.dart';
import '../../config/constants.dart';
import '../../providers/settings_provider.dart';
import '../../providers/user_provider.dart';
import '../../utils/helpers.dart';

/// ⚙️ Màn hình Cài đặt - đầy đủ các tuỳ chọn
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                ),
              ],
            ),
            child: const Icon(Icons.arrow_back,
                color: AppColors.textPrimary, size: 20),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Cài đặt',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: Consumer<SettingsProvider>(
        builder: (context, settings, _) {
          return ListView(
            padding: const EdgeInsets.all(AppSizes.padding),
            children: [
              _buildUserHeader(context),
              const SizedBox(height: 24),

              // === GIAO DIỆN ===
              _buildSectionTitle('Giao diện', LucideIcons.palette),
              _buildSettingCard(children: [
                _buildSwitchTile(
                  icon: LucideIcons.moon,
                  iconColor: Colors.indigo,
                  title: 'Chế độ tối',
                  subtitle: 'Giao diện thân thiện với mắt',
                  value: settings.isDarkMode,
                  onChanged: settings.toggleDarkMode,
                ),
              ]),
              const SizedBox(height: 20),

              // === ÂM THANH ===
              _buildSectionTitle('Âm thanh', LucideIcons.volume2),
              _buildSettingCard(children: [
                _buildSwitchTile(
                  icon: LucideIcons.volume2,
                  iconColor: Colors.orange,
                  title: 'Hiệu ứng âm thanh',
                  subtitle: 'Âm thanh khi chơi game',
                  value: settings.soundEnabled,
                  onChanged: settings.toggleSound,
                ),
                const Divider(height: 1, indent: 72),
                _buildSwitchTile(
                  icon: LucideIcons.music,
                  iconColor: Colors.purple,
                  title: 'Nhạc nền',
                  subtitle: 'Phát nhạc khi mở app',
                  value: settings.musicEnabled,
                  onChanged: settings.toggleMusic,
                ),
              ]),
              const SizedBox(height: 20),

              // === THÔNG BÁO ===
              _buildSectionTitle('Thông báo', LucideIcons.bell),
              _buildSettingCard(children: [
                _buildSwitchTile(
                  icon: LucideIcons.bell,
                  iconColor: Colors.red,
                  title: 'Nhắc nhở học tập',
                  subtitle: 'Nhắc bạn học mỗi ngày',
                  value: settings.notificationEnabled,
                  onChanged: settings.toggleNotification,
                ),
              ]),
              const SizedBox(height: 20),

              // === NGÔN NGỮ ===
              _buildSectionTitle('Ngôn ngữ', LucideIcons.globe),
              _buildSettingCard(children: [
                _buildActionTile(
                  icon: LucideIcons.languages,
                  iconColor: Colors.blue,
                  title: 'Ngôn ngữ giao diện',
                  subtitle: _getLanguageName(settings.language),
                  onTap: () => _showLanguagePicker(context, settings),
                ),
              ]),
              const SizedBox(height: 20),

              // === VỀ APP ===
              _buildSectionTitle('Thông tin', LucideIcons.info),
              _buildSettingCard(children: [
                _buildActionTile(
                  icon: LucideIcons.info,
                  iconColor: Colors.cyan,
                  title: 'Về ứng dụng',
                  subtitle: 'Phiên bản ${AppConstants.appVersion}',
                  onTap: () => _showAboutDialog(context),
                ),
                const Divider(height: 1, indent: 72),
                _buildActionTile(
                  icon: LucideIcons.star,
                  iconColor: Colors.amber,
                  title: 'Đánh giá ứng dụng',
                  subtitle: 'Cho chúng tôi 5 sao nhé!',
                  onTap: () => Helpers.showSnackBar(
                      context, 'Cảm ơn bạn đã yêu thích app! 🌟'),
                ),
                const Divider(height: 1, indent: 72),
                _buildActionTile(
                  icon: LucideIcons.share2,
                  iconColor: Colors.green,
                  title: 'Chia sẻ ứng dụng',
                  subtitle: 'Giới thiệu cho bạn bè',
                  onTap: () => Helpers.showSnackBar(
                      context, 'Tính năng đang được phát triển'),
                ),
              ]),
              const SizedBox(height: 32),

              // === NÚT ĐĂNG XUẤT ===
              _buildLogoutButton(context),
              const SizedBox(height: 16),

              // Footer
              const Center(
                child: Text(
                  'Made with ❤️ by VocabQuest Team',
                  style: TextStyle(
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
              CircleAvatar(
                radius: 32,
                backgroundColor: Colors.white,
                child: Text(
                  (user?.displayName.isNotEmpty == true
                      ? user!.displayName[0]
                      : 'U')
                      .toUpperCase(),
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
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

  Widget _buildSettingCard({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
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
          color: AppColors.textPrimary,
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
          color: AppColors.textPrimary,
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

  Widget _buildLogoutButton(BuildContext context) {
    return InkWell(
      onTap: () => _confirmLogout(context),
      borderRadius: BorderRadius.circular(AppSizes.radius),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppSizes.radius),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(LucideIcons.logOut, color: Colors.red, size: 22),
            SizedBox(width: 12),
            Text(
              'Đăng xuất',
              style: TextStyle(
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
            const Text(
              'Chọn ngôn ngữ',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
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

  void _showAboutDialog(BuildContext context) {
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
              const Text(
                'Phiên bản ${AppConstants.appVersion}',
                style: TextStyle(
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
                child: const Text('Đóng'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radius)),
        title: const Text('Đăng xuất'),
        content: const Text('Bạn có chắc muốn đăng xuất không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
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
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );
  }
}