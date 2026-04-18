import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../config/theme.dart';
import '../../providers/user_provider.dart';

/// 🏠 Màn hình Home - Menu chính siêu đẹp
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () =>
              context.read<UserProvider>().refreshUser(),
          color: AppColors.primary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(AppSizes.padding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                const SizedBox(height: 20),
                _buildStatsRow(context),
                const SizedBox(height: 24),
                _buildDailyBanner(context),
                const SizedBox(height: 24),
                _buildSectionTitle('Chức năng chính', LucideIcons.sparkles),
                const SizedBox(height: 12),
                _buildMainMenu(context),
                const SizedBox(height: 24),
                _buildSectionTitle('Khám phá thêm', LucideIcons.compass),
                const SizedBox(height: 12),
                _buildExtraMenu(context),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Header với avatar + tên + cài đặt
  Widget _buildHeader(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, _) {
        final user = userProvider.user;
        return Row(
          children: [
            // Avatar
            Container(
              padding: const EdgeInsets.all(3),
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: AppColors.gradientPurple),
                shape: BoxShape.circle,
              ),
              child: CircleAvatar(
                radius: 26,
                backgroundColor: Colors.white,
                child: Text(
                  (user?.displayName.isNotEmpty == true
                      ? user!.displayName[0]
                      : 'U')
                      .toUpperCase(),
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Chào
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Xin chào 👋',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    user?.displayName ?? 'Bạn',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),

            // Settings
            _iconButton(
              LucideIcons.settings,
              onTap: () => Navigator.pushNamed(context, '/settings'),
            ),
          ],
        );
      },
    );
  }

  /// Hàng stats: Điểm - Coin - XP - Tim
  Widget _buildStatsRow(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, _) {
        final user = userProvider.user;
        return Row(
          children: [
            Expanded(
              child: _buildStatCard(
                icon: FontAwesomeIcons.trophy,
                label: 'Điểm',
                value: '${user?.totalScore ?? 0}',
                gradient: AppColors.gradientGold,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildStatCard(
                icon: FontAwesomeIcons.coins,
                label: 'Coin',
                value: '${user?.totalCoins ?? 0}',
                gradient: AppColors.gradientOrange,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildStatCard(
                icon: FontAwesomeIcons.bolt,
                label: 'XP',
                value: '${user?.totalXP ?? 0}',
                gradient: AppColors.gradientBlue,
              ),
            ),
          ],
        ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.2, end: 0);
      },
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required List<Color> gradient,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSizes.radius),
        boxShadow: [
          BoxShadow(
            color: gradient.first.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  /// Banner thử thách hàng ngày
  Widget _buildDailyBanner(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.pushNamed(context, '/games'),
      borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
      child: Container(
        padding: const EdgeInsets.all(20),
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
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(LucideIcons.flame, color: Colors.white, size: 14),
                        SizedBox(width: 4),
                        Text(
                          'THỬ THÁCH',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Học 10 từ\nmới hôm nay',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(LucideIcons.gift,
                          color: Colors.white, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '+50 coin',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                FontAwesomeIcons.rocket,
                color: Colors.white,
                size: 36,
              ),
            )
                .animate(
                onPlay: (ctr) => ctr.repeat(reverse: true))
                .scale(
              duration: 1500.ms,
              begin: const Offset(1, 1),
              end: const Offset(1.1, 1.1),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 600.ms).slideX(begin: 0.1, end: 0);
  }

  /// Menu chính - 4 chức năng
  Widget _buildMainMenu(BuildContext context) {
    final items = [
      _MenuItem(
        icon: FontAwesomeIcons.gamepad,
        label: 'Chơi Game',
        subtitle: '3 mini game',
        gradient: AppColors.gradientPurple,
        route: '/games',
      ),
      _MenuItem(
        icon: FontAwesomeIcons.chartLine,
        label: 'Xếp hạng',
        subtitle: 'Top 100',
        gradient: AppColors.gradientOrange,
        route: '/leaderboard',
      ),
      _MenuItem(
        icon: FontAwesomeIcons.clockRotateLeft,
        label: 'Lịch sử',
        subtitle: 'Lần chơi gần',
        gradient: AppColors.gradientGreen,
        route: '/history',
      ),
      _MenuItem(
        icon: FontAwesomeIcons.user,
        label: 'Hồ sơ',
        subtitle: 'Thông tin',
        gradient: AppColors.gradientBlue,
        route: '/profile',
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.15,
      ),
      itemBuilder: (ctx, i) {
        final item = items[i];
        return InkWell(
          onTap: () => Navigator.pushNamed(context, item.route),
          borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: item.gradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
              boxShadow: [
                BoxShadow(
                  color: item.gradient.first.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(item.icon, color: Colors.white, size: 26),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      item.subtitle,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        )
            .animate(delay: (i * 100).ms)
            .fadeIn(duration: 500.ms)
            .slideY(begin: 0.2, end: 0);
      },
    );
  }

  /// Menu phụ
  Widget _buildExtraMenu(BuildContext context) {
    final items = [
      _ExtraItem(LucideIcons.bookOpen, 'Từ vựng', Colors.indigo),
      _ExtraItem(LucideIcons.award, 'Huy hiệu', Colors.amber),
      _ExtraItem(LucideIcons.bookmark, 'Đã lưu', Colors.pink),
      _ExtraItem(LucideIcons.settings, 'Cài đặt', Colors.grey),
    ];

    return SizedBox(
      height: 90,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (ctx, i) {
          final item = items[i];
          return InkWell(
            onTap: () {
              if (i == 3) Navigator.pushNamed(context, '/settings');
            },
            child: Container(
              width: 90,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppSizes.radius),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: item.color.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(item.icon, color: item.color, size: 22),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.label,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.textPrimary),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _iconButton(IconData icon, {required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizes.radiusCircle),
      child: Container(
        padding: const EdgeInsets.all(10),
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
        child: Icon(icon, color: AppColors.textPrimary, size: 22),
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String label;
  final String subtitle;
  final List<Color> gradient;
  final String route;

  _MenuItem({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.gradient,
    required this.route,
  });
}

class _ExtraItem {
  final IconData icon;
  final String label;
  final Color color;
  _ExtraItem(this.icon, this.label, this.color);
}