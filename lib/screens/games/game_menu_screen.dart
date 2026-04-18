import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../config/theme.dart';
import '../../models/level_model.dart';
import 'matching_game.dart';
import 'quiz_game.dart';
import 'word_puzzle_game.dart';

/// 🎮 Màn hình chọn game và level
class GameMenuScreen extends StatefulWidget {
  const GameMenuScreen({super.key});

  @override
  State<GameMenuScreen> createState() => _GameMenuScreenState();
}

class _GameMenuScreenState extends State<GameMenuScreen> {
  String _selectedLevel = 'beginner';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.arrow_back,
                color: AppColors.textPrimary, size: 20),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Chọn Game',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // === CHỌN LEVEL ===
            const Text(
              'Chọn cấp độ',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: LevelModel.levels
                  .map((level) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: _buildLevelChip(level),
                ),
              ))
                  .toList(),
            ),
            const SizedBox(height: 24),

            // === MÔ TẢ LEVEL ===
            _buildLevelDescription(),
            const SizedBox(height: 24),

            // === CÁC GAME ===
            const Text(
              'Mini Game',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),

            _buildGameCard(
              icon: FontAwesomeIcons.puzzlePiece,
              title: 'Nối từ',
              description: 'Ghép hình với từ tiếng Anh tương ứng',
              gradient: AppColors.gradientPurple,
              onTap: () => _startGame(MatchingGame(level: _selectedLevel)),
              delay: 0,
            ),
            const SizedBox(height: 12),
            _buildGameCard(
              icon: FontAwesomeIcons.circleQuestion,
              title: 'Trắc nghiệm',
              description: '4 đáp án cho mỗi câu hỏi, chọn đúng nhé!',
              gradient: AppColors.gradientOrange,
              onTap: () => _startGame(QuizGame(level: _selectedLevel)),
              delay: 100,
            ),
            const SizedBox(height: 12),
            _buildGameCard(
              icon: FontAwesomeIcons.spellCheck,
              title: 'Xếp chữ',
              description: 'Sắp xếp các chữ cái thành từ tiếng Anh đúng',
              gradient: AppColors.gradientPink,
              onTap: () => _startGame(WordPuzzleGame(level: _selectedLevel)),
              delay: 200,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildLevelChip(LevelModel level) {
    final isSelected = _selectedLevel == level.id;
    return InkWell(
      onTap: () => setState(() => _selectedLevel = level.id),
      borderRadius: BorderRadius.circular(AppSizes.radius),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(colors: level.gradient)
              : null,
          color: isSelected ? null : Colors.white,
          borderRadius: BorderRadius.circular(AppSizes.radius),
          border: Border.all(
            color: isSelected ? Colors.transparent : Colors.grey.shade300,
            width: 2,
          ),
          boxShadow: isSelected
              ? [
            BoxShadow(
              color: level.gradient.first.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ]
              : [],
        ),
        child: Column(
          children: [
            Icon(
              level.icon,
              color: isSelected ? Colors.white : level.color,
              size: 22,
            ),
            const SizedBox(height: 4),
            Text(
              level.name,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLevelDescription() {
    final level = LevelModel.getById(_selectedLevel);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: level.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSizes.radius),
        border: Border.all(color: level.color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: level.color,
              shape: BoxShape.circle,
            ),
            child: Icon(level.icon, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  level.name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: level.color,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  level.description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }

  Widget _buildGameCard({
    required IconData icon,
    required String title,
    required String description,
    required List<Color> gradient,
    required VoidCallback onTap,
    required int delay,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
          boxShadow: [
            BoxShadow(
              color: gradient.first.withValues(alpha: 0.3),
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
              child: Icon(icon, color: Colors.white, size: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
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
              child: const Icon(LucideIcons.play,
                  color: Colors.white, size: 18),
            ),
          ],
        ),
      ),
    )
        .animate(delay: delay.ms)
        .fadeIn(duration: 400.ms)
        .slideX(begin: 0.1, end: 0);
  }

  void _startGame(Widget game) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => game),
    );
  }
}