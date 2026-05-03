import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:provider/provider.dart';

import '../../config/design_tokens.dart';
import '../../config/theme.dart';
import '../../models/vocab_pack_model.dart';
import '../../providers/user_provider.dart';
import '../../services/pack_service.dart';
import '../../widgets/loading_widget.dart';
import 'level_map_screen.dart';

/// 🗂️ Pack Selection — D1 redesign: 2-col grid, progress ring
class PackSelectionScreen extends StatefulWidget {
  final String gameType;
  final String gameTitle;
  final IconData gameIcon;
  final List<Color> gameGradient;

  const PackSelectionScreen({
    super.key,
    required this.gameType,
    required this.gameTitle,
    required this.gameIcon,
    required this.gameGradient,
  });

  @override
  State<PackSelectionScreen> createState() => _PackSelectionScreenState();
}

class _PackSelectionScreenState extends State<PackSelectionScreen> {
  late Future<List<VocabPack>> _packsFuture;

  @override
  void initState() {
    super.initState();
    _loadPacks();
  }

  void _loadPacks() {
    final user = context.read<UserProvider>().user;
    _packsFuture = PackService.loadOwnedPacks(user?.ownedPacks ?? const []);
  }

  Color _hex(String h) =>
      Color(int.parse('FF${h.replaceFirst('#', '')}', radix: 16));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(8),
          child: _IconBubble(
            icon: Icons.arrow_back,
            onTap: () => Navigator.pop(context),
          ),
        ),
        title: Text(widget.gameTitle, style: AppText.title.copyWith(fontSize: 20)),
        centerTitle: true,
      ),
      body: Consumer<UserProvider>(
        builder: (context, userProv, _) {
          return FutureBuilder<List<VocabPack>>(
            future: _packsFuture,
            builder: (ctx, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const LoadingWidget(message: 'Đang tải gói từ vựng...');
              }
              if (snap.hasError) {
                return EmptyState(
                  icon: LucideIcons.alertCircle,
                  title: 'Lỗi tải gói',
                  subtitle: '${snap.error}',
                );
              }
              final packs = snap.data ?? [];
              if (packs.isEmpty) {
                return EmptyState(
                  icon: LucideIcons.packageOpen,
                  title: 'Chưa sở hữu gói nào',
                  subtitle: 'Mua gói tại Cửa hàng để bắt đầu',
                  action: ElevatedButton.icon(
                    onPressed: () =>
                        Navigator.pushNamed(context, '/shop'),
                    icon: const Icon(LucideIcons.shoppingBag),
                    label: const Text('Đi tới Cửa hàng'),
                  ),
                );
              }
              return CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(child: _buildHeaderBanner()),
                  SliverPadding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    sliver: SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: AppSpacing.sm + 4,
                        mainAxisSpacing: AppSpacing.sm + 4,
                        childAspectRatio: 0.78,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (ctx, i) {
                          final pack = packs[i];
                          final passed =
                              userProv.getProgress(widget.gameType, pack.id);
                          return _PackCard(
                            pack: pack,
                            passed: passed,
                            totalLevels: PackService.levelsPerPack,
                            hex: _hex,
                            onTap: () => _open(pack),
                          )
                              .animate(delay: (i * 60).ms)
                              .fadeIn(duration: 320.ms)
                              .slideY(begin: 0.08, end: 0);
                        },
                        childCount: packs.length,
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(
                        AppSpacing.md, 0, AppSpacing.md, AppSpacing.xl),
                    sliver: SliverToBoxAdapter(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              vertical: AppSpacing.md),
                          shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(AppRadius.md)),
                        ),
                        onPressed: () =>
                            Navigator.pushNamed(context, '/shop'),
                        icon: const Icon(LucideIcons.shoppingBag, size: 18),
                        label: const Text('Mua gói mới tại Cửa hàng'),
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildHeaderBanner() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.md, 0, AppSpacing.md, AppSpacing.sm),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: widget.gameGradient),
          borderRadius: BorderRadius.circular(AppRadius.lg),
          boxShadow: AppShadow.colored(widget.gameGradient.first),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.22),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Icon(widget.gameIcon, color: Colors.white, size: 28),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Chọn gói từ vựng',
                    style: AppText.subtitle.copyWith(color: Colors.white),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '3 level / gói · pass ≥ 2 sao để mở khoá',
                    style: AppText.caption.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 300.ms);
  }

  void _open(VocabPack pack) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LevelMapScreen(
          gameType: widget.gameType,
          gameTitle: widget.gameTitle,
          gameGradient: widget.gameGradient,
          pack: pack,
        ),
      ),
    );
  }
}

class _PackCard extends StatelessWidget {
  final VocabPack pack;
  final int passed;
  final int totalLevels;
  final Color Function(String) hex;
  final VoidCallback onTap;

  const _PackCard({
    required this.pack,
    required this.passed,
    required this.totalLevels,
    required this.hex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = pack.gradient.map(hex).toList();
    final completed = passed >= totalLevels;
    final progress = totalLevels == 0 ? 0.0 : passed / totalLevels;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color ?? Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: colors.first.withValues(alpha: 0.2),
            width: 1.5,
          ),
          boxShadow: AppShadow.soft,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail + progress ring
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 84,
                  height: 84,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: colors.length >= 2
                          ? colors
                          : [AppColors.primary, AppColors.primaryDark],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: AppShadow.colored(colors.first, alpha: 0.35),
                  ),
                  child: Center(
                    child: Text(
                      pack.emoji,
                      style: const TextStyle(fontSize: 40),
                    ),
                  ),
                ),
                // Progress ring
                SizedBox(
                  width: 96,
                  height: 96,
                  child: CircularPercentIndicator(
                    radius: 48,
                    lineWidth: 4,
                    percent: progress.clamp(0.0, 1.0),
                    backgroundColor: Colors.grey.withValues(alpha: 0.15),
                    progressColor: const Color(0xFFFFB300),
                    circularStrokeCap: CircularStrokeCap.round,
                    animation: true,
                    animationDuration: 600,
                  ),
                ),
                if (completed)
                  Positioned(
                    right: 0,
                    top: 2,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: Colors.amber,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(LucideIcons.crown,
                          color: Colors.white, size: 12),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              pack.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppText.subtitle.copyWith(fontSize: 15),
            ),
            const SizedBox(height: 2),
            Text(
              pack.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppText.caption.copyWith(fontSize: 11.5, height: 1.3),
            ),
            const Spacer(),
            Row(
              children: [
                Icon(LucideIcons.bookOpen,
                    size: 13,
                    color: AppColors.textSecondary.withValues(alpha: 0.8)),
                const SizedBox(width: 4),
                Text('${pack.wordCount} từ',
                    style: AppText.caption.copyWith(fontSize: 11)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: colors.first.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                  child: Text(
                    '$passed/$totalLevels',
                    style: TextStyle(
                      color: colors.first,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
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

/// Helper meta cho 3 game type (giữ API cũ)
class GameMeta {
  final String type;
  final String title;
  final IconData icon;
  final List<Color> gradient;

  const GameMeta({
    required this.type,
    required this.title,
    required this.icon,
    required this.gradient,
  });

  static const matching = GameMeta(
    type: 'matching',
    title: 'Nối từ',
    icon: FontAwesomeIcons.puzzlePiece,
    gradient: AppColors.gradientPurple,
  );
  static const quiz = GameMeta(
    type: 'quiz',
    title: 'Trắc nghiệm',
    icon: FontAwesomeIcons.circleQuestion,
    gradient: AppColors.gradientOrange,
  );
  static const wordPuzzle = GameMeta(
    type: 'word_puzzle',
    title: 'Xếp chữ',
    icon: FontAwesomeIcons.spellCheck,
    gradient: AppColors.gradientPink,
  );
  static const memory = GameMeta(
    type: 'memory',
    title: 'Lật thẻ',
    icon: FontAwesomeIcons.brain,
    gradient: AppColors.gradientBlue,
  );
}
