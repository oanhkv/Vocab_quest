import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:provider/provider.dart';

import '../../config/design_tokens.dart';
import '../../config/theme.dart';
import '../../providers/user_provider.dart';

/// 🏠 Home — redesign D1: hero greeting, stats, big action tiles
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => context.read<UserProvider>().refreshUser(),
          color: AppColors.primary,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.md, AppSpacing.md, AppSpacing.md, AppSpacing.xl),
            children: [
              _buildHero(context),
              const SizedBox(height: AppSpacing.lg),
              _buildStatsStrip(context),
              const SizedBox(height: AppSpacing.lg),
              _buildDailyBanner(context),
              const SizedBox(height: AppSpacing.lg),
              _buildSectionTitle('Chơi ngay', LucideIcons.gamepad2),
              const SizedBox(height: AppSpacing.sm),
              _buildMainActions(context),
              const SizedBox(height: AppSpacing.lg),
              _buildSectionTitle('Khám phá', LucideIcons.compass),
              const SizedBox(height: AppSpacing.sm),
              _buildShortcutsRow(context),
            ],
          ),
        ),
      ),
    );
  }

  /// Hero greeting: avatar + tên + streak chip
  Widget _buildHero(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProv, _) {
        final user = userProv.user;
        return Row(
          children: [
            Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                gradient:
                    const LinearGradient(colors: AppColors.gradientPurple),
                shape: BoxShape.circle,
                boxShadow: AppShadow.colored(AppColors.primary, alpha: 0.25),
              ),
              child: CircleAvatar(
                radius: 28,
                backgroundColor: Colors.white,
                child: Text(
                  (user?.displayName.isNotEmpty == true
                          ? user!.displayName[0]
                          : 'U')
                      .toUpperCase(),
                  style: AppText.title.copyWith(
                    color: AppColors.primary,
                    fontSize: 24,
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Xin chào 👋',
                    style: AppText.caption.copyWith(
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    user?.displayName.isNotEmpty == true
                        ? user!.displayName
                        : 'Học viên mới',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.title.copyWith(fontSize: 22),
                  ),
                ],
              ),
            ),
            _HeroChip(
              icon: LucideIcons.flame,
              text: '${user?.streak ?? 0}',
              gradient: const [Color(0xFFFF8A65), Color(0xFFFF6A88)],
            ),
            const SizedBox(width: AppSpacing.sm),
            _IconBubble(
              icon: LucideIcons.settings,
              onTap: () => Navigator.pushNamed(context, '/settings'),
            ),
          ],
        );
      },
    ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.05, end: 0);
  }

  /// Thanh stats ngang: 3 ô clickable
  Widget _buildStatsStrip(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProv, _) {
        final user = userProv.user;
        return Container(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md, vertical: AppSpacing.md),
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color ?? Colors.white,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            boxShadow: AppShadow.soft,
          ),
          child: Row(
            children: [
              Expanded(
                child: _StatItem(
                  icon: FontAwesomeIcons.trophy,
                  iconColor: const Color(0xFFFFB300),
                  label: 'Điểm',
                  value: '${user?.totalScore ?? 0}',
                ),
              ),
              const _StatDivider(),
              Expanded(
                child: InkWell(
                  onTap: () => Navigator.pushNamed(context, '/shop'),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  child: _StatItem(
                    icon: FontAwesomeIcons.coins,
                    iconColor: const Color(0xFFFF9800),
                    label: 'Coin',
                    value: '${user?.totalCoins ?? 0}',
                    tappable: true,
                  ),
                ),
              ),
              const _StatDivider(),
              Expanded(
                child: _StatItem(
                  icon: FontAwesomeIcons.bolt,
                  iconColor: const Color(0xFF2196F3),
                  label: 'XP',
                  value: '${user?.totalXP ?? 0}',
                ),
              ),
            ],
          ),
        ).animate().fadeIn(delay: 100.ms, duration: 400.ms).slideY(
              begin: 0.05,
              end: 0,
            );
      },
    );
  }

  /// Banner thử thách hàng ngày — lớn, có progress
  Widget _buildDailyBanner(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProv, _) {
        final user = userProv.user;
        const dailyGoal = 50; // XP target
        final xpToday = (user?.totalXP ?? 0) % dailyGoal;
        final progress = xpToday / dailyGoal;

        return InkWell(
          onTap: () => Navigator.pushNamed(context, '/games'),
          borderRadius: BorderRadius.circular(AppRadius.lg),
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: AppColors.gradientPurple,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(AppRadius.lg),
              boxShadow: AppShadow.colored(AppColors.primary, alpha: 0.35),
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Decorative circle
                Positioned(
                  right: -30,
                  bottom: -40,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.22),
                              borderRadius:
                                  BorderRadius.circular(AppRadius.pill),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(LucideIcons.flame,
                                    color: Colors.white, size: 13),
                                const SizedBox(width: 4),
                                Text('THỬ THÁCH HÔM NAY',
                                    style: AppText.overline.copyWith(
                                      color: Colors.white,
                                      fontSize: 10,
                                    )),
                              ],
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            'Học $dailyGoal XP\nđể giữ streak',
                            style: AppText.title.copyWith(
                              color: Colors.white,
                              fontSize: 22,
                              height: 1.25,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          LinearPercentIndicator(
                            percent: progress.clamp(0.0, 1.0),
                            lineHeight: 10,
                            padding: EdgeInsets.zero,
                            backgroundColor:
                                Colors.white.withValues(alpha: 0.25),
                            progressColor: const Color(0xFFFFD93D),
                            barRadius: const Radius.circular(AppRadius.pill),
                            animation: true,
                            animationDuration: 800,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '$xpToday / $dailyGoal XP',
                            style: AppText.caption.copyWith(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(FontAwesomeIcons.rocket,
                              color: Colors.white, size: 32)
                          .animate(onPlay: (c) => c.repeat(reverse: true))
                          .scale(
                            duration: 1500.ms,
                            begin: const Offset(1, 1),
                            end: const Offset(1.12, 1.12),
                          ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ).animate().fadeIn(delay: 150.ms, duration: 500.ms);
      },
    );
  }

  /// 4 action tile lớn 2x2 có emoji
  Widget _buildMainActions(BuildContext context) {
    final tiles = [
      _ActionTileData(
        emoji: '🎮',
        title: 'Mini Game',
        subtitle: '3 loại game',
        gradient: AppColors.gradientPurple,
        route: '/games',
      ),
      _ActionTileData(
        emoji: '🏆',
        title: 'Xếp hạng',
        subtitle: 'Top 100',
        gradient: AppColors.gradientOrange,
        route: '/leaderboard',
      ),
      _ActionTileData(
        emoji: '📜',
        title: 'Lịch sử',
        subtitle: 'Lần chơi gần',
        gradient: AppColors.gradientGreen,
        route: '/history',
      ),
      _ActionTileData(
        emoji: '🛍️',
        title: 'Cửa hàng',
        subtitle: 'Mua gói từ vựng',
        gradient: const [Color(0xFFFA709A), Color(0xFFFEE140)],
        route: '/shop',
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: tiles.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppSpacing.sm + 4,
        mainAxisSpacing: AppSpacing.sm + 4,
        childAspectRatio: 1.05,
      ),
      itemBuilder: (ctx, i) {
        return _ActionTile(data: tiles[i])
            .animate(delay: (i * 80 + 200).ms)
            .fadeIn(duration: 400.ms)
            .slideY(begin: 0.1, end: 0);
      },
    );
  }

  /// Shortcuts ngang: Profile + Settings
  Widget _buildShortcutsRow(BuildContext context) {
    final shortcuts = [
      _ShortcutData(
          icon: LucideIcons.user,
          label: 'Hồ sơ',
          color: const Color(0xFF5C6BC0),
          route: '/profile'),
      _ShortcutData(
          icon: LucideIcons.settings,
          label: 'Cài đặt',
          color: const Color(0xFF78909C),
          route: '/settings'),
      _ShortcutData(
          icon: LucideIcons.award,
          label: 'Huy hiệu',
          color: const Color(0xFFFFB300),
          route: null),
      _ShortcutData(
          icon: LucideIcons.bookmark,
          label: 'Đã lưu',
          color: const Color(0xFFEC407A),
          route: null),
    ];
    return Row(
      children: shortcuts.asMap().entries.map((e) {
        final i = e.key;
        final s = e.value;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: i == shortcuts.length - 1 ? 0 : 8),
            child: _ShortcutTile(data: s)
                .animate(delay: (i * 60 + 400).ms)
                .fadeIn(duration: 400.ms)
                .slideY(begin: 0.1, end: 0),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: 8),
          Text(title, style: AppText.subtitle),
        ],
      ),
    );
  }
}

// ===== Sub-widgets =====

class _HeroChip extends StatelessWidget {
  final IconData icon;
  final String text;
  final List<Color> gradient;
  const _HeroChip({
    required this.icon,
    required this.text,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: gradient),
        borderRadius: BorderRadius.circular(AppRadius.pill),
        boxShadow: AppShadow.colored(gradient.first, alpha: 0.35),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _IconBubble extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _IconBubble({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.pill),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color ?? Colors.white,
          shape: BoxShape.circle,
          boxShadow: AppShadow.soft,
        ),
        child: Icon(icon,
            size: 20, color: Theme.of(context).colorScheme.onSurface),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final bool tappable;
  const _StatItem({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    this.tappable = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: 18),
        ),
        const SizedBox(height: 6),
        Text(value, style: AppText.stat.copyWith(fontSize: 18)),
        Text(label, style: AppText.caption.copyWith(fontSize: 11)),
      ],
    );
  }
}

class _StatDivider extends StatelessWidget {
  const _StatDivider();
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 40,
      margin: const EdgeInsets.symmetric(horizontal: 6),
      color: Colors.grey.withValues(alpha: 0.15),
    );
  }
}

class _ActionTileData {
  final String emoji;
  final String title;
  final String subtitle;
  final List<Color> gradient;
  final String route;
  _ActionTileData({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.gradient,
    required this.route,
  });
}

class _ActionTile extends StatelessWidget {
  final _ActionTileData data;
  const _ActionTile({required this.data});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.pushNamed(context, data.route),
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: data.gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppRadius.lg),
          boxShadow: AppShadow.colored(data.gradient.first),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              right: -8,
              bottom: -16,
              child: Opacity(
                opacity: 0.2,
                child: Text(
                  data.emoji,
                  style: const TextStyle(fontSize: 100),
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  data.emoji,
                  style: const TextStyle(fontSize: 40),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.title,
                      style: AppText.subtitle.copyWith(
                        color: Colors.white,
                        fontSize: 17,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      data.subtitle,
                      style: AppText.caption.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ShortcutData {
  final IconData icon;
  final String label;
  final Color color;
  final String? route;
  _ShortcutData({
    required this.icon,
    required this.label,
    required this.color,
    required this.route,
  });
}

class _ShortcutTile extends StatelessWidget {
  final _ShortcutData data;
  const _ShortcutTile({required this.data});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: data.route == null
          ? null
          : () => Navigator.pushNamed(context, data.route!),
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm, vertical: AppSpacing.md),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color ?? Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.md),
          boxShadow: AppShadow.soft,
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: data.color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(data.icon, color: data.color, size: 20),
            ),
            const SizedBox(height: 6),
            Text(
              data.label,
              textAlign: TextAlign.center,
              style: AppText.caption.copyWith(
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
