import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import '../../config/theme.dart';
import '../../providers/favorites_provider.dart';
import '../../providers/user_provider.dart';
import '../../utils/app_localizations.dart';
import '../../utils/helpers.dart';
import 'pack_selection_screen.dart';

/// 🎮 Màn hình chọn game — redesign: hero banner, featured card, grid 2 cột
class GameMenuScreen extends StatelessWidget {
  const GameMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Game đầu tiên làm "featured" để nổi bật hơn.
    final featured = _GameInfo(
      meta: GameMeta.matching,
      title: context.t('gm_game_matching'),
      description: context.t('gm_matching_desc'),
      badge: 'HOT',
      badgeColor: const Color(0xFFFF4D6D),
    );
    final isEn = context.t('home_shortcut_saved') == 'Saved';
    final others = [
      _GameInfo(
        meta: GameMeta.quiz,
        title: context.t('gm_game_quiz'),
        description: context.t('gm_quiz_desc'),
      ),
      _GameInfo(
        meta: GameMeta.wordPuzzle,
        title: context.t('gm_game_puzzle'),
        description: context.t('gm_puzzle_desc'),
      ),
      _GameInfo(
        meta: GameMeta.memory,
        title: context.t('gm_game_memory'),
        description: context.t('gm_memory_desc'),
        badge: isEn ? 'NEW' : 'MỚI',
        badgeColor: const Color(0xFF00C6A7),
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverAppBar(
              pinned: false,
              floating: true,
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
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: const Icon(Icons.arrow_back,
                      color: AppColors.textPrimary, size: 20),
                ),
                onPressed: () => Navigator.pop(context),
              ),
              title: Text(
                context.t('gm_title'),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              centerTitle: true,
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const _HeroBanner(),
                  const SizedBox(height: 24),
                  _sectionHeader(context.t('gm_featured'),
                      context.t('gm_featured_sub')),
                  const SizedBox(height: 12),
                  _FeaturedGameCard(info: featured)
                      .animate()
                      .fadeIn(duration: 500.ms)
                      .slideY(begin: 0.1, end: 0, duration: 400.ms),
                  const SizedBox(height: 28),
                  _sectionHeader(context.t('gm_all'), context.t('gm_all_sub')),
                  const SizedBox(height: 12),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: others.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.9,
                    ),
                    itemBuilder: (ctx, i) => _GameGridCard(
                      info: others[i],
                      delay: 150 + i * 100,
                    ),
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

/// Data tổng hợp cho 1 game card (meta + title localized + description + badge optional).
class _GameInfo {
  final GameMeta meta;
  final String title;
  final String description;
  final String? badge;
  final Color? badgeColor;

  _GameInfo({
    required this.meta,
    required this.title,
    required this.description,
    this.badge,
    this.badgeColor,
  });
}

/// Banner trên cùng: gradient tím, lời chào + 3 mini-stats.
class _HeroBanner extends StatelessWidget {
  const _HeroBanner();

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProv, _) {
        final user = userProv.user;
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: AppColors.gradientPurple,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.25),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Decorative circle (blob nền)
              Positioned(
                top: -30,
                right: -20,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Positioned(
                bottom: -40,
                left: -20,
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.06),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.22),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          LucideIcons.gamepad2,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              context.t('gm_ready'),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              context.t('gm_ready_sub'),
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: _HeroStat(
                          icon: LucideIcons.flame,
                          iconColor: const Color(0xFFFFB26B),
                          value: '${user?.streak ?? 0}',
                          label: context.t('profile_streak'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _HeroStat(
                          icon: LucideIcons.zap,
                          iconColor: AppColors.accent,
                          value: '${user?.totalXP ?? 0}',
                          label: context.t('home_stat_xp'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _HeroStat(
                          icon: FontAwesomeIcons.trophy,
                          iconColor: const Color(0xFFFFD166),
                          value: '${user?.totalScore ?? 0}',
                          label: context.t('home_stat_score'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ).animate().fadeIn(duration: 500.ms).slideY(begin: -0.05, end: 0);
      },
    );
  }
}

class _HeroStat extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;

  const _HeroStat({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 18),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }
}

/// Nút tim yêu thích — toggle state qua FavoritesProvider.
class _FavoriteHeart extends StatelessWidget {
  final String gameId;

  const _FavoriteHeart({required this.gameId});

  @override
  Widget build(BuildContext context) {
    final isFav = context.watch<FavoritesProvider>().isFavorite(gameId);
    return InkWell(
      onTap: () async {
        HapticFeedback.lightImpact();
        final added =
            await context.read<FavoritesProvider>().toggle(gameId);
        if (!context.mounted) return;
        Helpers.showSuccess(
            context, context.tr(added ? 'fav_added' : 'fav_removed'));
      },
      customBorder: const CircleBorder(),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: isFav ? 0.95 : 0.25),
          shape: BoxShape.circle,
          boxShadow: isFav
              ? [
                  BoxShadow(
                    color: Colors.pink.withValues(alpha: 0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Icon(
          isFav ? Icons.favorite : Icons.favorite_border,
          color: isFav ? const Color(0xFFFF4D6D) : Colors.white,
          size: 20,
        ),
      )
          .animate(key: ValueKey('heart_${gameId}_$isFav'))
          .scale(
            begin: const Offset(0.7, 0.7),
            end: const Offset(1, 1),
            duration: 250.ms,
            curve: Curves.elasticOut,
          ),
    );
  }
}

/// Card game lớn cho mục "Gợi ý hôm nay" — có shimmer glow để nổi bật.
class _FeaturedGameCard extends StatelessWidget {
  final _GameInfo info;

  const _FeaturedGameCard({required this.info});

  @override
  Widget build(BuildContext context) {
    final gradient = info.meta.gradient;
    return GestureDetector(
      onTap: () => _openPack(context, info.meta),
      child: Container(
        height: 160,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: gradient.first.withValues(alpha: 0.45),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            // Shimmer sweep chạy liên tục để card featured có cảm giác "sống"
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Shimmer.fromColors(
                  baseColor: Colors.white.withValues(alpha: 0.0),
                  highlightColor: Colors.white.withValues(alpha: 0.18),
                  period: const Duration(seconds: 3),
                  child: Container(color: Colors.white),
                ),
              ),
            ),
            // Blob nền
            Positioned(
              right: -30,
              bottom: -30,
              child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              right: 40,
              top: -30,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.06),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              top: 12,
              right: 12,
              child: _FavoriteHeart(gameId: info.meta.type),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  // Orb icon lớn với glow
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3),
                        width: 2,
                      ),
                    ),
                    child: Icon(info.meta.icon, color: Colors.white, size: 40),
                  )
                      .animate(
                        onPlay: (c) => c.repeat(reverse: true),
                      )
                      .scale(
                        duration: 1800.ms,
                        begin: const Offset(1, 1),
                        end: const Offset(1.06, 1.06),
                        curve: Curves.easeInOut,
                      ),
                  const SizedBox(width: 18),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                info.title,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ),
                            if (info.badge != null) ...[
                              const SizedBox(width: 8),
                              _Badge(
                                text: info.badge!,
                                color: info.badgeColor ?? Colors.red,
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          info.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white.withValues(alpha: 0.9),
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(LucideIcons.play,
                                  color: gradient.first, size: 14),
                              const SizedBox(width: 4),
                              Text(
                                context.t('gm_play_now'),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: gradient.first,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Card nhỏ hơn cho grid 2 cột.
class _GameGridCard extends StatelessWidget {
  final _GameInfo info;
  final int delay;

  const _GameGridCard({required this.info, required this.delay});

  @override
  Widget build(BuildContext context) {
    final gradient = info.meta.gradient;
    return GestureDetector(
      onTap: () => _openPack(context, info.meta),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: gradient.first.withValues(alpha: 0.35),
              blurRadius: 14,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            Positioned(
              right: -25,
              bottom: -25,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: _FavoriteHeart(gameId: info.meta.type),
            ),
            if (info.badge != null)
              Positioned(
                bottom: 12,
                right: 12,
                child: _Badge(
                  text: info.badge!,
                  color: info.badgeColor ?? Colors.red,
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.22),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Icon(info.meta.icon, color: Colors.white, size: 28),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        info.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        info.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.white.withValues(alpha: 0.85),
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    )
        .animate(delay: delay.ms)
        .fadeIn(duration: 400.ms)
        .slideY(begin: 0.15, end: 0);
  }
}

/// Badge nhỏ (HOT / MỚI ...).
class _Badge extends StatelessWidget {
  final String text;
  final Color color;

  const _Badge({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.5),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

Future<void> _openPack(BuildContext context, GameMeta meta) async {
  HapticFeedback.lightImpact();
  await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => PackSelectionScreen(
        gameType: meta.type,
        gameTitle: meta.title,
        gameIcon: meta.icon,
        gameGradient: meta.gradient,
      ),
    ),
  );
}
