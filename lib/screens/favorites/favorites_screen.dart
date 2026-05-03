import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../config/theme.dart';
import '../../providers/favorites_provider.dart';
import '../../utils/app_localizations.dart';
import '../../utils/helpers.dart';
import '../games/pack_selection_screen.dart';

/// ❤️ Màn hình "Đã lưu" — liệt kê game user đã yêu thích.
class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  /// Mapping gameType → meta.
  List<GameMeta> _allMetas() => [
        GameMeta.matching,
        GameMeta.quiz,
        GameMeta.wordPuzzle,
      ];

  GameMeta? _metaFor(String type) {
    for (final m in _allMetas()) {
      if (m.type == type) return m;
    }
    return null;
  }

  String _titleFor(BuildContext context, String type) {
    switch (type) {
      case 'matching':
        return context.t('gm_game_matching');
      case 'quiz':
        return context.t('gm_game_quiz');
      case 'word_puzzle':
        return context.t('gm_game_puzzle');
    }
    return type;
  }

  String _descFor(BuildContext context, String type) {
    switch (type) {
      case 'matching':
        return context.t('gm_matching_desc');
      case 'quiz':
        return context.t('gm_quiz_desc');
      case 'word_puzzle':
        return context.t('gm_puzzle_desc');
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          context.t('fav_title'),
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: Consumer<FavoritesProvider>(
        builder: (context, fav, _) {
          final ids = fav.idList;
          if (ids.isEmpty) {
            return _buildEmpty(context);
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: ids.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (ctx, i) {
              final meta = _metaFor(ids[i]);
              if (meta == null) return const SizedBox.shrink();
              return _FavGameCard(
                meta: meta,
                title: _titleFor(context, meta.type),
                description: _descFor(context, meta.type),
              )
                  .animate(delay: (i * 80).ms)
                  .fadeIn(duration: 300.ms)
                  .slideX(begin: 0.05, end: 0);
            },
          );
        },
      ),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Color(0xFFFFE4EC),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.favorite_border,
                size: 60,
                color: Color(0xFFFF4D6D),
              ),
            )
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .scale(
                  begin: const Offset(1, 1),
                  end: const Offset(1.08, 1.08),
                  duration: 1400.ms,
                  curve: Curves.easeInOut,
                ),
            const SizedBox(height: 20),
            Text(
              context.t('fav_empty_title'),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              context.t('fav_empty_sub'),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/games');
              },
              icon: const Icon(LucideIcons.gamepad2),
              label: Text(context.t('fav_browse_games')),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FavGameCard extends StatelessWidget {
  final GameMeta meta;
  final String title;
  final String description;

  const _FavGameCard({
    required this.meta,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final gradient = meta.gradient;
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PackSelectionScreen(
              gameType: meta.type,
              gameTitle: title,
              gameIcon: meta.icon,
              gameGradient: meta.gradient,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: gradient.first.withValues(alpha: 0.35),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.22),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(meta.icon, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.9),
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            InkWell(
              onTap: () async {
                HapticFeedback.lightImpact();
                await context.read<FavoritesProvider>().toggle(meta.type);
                if (!context.mounted) return;
                Helpers.showSuccess(context, context.tr('fav_removed'));
              },
              customBorder: const CircleBorder(),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.favorite,
                  color: Color(0xFFFF4D6D),
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
