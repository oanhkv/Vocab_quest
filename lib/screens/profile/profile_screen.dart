import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:provider/provider.dart';

import '../../config/constants.dart';
import '../../config/design_tokens.dart';
import '../../config/theme.dart';
import '../../providers/user_provider.dart';
import '../../services/firestore_service.dart';
import '../../utils/helpers.dart';

/// 👤 Màn hình hồ sơ cá nhân
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, int>? _stats;
  bool _isLoadingStats = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final user = context.read<UserProvider>().user;
    if (user == null) return;
    final stats = await FirestoreService().getGameStats(user.uid);
    if (mounted) {
      setState(() {
        _stats = stats;
        _isLoadingStats = false;
      });
    }
  }

  void _editName() {
    final user = context.read<UserProvider>().user;
    if (user == null) return;
    final ctrl = TextEditingController(text: user.displayName);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radius)),
        title: const Text('Đổi tên'),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(
            labelText: 'Tên hiển thị',
            prefixIcon: Icon(LucideIcons.user),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (ctrl.text.trim().isEmpty) return;
              await context
                  .read<UserProvider>()
                  .updateDisplayName(ctrl.text.trim());
              if (!mounted) return;
              Navigator.pop(context);
              Helpers.showSuccess(context, 'Đã cập nhật');
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<UserProvider>(
        builder: (context, userProvider, _) {
          final user = userProvider.user;
          if (user == null) {
            return const Center(child: Text('Vui lòng đăng nhập'));
          }

          final currentLv = LevelSystem.getLevelFromXP(user.totalXP);
          final nextLvXP = LevelSystem.getXPForNextLevel(currentLv);
          final currentLvXP =
              LevelSystem.xpThresholds[currentLv] ?? 0;
          final progress = nextLvXP == 99999
              ? 1.0
              : (user.totalXP - currentLvXP) /
              (nextLvXP - currentLvXP);

          return SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Header gradient
                  _buildHeader(user, currentLv, progress, nextLvXP),

                  Padding(
                    padding: const EdgeInsets.all(AppSizes.padding),
                    child: Column(
                      children: [
                        // Stats cards
                        _buildStatsGrid(user),
                        const SizedBox(height: 20),

                        // Game stats
                        _buildGameStatsCard(),
                        const SizedBox(height: 20),

                        // Menu
                        _buildMenuCard(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(user, int currentLv, double progress, int nextLvXP) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: AppColors.gradientPurple,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              InkWell(
                onTap: () => Navigator.pop(context),
                borderRadius: BorderRadius.circular(AppRadius.pill),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.22),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.arrow_back,
                      color: Colors.white, size: 20),
                ),
              ),
              const Spacer(),
              Text(
                'Hồ sơ',
                style: AppText.title
                    .copyWith(color: Colors.white, fontSize: 20),
              ),
              const Spacer(),
              InkWell(
                onTap: () => Navigator.pushNamed(context, '/settings'),
                borderRadius: BorderRadius.circular(AppRadius.pill),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.22),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(LucideIcons.settings,
                      color: Colors.white, size: 20),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Avatar
          Stack(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                ),
                child: CircleAvatar(
                  radius: 45,
                  backgroundColor: Colors.white,
                  child: Text(
                    user.displayName.isNotEmpty
                        ? user.displayName[0].toUpperCase()
                        : 'U',
                    style: const TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.w900,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: Text(
                    'Lv$currentLv',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ],
          )
              .animate()
              .scale(duration: 400.ms, curve: Curves.elasticOut),

          const SizedBox(height: 12),

          // Tên
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                user.displayName,
                style: AppText.display.copyWith(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
              const SizedBox(width: 6),
              InkWell(
                onTap: _editName,
                child: const Icon(LucideIcons.edit,
                    color: Colors.white70, size: 18),
              ),
            ],
          ),
          Text(
            user.email,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 16),

          // XP progress
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(AppSizes.radius),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Cấp $currentLv',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      '${user.totalXP} / $nextLvXP XP',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearPercentIndicator(
                  lineHeight: 8,
                  percent: progress.clamp(0.0, 1.0),
                  backgroundColor: Colors.white.withValues(alpha: 0.3),
                  progressColor: AppColors.accent,
                  barRadius: const Radius.circular(8),
                  padding: EdgeInsets.zero,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(user) {
    return Row(
      children: [
        Expanded(
          child: _statCard(
            icon: FontAwesomeIcons.trophy,
            value: '${user.totalScore}',
            label: 'Điểm',
            color: Colors.orange,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _statCard(
            icon: FontAwesomeIcons.coins,
            value: '${user.totalCoins}',
            label: 'Coin',
            color: Colors.amber,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _statCard(
            icon: LucideIcons.flame,
            value: '${user.streak}',
            label: 'Streak',
            color: Colors.red,
          ),
        ),
      ],
    );
  }

  Widget _statCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color ?? Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.md),
        boxShadow: AppShadow.soft,
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppText.stat.copyWith(fontSize: 20),
          ),
          Text(label, style: AppText.caption.copyWith(fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildGameStatsCard() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color ?? Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.md),
        boxShadow: AppShadow.soft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(LucideIcons.barChart3,
                  color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text('Thống kê game',
                  style: AppText.subtitle.copyWith(fontSize: 16)),
            ],
          ),
          const SizedBox(height: 16),
          if (_isLoadingStats)
            const Center(child: CircularProgressIndicator())
          else
            Row(
              children: [
                Expanded(
                  child: _miniStat('Tổng', '${_stats?['total'] ?? 0}',
                      FontAwesomeIcons.gamepad, Colors.blue),
                ),
                Expanded(
                  child: _miniStat('Nối từ', '${_stats?['matching'] ?? 0}',
                      FontAwesomeIcons.puzzlePiece, Colors.purple),
                ),
                Expanded(
                  child: _miniStat('Quiz', '${_stats?['quiz'] ?? 0}',
                      FontAwesomeIcons.circleQuestion, Colors.orange),
                ),
                Expanded(
                  child: _miniStat('Xếp chữ', '${_stats?['word_puzzle'] ?? 0}',
                      FontAwesomeIcons.spellCheck, Colors.pink),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _miniStat(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildMenuCard() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color ?? Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.md),
        boxShadow: AppShadow.soft,
      ),
      child: Column(
        children: [
          _menuTile(
            icon: LucideIcons.history,
            iconColor: Colors.blue,
            title: 'Lịch sử chơi',
            onTap: () => Navigator.pushNamed(context, '/history'),
          ),
          const Divider(height: 1, indent: 62),
          _menuTile(
            icon: LucideIcons.trophy,
            iconColor: Colors.amber,
            title: 'Bảng xếp hạng',
            onTap: () => Navigator.pushNamed(context, '/leaderboard'),
          ),
          const Divider(height: 1, indent: 62),
          _menuTile(
            icon: LucideIcons.settings,
            iconColor: Colors.grey,
            title: 'Cài đặt',
            onTap: () => Navigator.pushNamed(context, '/settings'),
          ),
          const Divider(height: 1, indent: 62),
          _menuTile(
            icon: LucideIcons.logOut,
            iconColor: Colors.red,
            title: 'Đăng xuất',
            onTap: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Đăng xuất?'),
                  content: const Text('Bạn có chắc muốn đăng xuất không?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Hủy'),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red),
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Đăng xuất'),
                    ),
                  ],
                ),
              );
              if (confirmed == true) {
                if (!mounted) return;
                await context.read<UserProvider>().logout();
                if (!mounted) return;
                Navigator.pushNamedAndRemoveUntil(
                    context, '/login', (r) => false);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _menuTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}