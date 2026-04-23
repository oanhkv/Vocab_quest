import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../config/theme.dart';
import 'pack_selection_screen.dart';

/// 🎮 Màn hình chọn game — mỗi game có danh sách pack riêng
class GameMenuScreen extends StatelessWidget {
  const GameMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final games = [
      GameMeta.matching,
      GameMeta.quiz,
      GameMeta.wordPuzzle,
    ];
    final descriptions = [
      'Ghép từ tiếng Anh với nghĩa tiếng Việt',
      '4 đáp án cho mỗi câu hỏi, chọn đúng nhé!',
      'Sắp xếp các chữ cái thành từ đúng',
    ];

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).cardTheme.color ?? Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.arrow_back,
                color: Theme.of(context).colorScheme.onSurface, size: 20),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Chọn Game',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Mini Game',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Chọn 1 game rồi pick gói từ vựng bạn muốn luyện',
              style: TextStyle(
                fontSize: 13,
                color: Theme.of(context).colorScheme.onSurface.withValues(
                      alpha: 0.6,
                    ),
              ),
            ),
            const SizedBox(height: 16),
            ...games.asMap().entries.map((e) {
              final i = e.key;
              final g = e.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildGameCard(
                  context: context,
                  meta: g,
                  description: descriptions[i],
                  delay: i * 100,
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildGameCard({
    required BuildContext context,
    required GameMeta meta,
    required String description,
    required int delay,
  }) {
    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PackSelectionScreen(
            gameType: meta.type,
            gameTitle: meta.title,
            gameIcon: meta.icon,
            gameGradient: meta.gradient,
          ),
        ),
      ),
      borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: meta.gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
          boxShadow: [
            BoxShadow(
              color: meta.gradient.first.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(AppSizes.radius),
              ),
              child: Icon(meta.icon, color: Colors.white, size: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    meta.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.25),
                shape: BoxShape.circle,
              ),
              child: const Icon(LucideIcons.chevronRight,
                  color: Colors.white, size: 20),
            ),
          ],
        ),
      ),
    )
        .animate(delay: delay.ms)
        .fadeIn(duration: 400.ms)
        .slideX(begin: 0.1, end: 0);
  }
}
