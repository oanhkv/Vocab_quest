import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../config/design_tokens.dart';
import '../../config/theme.dart';
import '../../models/game_result_model.dart';
import '../../providers/user_provider.dart';
import '../../services/firestore_service.dart';
import '../../utils/helpers.dart';
import '../../widgets/bubble_back_button.dart';
import '../../widgets/loading_widget.dart';

/// 📜 Màn hình lịch sử chơi game
class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().user;

    return Scaffold(
      appBar: AppBar(
        leading: const BubbleBackButton(),
        title: Text('Lịch sử chơi', style: AppText.title.copyWith(fontSize: 20)),
        centerTitle: true,
      ),
      body: user == null
          ? const EmptyState(
        icon: LucideIcons.userX,
        title: 'Vui lòng đăng nhập',
        subtitle: 'Bạn cần đăng nhập để xem lịch sử',
      )
          : StreamBuilder<List<GameResultModel>>(
        stream: FirestoreService().streamUserHistory(user.uid),
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting &&
              !snap.hasData) {
            return const ShimmerList(itemCount: 6);
          }

          if (snap.hasError) {
            return EmptyState(
              icon: LucideIcons.alertCircle,
              title: 'Không tải được lịch sử',
              subtitle: 'Lỗi: ${snap.error}',
            );
          }

          final list = snap.data ?? [];
          if (list.isEmpty) {
            return const EmptyState(
              icon: LucideIcons.history,
              title: 'Chưa có lịch sử',
              subtitle: 'Hãy chơi game để xem kết quả ở đây',
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(AppSizes.padding),
            itemCount: list.length,
            itemBuilder: (ctx, i) => _buildHistoryCard(list[i], i),
          );
        },
      ),
    );
  }

  Widget _buildHistoryCard(GameResultModel r, int index) {
    final IconData icon;
    final List<Color> gradient;

    switch (r.gameType) {
      case 'matching':
        icon = FontAwesomeIcons.puzzlePiece;
        gradient = AppColors.gradientPurple;
        break;
      case 'quiz':
        icon = FontAwesomeIcons.circleQuestion;
        gradient = AppColors.gradientOrange;
        break;
      case 'word_puzzle':
        icon = FontAwesomeIcons.spellCheck;
        gradient = AppColors.gradientPink;
        break;
      default:
        icon = FontAwesomeIcons.gamepad;
        gradient = AppColors.gradientBlue;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm + 4),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.md),
        boxShadow: AppShadow.soft,
      ),
      child: Row(
        children: [
          // Icon game
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: gradient),
              borderRadius: BorderRadius.circular(AppSizes.radius),
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 12),

          // Thông tin
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      r.gameTypeDisplay,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: _getLevelColor(r.level).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        r.levelDisplay,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: _getLevelColor(r.level),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    // Sao
                    ...List.generate(3, (i) {
                      return Icon(
                        Icons.star,
                        size: 14,
                        color: i < r.stars
                            ? Colors.amber
                            : Colors.grey.shade300,
                      );
                    }),
                    const SizedBox(width: 8),
                    Text(
                      '${r.correctAnswers}/${r.totalQuestions} đúng',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  Helpers.timeAgo(r.playedAt),
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textLight,
                  ),
                ),
              ],
            ),
          ),

          // Điểm số
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${r.score}',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primary,
                ),
              ),
              const Text(
                'điểm',
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(FontAwesomeIcons.coins,
                      color: Colors.orange, size: 12),
                  const SizedBox(width: 2),
                  Text(
                    '+${r.coinsEarned}',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.orange,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    )
        .animate(delay: (index * 50).ms)
        .fadeIn(duration: 300.ms)
        .slideX(begin: 0.1, end: 0);
  }

  Color _getLevelColor(String level) {
    switch (level) {
      case 'beginner':
        return AppColors.beginnerColor;
      case 'intermediate':
        return AppColors.intermediateColor;
      case 'advanced':
        return AppColors.advancedColor;
      default:
        return AppColors.primary;
    }
  }
}