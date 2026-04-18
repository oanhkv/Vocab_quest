import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../config/theme.dart';
import '../../models/game_result_model.dart';
import '../../widgets/custom_button.dart';

/// 🎉 Màn hình kết quả sau khi chơi xong - có hiệu ứng confetti
class GameResultScreen extends StatefulWidget {
  final GameResultModel result;
  const GameResultScreen({super.key, required this.result});

  @override
  State<GameResultScreen> createState() => _GameResultScreenState();
}

class _GameResultScreenState extends State<GameResultScreen> {
  late ConfettiController _confetti;

  @override
  void initState() {
    super.initState();
    _confetti = ConfettiController(duration: const Duration(seconds: 3));

    // Chỉ bắn confetti nếu thắng (>= 2 sao)
    if (widget.result.stars >= 2) {
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
    final isGood = r.stars >= 2;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isGood
                ? AppColors.gradientPurple
                : AppColors.gradientDark,
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
                    _buildHeader(r),
                    const SizedBox(height: 24),

                    // Sao
                    _buildStars(r.stars),
                    const SizedBox(height: 32),

                    // Các card thông tin
                    _buildStatsCard(r),
                    const SizedBox(height: 20),

                    // Rewards
                    _buildRewardsCard(r),
                    const SizedBox(height: 32),

                    // Buttons
                    _buildActionButtons(),
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
        )
            .animate()
            .scale(duration: 600.ms, curve: Curves.elasticOut),
        const SizedBox(height: 16),
        Text(
          title,
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w900,
            color: Colors.white,
          ),
        ).animate().fadeIn(delay: 300.ms),
        const SizedBox(height: 6),
        Text(
          '${r.gameTypeDisplay} - ${r.levelDisplay}',
          style: TextStyle(
            fontSize: 14,
            color: Colors.white.withValues(alpha: 0.9),
          ),
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
          )
              .animate(delay: (500 + i * 200).ms)
              .scale(
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
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
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
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

  Widget _buildRewardsCard(GameResultModel r) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: AppColors.gradientGold),
        borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
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

  Widget _buildActionButtons() {
    return Column(
      children: [
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