import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../config/design_tokens.dart';
import '../../config/theme.dart';
import '../../models/vocab_model.dart';
import '../../models/vocab_pack_model.dart';
import '../../providers/user_provider.dart';
import '../../services/pack_service.dart';
import '../../utils/helpers.dart';
import '../../widgets/loading_widget.dart';
import 'matching_game.dart';
import 'memory_game.dart';
import 'quiz_game.dart';
import 'word_puzzle_game.dart';

/// 🗺️ Level Map — D1 redesign: Duolingo-style zigzag path
class LevelMapScreen extends StatefulWidget {
  final String gameType;
  final String gameTitle;
  final List<Color> gameGradient;
  final VocabPack pack;

  const LevelMapScreen({
    super.key,
    required this.gameType,
    required this.gameTitle,
    required this.gameGradient,
    required this.pack,
  });

  @override
  State<LevelMapScreen> createState() => _LevelMapScreenState();
}

class _LevelMapScreenState extends State<LevelMapScreen> {
  List<VocabModel>? _allWords;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadWords();
  }

  Future<void> _loadWords() async {
    final w = await PackService.loadPackWords(widget.pack);
    if (!mounted) return;
    setState(() {
      _allWords = w;
      _loading = false;
    });
  }

  Color _hex(String h) =>
      Color(int.parse('FF${h.replaceFirst('#', '')}', radix: 16));

  @override
  Widget build(BuildContext context) {
    final colors = widget.pack.gradient.map(_hex).toList();
    final bg = colors.length >= 2
        ? colors
        : [AppColors.primary, AppColors.primaryDark];

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8),
          child: InkWell(
            onTap: () => Navigator.pop(context),
            borderRadius: BorderRadius.circular(AppRadius.pill),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: AppShadow.soft,
              ),
              child: const Icon(Icons.arrow_back,
                  color: AppColors.textPrimary, size: 20),
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: bg,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            // Background pattern — dots rải rác
            const Positioned.fill(child: _DotsPattern()),
            SafeArea(
              child: _loading
                  ? const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    )
                  : (_allWords?.isEmpty ?? true)
                      ? const EmptyState(
                          icon: LucideIcons.fileQuestion,
                          title: 'Gói trống',
                          subtitle: 'Gói này chưa có từ nào',
                        )
                      : _buildContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    final progress = context.watch<UserProvider>().getProgress(
          widget.gameType,
          widget.pack.id,
        );
    final levels = _levelMetas();

    return ListView(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, 80, AppSpacing.lg, AppSpacing.xl),
      children: [
        _buildPackHeader(progress, levels.length),
        const SizedBox(height: AppSpacing.xl),
        ..._buildLevelPath(levels, progress),
      ],
    );
  }

  Widget _buildPackHeader(int progress, int total) {
    return Column(
      children: [
        Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: AppShadow.card,
          ),
          child: Center(
            child: Text(widget.pack.emoji,
                style: const TextStyle(fontSize: 56)),
          ),
        ).animate().scale(
              duration: 500.ms,
              curve: Curves.elasticOut,
              begin: const Offset(0.6, 0.6),
            ),
        const SizedBox(height: AppSpacing.md),
        Text(
          widget.pack.title,
          style: AppText.display.copyWith(color: Colors.white, fontSize: 26),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(AppRadius.pill),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(LucideIcons.bookOpen,
                  color: Colors.white.withValues(alpha: 0.9), size: 13),
              const SizedBox(width: 6),
              Text(
                '${_allWords!.length} từ · $progress/$total level đã qua',
                style: AppText.caption.copyWith(
                  color: Colors.white.withValues(alpha: 0.95),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<Widget> _buildLevelPath(List<_LevelMeta> levels, int progress) {
    final out = <Widget>[];
    for (var i = 0; i < levels.length; i++) {
      final meta = levels[i];
      final unlocked = meta.index <= progress + 1;
      final passed = meta.index <= progress;
      final alignLeft = i.isEven;
      final isCurrent = meta.index == progress + 1; // level đang sẵn sàng chơi

      out.add(Row(
        mainAxisAlignment:
            alignLeft ? MainAxisAlignment.start : MainAxisAlignment.end,
        children: [
          _LevelNode(
            meta: meta,
            unlocked: unlocked,
            passed: passed,
            isCurrent: isCurrent,
            onTap: unlocked ? () => _startLevel(meta) : _lockedTap,
          )
              .animate(delay: (i * 150).ms)
              .fadeIn(duration: 400.ms)
              .scale(
                begin: const Offset(0.6, 0.6),
                curve: Curves.easeOutBack,
                duration: 400.ms,
              ),
        ],
      ));

      // Đường nối dots giữa các node (không vẽ sau node cuối)
      if (i < levels.length - 1) {
        out.add(const SizedBox(height: 8));
        out.add(_PathDots(leftToRight: alignLeft));
        out.add(const SizedBox(height: 8));
      }
    }
    return out;
  }

  List<_LevelMeta> _levelMetas() {
    return const [
      _LevelMeta(
        index: 1,
        title: 'Khởi động',
        subtitle: 'Nửa đầu từ vựng',
        icon: LucideIcons.flame,
      ),
      _LevelMeta(
        index: 2,
        title: 'Tăng tốc',
        subtitle: 'Nửa sau từ vựng',
        icon: LucideIcons.zap,
      ),
      _LevelMeta(
        index: 3,
        title: 'Boss',
        subtitle: 'Tất cả từ, xáo trộn',
        icon: LucideIcons.crown,
      ),
    ];
  }

  void _lockedTap() {
    Helpers.showSnackBar(
        context, 'Hãy hoàn thành level trước (≥2 sao) để mở khoá');
  }

  void _startLevel(_LevelMeta meta) {
    final words = PackService.wordsForLevel(_allWords!, meta.index);
    if (words.isEmpty) {
      Helpers.showError(context, 'Không đủ từ vựng cho level này');
      return;
    }

    Widget game;
    switch (widget.gameType) {
      case 'matching':
        game = MatchingGame(
          level: widget.pack.level,
          words: words,
          packId: widget.pack.id,
          levelIndex: meta.index,
        );
        break;
      case 'quiz':
        game = QuizGame(
          level: widget.pack.level,
          words: words,
          packId: widget.pack.id,
          levelIndex: meta.index,
        );
        break;
      case 'memory':
        game = MemoryGame(
          level: widget.pack.level,
          words: words,
          packId: widget.pack.id,
          levelIndex: meta.index,
        );
        break;
      case 'word_puzzle':
      default:
        game = WordPuzzleGame(
          level: widget.pack.level,
          words: words,
          packId: widget.pack.id,
          levelIndex: meta.index,
        );
    }

    Navigator.push(context, MaterialPageRoute(builder: (_) => game));
  }
}

// ===== Sub-widgets =====

class _LevelMeta {
  final int index;
  final String title;
  final String subtitle;
  final IconData icon;
  const _LevelMeta({
    required this.index,
    required this.title,
    required this.subtitle,
    required this.icon,
  });
}

class _LevelNode extends StatelessWidget {
  final _LevelMeta meta;
  final bool unlocked;
  final bool passed;
  final bool isCurrent;
  final VoidCallback onTap;

  const _LevelNode({
    required this.meta,
    required this.unlocked,
    required this.passed,
    required this.isCurrent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: Container(
        width: 220,
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: unlocked ? Colors.white : Colors.white.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: isCurrent
              ? Border.all(
                  color: const Color(0xFFFFD93D), width: 3)
              : null,
          boxShadow: unlocked ? AppShadow.card : [],
        ),
        child: Row(
          children: [
            // Circle icon
            _NodeCircle(
              icon: unlocked ? meta.icon : LucideIcons.lock,
              passed: passed,
              unlocked: unlocked,
              isCurrent: isCurrent,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Text(
                        'LEVEL ${meta.index}',
                        style: AppText.overline.copyWith(
                          color: unlocked
                              ? AppColors.textSecondary
                              : Colors.white70,
                          fontSize: 10,
                        ),
                      ),
                      if (isCurrent) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFD93D),
                            borderRadius:
                                BorderRadius.circular(AppRadius.pill),
                          ),
                          child: const Text(
                            'MỚI',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF8B6E00),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    meta.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.subtitle.copyWith(
                      color: unlocked ? AppColors.textPrimary : Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    meta.subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.caption.copyWith(
                      color: unlocked
                          ? AppColors.textSecondary
                          : Colors.white70,
                      fontSize: 11,
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

class _NodeCircle extends StatelessWidget {
  final IconData icon;
  final bool passed;
  final bool unlocked;
  final bool isCurrent;
  const _NodeCircle({
    required this.icon,
    required this.passed,
    required this.unlocked,
    required this.isCurrent,
  });

  @override
  Widget build(BuildContext context) {
    final Widget core = Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        gradient: passed
            ? const LinearGradient(
                colors: [Color(0xFF43E97B), Color(0xFF38F9D7)])
            : (unlocked
                ? const LinearGradient(colors: AppColors.gradientGold)
                : null),
        color: unlocked ? null : Colors.white24,
        shape: BoxShape.circle,
        boxShadow: unlocked
            ? [
                BoxShadow(
                  color: (passed
                          ? const Color(0xFF43E97B)
                          : const Color(0xFFFFB300))
                      .withValues(alpha: 0.4),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ]
            : [],
      ),
      child: Icon(
        passed ? Icons.check_rounded : icon,
        color: Colors.white,
        size: passed ? 30 : 26,
      ),
    );
    if (isCurrent) {
      return core
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .scale(
            duration: 1000.ms,
            begin: const Offset(1, 1),
            end: const Offset(1.08, 1.08),
          );
    }
    return core;
  }
}

class _PathDots extends StatelessWidget {
  final bool leftToRight;
  const _PathDots({required this.leftToRight});

  @override
  Widget build(BuildContext context) {
    final dots = List.generate(
      5,
      (i) => Container(
        width: 6,
        height: 6,
        margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.5),
          shape: BoxShape.circle,
        ),
      ),
    );
    return Row(
      mainAxisAlignment:
          leftToRight ? MainAxisAlignment.start : MainAxisAlignment.end,
      children: [
        SizedBox(width: leftToRight ? 80 : 0),
        Column(mainAxisSize: MainAxisSize.min, children: dots),
        SizedBox(width: leftToRight ? 0 : 80),
      ],
    );
  }
}

/// Dot pattern nền mờ
class _DotsPattern extends StatelessWidget {
  const _DotsPattern();
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DotsPainter(),
    );
  }
}

class _DotsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withValues(alpha: 0.08);
    const double spacing = 28;
    for (double y = 0; y < size.height; y += spacing) {
      for (double x = (y ~/ spacing).isEven ? 0 : spacing / 2;
          x < size.width;
          x += spacing) {
        canvas.drawCircle(Offset(x, y), 1.4, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
