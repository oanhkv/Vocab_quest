import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../config/design_tokens.dart';
import '../../config/theme.dart';
import '../../models/game_result_model.dart';
import '../../models/level_reward_model.dart';
import '../../utils/streak_calculator.dart';
import '../../widgets/custom_button.dart';
import '../../services/pack_service.dart';
import 'level_map_screen.dart';

/// 🧠 Stats riêng cho Memory game — chỉ truyền khi gameType == memory.
/// Khi có giá trị, `GameResultScreen` render layout dành riêng cho memory
/// (3 game khác không truyền nên path cũ giữ nguyên).
class MemoryStats {
  final int pairsMatched; // Tổng cặp đã ghép
  final int pairsTotal;   // Tổng cặp cần ghép
  final int timeLeft;     // Giây còn lại khi kết thúc
  final int totalTime;    // Tổng thời gian quy định
  const MemoryStats({
    required this.pairsMatched,
    required this.pairsTotal,
    required this.timeLeft,
    required this.totalTime,
  });

  bool get isComplete => pairsMatched >= pairsTotal && pairsTotal > 0;
}

/// 🎉 Màn hình kết quả sau khi chơi xong - có hiệu ứng confetti
class GameResultScreen extends StatefulWidget {
  final GameResultModel result;
  final LevelReward? levelReward; // có giá trị nếu vừa pass level lần đầu
  final String? packId; // nếu chơi trong pack
  final int? levelIndex; // level hiện tại (1-3)
  final StreakOutcome? streakOutcome;
  final MemoryStats? memoryStats; // chỉ memory truyền vào
  final int? overrideStars; // chỉ memory: ghi đè cách tính sao
  const GameResultScreen({
    super.key,
    required this.result,
    this.levelReward,
    this.packId,
    this.levelIndex,
    this.streakOutcome,
    this.memoryStats,
    this.overrideStars,
  });

  @override
  State<GameResultScreen> createState() => _GameResultScreenState();
}

class _GameResultScreenState extends State<GameResultScreen> {
  late ConfettiController _confetti;
  bool _loadingNext = false;

  /// Sao thực tế hiển thị: ưu tiên `overrideStars` (memory), fallback `result.stars`.
  int get _effectiveStars => widget.overrideStars ?? widget.result.stars;

  /// Có dùng layout riêng cho memory hay không.
  bool get _isMemoryLayout =>
      widget.memoryStats != null && widget.result.gameType == 'memory';

  @override
  void initState() {
    super.initState();
    _confetti = ConfettiController(duration: const Duration(seconds: 3));

    // Bắn confetti nếu thắng (>= 2 sao), unlock level mới, hoặc đạt mốc streak
    final streakMilestone = widget.streakOutcome?.milestoneHit != null;
    if (_effectiveStars >= 2 ||
        widget.levelReward != null ||
        streakMilestone) {
      _confetti.play();
    }
  }

  @override
  void dispose() {
    _confetti.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.result;
    final stars = _effectiveStars;
    final isGood = stars >= 2;
    final canPlayNext = widget.packId != null &&
        widget.levelIndex != null &&
        isGood &&
        (widget.levelIndex! < PackService.levelsPerPack);

    // Memory dùng gradient xanh (theme thẻ); 3 game khác giữ tím/dark.
    final List<Color> bgGradient = _isMemoryLayout
        ? (isGood ? AppColors.gradientBlue : AppColors.gradientDark)
        : (isGood ? AppColors.gradientPurple : AppColors.gradientDark);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: bgGradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            // Confetti
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confetti,
                blastDirectionality: BlastDirectionality.explosive,
                particleDrag: 0.05,
                emissionFrequency: 0.05,
                numberOfParticles: 30,
                gravity: 0.2,
                shouldLoop: false,
                colors: const [
                  Colors.pink,
                  Colors.blue,
                  Colors.yellow,
                  Colors.green,
                  Colors.purple,
                ],
              ),
            ),

            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSizes.padding),
                child: Column(
                  children: [
                    const SizedBox(height: 40),

                    // Icon + text
                    _isMemoryLayout
                        ? _buildMemoryHeader(r, stars)
                        : _buildHeader(r),
                    const SizedBox(height: 24),

                    // Sao
                    _buildStars(stars),
                    const SizedBox(height: 24),

                    // Banner thưởng mở khoá level (nếu có)
                    if (widget.levelReward != null) ...[
                      _buildLevelRewardBanner(widget.levelReward!),
                      const SizedBox(height: 20),
                    ] else
                      const SizedBox(height: 8),

                    // Các card thông tin
                    _isMemoryLayout
                        ? _buildMemoryStatsCard(r, widget.memoryStats!)
                        : _buildStatsCard(r),
                    const SizedBox(height: 20),

                    // Rewards
                    _buildRewardsCard(r),
                    const SizedBox(height: 20),

                    // Streak (nếu có thông tin từ outcome)
                    if (widget.streakOutcome != null &&
                        widget.streakOutcome!.newStreak > 0) ...[
                      _buildStreakCard(widget.streakOutcome!),
                      const SizedBox(height: 20),
                    ],

                    const SizedBox(height: 12),

                    // Buttons
                    _buildActionButtons(canPlayNext: canPlayNext),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(GameResultModel r) {
    final String title;
    final IconData icon;
    switch (r.stars) {
      case 3:
        title = 'Tuyệt vời!';
        icon = FontAwesomeIcons.crown;
        break;
      case 2:
        title = 'Làm tốt lắm!';
        icon = FontAwesomeIcons.medal;
        break;
      case 1:
        title = 'Cố lên nhé!';
        icon = FontAwesomeIcons.handSparkles;
        break;
      default:
        title = 'Hãy thử lại!';
        icon = FontAwesomeIcons.faceSadTear;
    }

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white, size: 64),
        ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),
        const SizedBox(height: AppSpacing.md),
        Text(
          title,
          style: AppText.display.copyWith(
            color: Colors.white,
            fontSize: 32,
          ),
        ).animate().fadeIn(delay: 300.ms),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(AppRadius.pill),
          ),
          child: Text(
            '${r.gameTypeDisplay} · ${r.levelDisplay}',
            style: AppText.caption.copyWith(
              color: Colors.white.withValues(alpha: 0.95),
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }

  /// Header riêng cho Memory: tiêu đề thân thiện hơn, có badge "Hoàn hảo!"
  /// nếu first-attempt 100%, hoặc "Hoàn thành!" nếu ghép xong nhưng có lỗi.
  Widget _buildMemoryHeader(GameResultModel r, int stars) {
    final ms = widget.memoryStats!;
    final String title;
    final IconData icon;
    switch (stars) {
      case 3:
        title = 'Trí nhớ siêu đỉnh!';
        icon = FontAwesomeIcons.brain;
        break;
      case 2:
        title = 'Ghép giỏi lắm!';
        icon = FontAwesomeIcons.medal;
        break;
      case 1:
        title = 'Cố thêm chút nhé!';
        icon = FontAwesomeIcons.handSparkles;
        break;
      default:
        title = 'Thử lại nào!';
        icon = FontAwesomeIcons.faceSadTear;
    }

    final String? badge = ms.isComplete ? '✅ Hoàn thành' : null;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white, size: 64),
        ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),
        const SizedBox(height: AppSpacing.md),
        Text(
          title,
          style: AppText.display.copyWith(
            color: Colors.white,
            fontSize: 32,
          ),
          textAlign: TextAlign.center,
        ).animate().fadeIn(delay: 300.ms),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(AppRadius.pill),
          ),
          child: Text(
            'Lật thẻ · ${r.levelDisplay}',
            style: AppText.caption.copyWith(
              color: Colors.white.withValues(alpha: 0.95),
              fontSize: 12,
            ),
          ),
        ),
        if (badge != null) ...[
          const SizedBox(height: 8),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.95),
              borderRadius: BorderRadius.circular(AppRadius.pill),
              boxShadow: [
                BoxShadow(
                  color: Colors.amber.withValues(alpha: 0.5),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Text(
              badge,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.4,
              ),
            ),
          ).animate(delay: 600.ms).fadeIn().scale(
                begin: const Offset(0.7, 0.7),
                end: const Offset(1, 1),
                curve: Curves.elasticOut,
                duration: 500.ms,
              ),
        ],
      ],
    );
  }

  /// Stats card riêng cho Memory: chỉ hiển thị Điểm số và Thời gian còn lại.
  /// (Sao đã hiển thị riêng phía trên; các metric "câu đúng / accuracy"
  /// không hợp với game ghép thẻ nên đã bỏ.)
  Widget _buildMemoryStatsCard(GameResultModel r, MemoryStats ms) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: AppShadow.card,
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildBigStat(
              icon: LucideIcons.trophy,
              label: 'Điểm số',
              value: '${r.score}',
              color: Colors.orange,
            ),
          ),
          Container(width: 1, height: 80, color: Colors.grey.shade200),
          Expanded(
            child: _buildBigStat(
              icon: LucideIcons.timer,
              label: 'Thời gian còn',
              value: '${ms.timeLeft}s',
              color: Colors.purple,
            ),
          ),
        ],
      ),
    ).animate(delay: 800.ms).fadeIn().slideY(begin: 0.2, end: 0);
  }

  Widget _buildBigStat({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 30),
        ),
        const SizedBox(height: 12),
        Text(
          value,
          style: AppText.stat.copyWith(
            fontSize: 32,
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: AppText.caption.copyWith(fontSize: 13),
        ),
      ],
    );
  }

  Widget _buildStars(int stars) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (i) {
        final active = i < stars;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Icon(
            active ? Icons.star_rounded : Icons.star_outline_rounded,
            color: active ? Colors.amber : Colors.white54,
            size: 60,
          ).animate(delay: (500 + i * 200).ms).scale(
                duration: 400.ms,
                curve: Curves.elasticOut,
                begin: const Offset(0, 0),
                end: const Offset(1, 1),
              ),
        );
      }),
    );
  }

  Widget _buildStatsCard(GameResultModel r) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: AppShadow.card,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  icon: LucideIcons.trophy,
                  label: 'Điểm số',
                  value: '${r.score}',
                  color: Colors.orange,
                ),
              ),
              _divider(),
              Expanded(
                child: _buildStatItem(
                  icon: LucideIcons.target,
                  label: 'Độ chính xác',
                  value: '${r.accuracy.toStringAsFixed(0)}%',
                  color: Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  icon: LucideIcons.checkCircle,
                  label: 'Câu đúng',
                  value: '${r.correctAnswers}/${r.totalQuestions}',
                  color: Colors.blue,
                ),
              ),
              _divider(),
              Expanded(
                child: _buildStatItem(
                  icon: LucideIcons.timer,
                  label: 'Thời gian',
                  value: '${r.timeTakenSeconds}s',
                  color: Colors.purple,
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate(delay: 800.ms).fadeIn().slideY(begin: 0.2, end: 0);
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          value,
          style: AppText.stat.copyWith(
            fontSize: 22,
            color: AppColors.textPrimary,
          ),
        ),
        Text(
          label,
          style: AppText.caption.copyWith(fontSize: 12),
        ),
      ],
    );
  }

  Widget _divider() {
    return Container(
      width: 1,
      height: 60,
      color: Colors.grey.shade200,
    );
  }

  /// Card hiển thị streak — có 2 state:
  /// - Milestone hit: banner cam-vàng lớn + bonus coin/XP
  /// - Streak tăng thường: chip nhỏ "+1 ngày, giữ đà!"
  Widget _buildStreakCard(StreakOutcome s) {
    final isMilestone = s.milestoneHit != null;

    if (isMilestone) {
      return Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFF6A00), Color(0xFFFF3D71)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppRadius.lg),
          boxShadow: AppShadow.colored(const Color(0xFFFF6A00)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.22),
                shape: BoxShape.circle,
              ),
              child: const Icon(LucideIcons.flame,
                  color: Colors.white, size: 32),
            )
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .scale(
                  begin: const Offset(1, 1),
                  end: const Offset(1.15, 1.15),
                  duration: 700.ms,
                  curve: Curves.easeInOut,
                ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '🔥 Streak ${s.milestoneHit} ngày!',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Bonus: +${s.bonusCoins} coin, +${s.bonusXP} XP',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ).animate().fadeIn(delay: 1000.ms).slideY(begin: 0.2, end: 0);
    }

    final subtitle = s.streakIncreased
        ? 'Giỏi lắm! Giữ đà học mỗi ngày nhé 🚀'
        : 'Bạn đã học hôm nay — quay lại mai để streak tăng!';

    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: AppShadow.card,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: Color(0xFFFFF1E6),
              shape: BoxShape.circle,
            ),
            child: const Icon(LucideIcons.flame,
                color: Color(0xFFFF6A00), size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Streak: ${s.newStreak} ngày',
                  style: const TextStyle(
                    fontSize: 15,
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
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 900.ms);
  }

  Widget _buildRewardsCard(GameResultModel r) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: AppColors.gradientGold),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: AppShadow.colored(const Color(0xFFFFB300)),
      ),
      child: Column(
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(FontAwesomeIcons.gift, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text(
                'Phần thưởng',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildReward(
                icon: FontAwesomeIcons.coins,
                value: '+${r.coinsEarned}',
                label: 'Coins',
              ),
              Container(width: 1, height: 50, color: Colors.white30),
              _buildReward(
                icon: FontAwesomeIcons.bolt,
                value: '+${r.xpEarned}',
                label: 'XP',
              ),
            ],
          ),
        ],
      ),
    ).animate(delay: 1000.ms).fadeIn().slideY(begin: 0.2, end: 0);
  }

  Widget _buildReward({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 28),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.9),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildLevelRewardBanner(LevelReward reward) {
    final title = reward.packCompleted
        ? 'HOÀN THÀNH TRỌN PACK!'
        : 'MỞ KHOÁ LEVEL ${reward.levelIndex + 1}';
    final subtitle = reward.packCompleted
        ? 'Bạn đã chinh phục cả 3 level của pack này 👑'
        : 'Level ${reward.levelIndex + 1} đã sẵn sàng để thử thách';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: AppColors.gradientGold),
        borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withValues(alpha: 0.4),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                ),
                child:
                    const Icon(LucideIcons.gift, color: Colors.white, size: 26),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.95),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _rewardChip(
                  icon: FontAwesomeIcons.coins,
                  text: '+${reward.coins}',
                  label: 'Coin bonus',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _rewardChip(
                  icon: FontAwesomeIcons.bolt,
                  text: '+${reward.xp}',
                  label: 'XP bonus',
                ),
              ),
            ],
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 500.ms)
        .slideY(begin: -0.15, end: 0, duration: 500.ms)
        .then()
        .shake(duration: 400.ms, hz: 2);
  }

  Widget _rewardChip({
    required IconData icon,
    required String text,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(AppSizes.radius),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 10,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Color> _gameGradient(String gameType) {
    switch (gameType) {
      case 'matching':
        return AppColors.gradientPurple;
      case 'quiz':
        return AppColors.gradientOrange;
      case 'memory':
        return AppColors.gradientBlue;
      case 'word_puzzle':
      default:
        return AppColors.gradientPink;
    }
  }

  String _gameTitle(String gameType) {
    switch (gameType) {
      case 'matching':
        return 'Nối từ';
      case 'quiz':
        return 'Trắc nghiệm';
      case 'memory':
        return 'Lật thẻ';
      case 'word_puzzle':
      default:
        return 'Xếp chữ';
    }
  }

  Future<void> _playNextLevel() async {
    if (_loadingNext) return;
    final packId = widget.packId;
    final levelIndex = widget.levelIndex;
    if (packId == null || levelIndex == null) return;
    final nextLevel = levelIndex + 1;
    if (nextLevel > PackService.levelsPerPack) return;

    setState(() => _loadingNext = true);
    try {
      final pack = await PackService.loadPackById(packId);
      if (!mounted) return;
      if (pack == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không tìm thấy pack để chơi tiếp')),
        );
        return;
      }

      // Mở LevelMap để người dùng thấy đường tiến độ và level mới.
      // (LevelMap tự load words từ pack và sẽ cho phép tap vào level mới mở.)
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => LevelMapScreen(
            gameType: widget.result.gameType,
            gameTitle: _gameTitle(widget.result.gameType),
            gameGradient: _gameGradient(widget.result.gameType),
            pack: pack,
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _loadingNext = false);
    }
  }

  Widget _buildActionButtons({required bool canPlayNext}) {
    return Column(
      children: [
        if (canPlayNext) ...[
          GradientButton(
            text:
                _loadingNext ? 'Đang tải level mới...' : 'Chơi tiếp level mới',
            icon: LucideIcons.arrowRightCircle,
            gradient: const [Color(0xFF4FACFE), Color(0xFF00F2FE)],
            onPressed: _loadingNext ? () {} : _playNextLevel,
          ),
          const SizedBox(height: 12),
        ],
        GradientButton(
          text: 'Chơi lại',
          icon: LucideIcons.rotateCcw,
          gradient: const [Color(0xFF43E97B), Color(0xFF38F9D7)],
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        const SizedBox(height: 12),
        OutlineButton2(
          text: 'Về menu chính',
          icon: LucideIcons.home,
          color: Colors.white,
          onPressed: () {
            Navigator.popUntil(context, ModalRoute.withName('/home'));
          },
        ),
      ],
    ).animate(delay: 1200.ms).fadeIn();
  }
}
