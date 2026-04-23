import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../config/design_tokens.dart';
import '../../config/theme.dart';
import '../../models/user_model.dart';
import '../../providers/user_provider.dart';
import '../../services/firestore_service.dart';
import '../../widgets/loading_widget.dart';

// Man hinh Xep hang - hien thi top nguoi choi
class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  bool _rankByXP = false;
  bool _seeding = false;

  Future<void> _seedDemoData() async {
    setState(() => _seeding = true);
    try {
      await _firestoreService.seedLeaderboardDemoUsers();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Da nap 10 du lieu mau leaderboard')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Nap du lieu that bai: $e')),
      );
    } finally {
      if (mounted) setState(() => _seeding = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = context.watch<UserProvider>().user;
    final leaderboardStream = _rankByXP
        ? _firestoreService.streamLeaderboardByXP()
        : _firestoreService.streamLeaderboard();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header voi gradient
            Container(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: AppColors.gradientGold,
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
                        'Bảng xếp hạng',
                        style: AppText.title
                            .copyWith(color: Colors.white, fontSize: 20),
                      ),
                      const Spacer(),
                      IconButton(
                        tooltip: 'Nap du lieu demo',
                        onPressed: _seeding ? null : _seedDemoData,
                        icon: _seeding
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.cloud_upload_outlined,
                                color: Colors.white),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Top 100 nguoi choi gioi nhat',
                    style: AppText.caption.copyWith(
                      color: Colors.white.withValues(alpha: 0.95),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ChoiceChip(
                        label: const Text('Xep hang diem'),
                        selected: !_rankByXP,
                        onSelected: (_) => setState(() => _rankByXP = false),
                      ),
                      const SizedBox(width: 8),
                      ChoiceChip(
                        label: const Text('Xep hang XP'),
                        selected: _rankByXP,
                        onSelected: (_) => setState(() => _rankByXP = true),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Danh sach
            Expanded(
              child: StreamBuilder<List<UserModel>>(
                stream: leaderboardStream,
                builder: (ctx, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const ShimmerList(itemCount: 8);
                  }

                  final list = snap.data ?? [];
                  if (list.isEmpty) {
                    return const EmptyState(
                      icon: LucideIcons.trophy,
                      title: 'Chua co du lieu',
                      subtitle: 'Hay la nguoi dau tien!',
                    );
                  }

                  return Column(
                    children: [
                      if (currentUser != null)
                        _buildMyRankCard(currentUser.uid, _rankByXP),
                      if (list.length >= 3) _buildPodium(list.take(3).toList()),
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.all(AppSizes.padding),
                          itemCount: list.length > 3 ? list.length - 3 : 0,
                          itemBuilder: (ctx, i) {
                            final u = list[i + 3];
                            final rank = i + 4;
                            final isMe = u.uid == currentUser?.uid;
                            return _buildRankCard(u, rank, isMe, i, _rankByXP);
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMyRankCard(String uid, bool rankByXP) {
    final rankFuture = rankByXP
        ? _firestoreService.getUserRankByXP(uid)
        : _firestoreService.getUserRankByScore(uid);
    return FutureBuilder<int?>(
      future: rankFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Padding(
            padding: EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: LinearProgressIndicator(minHeight: 3),
          );
        }
        final rank = snapshot.data;
        if (rank == null) return const SizedBox.shrink();
        return Container(
          margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
            border:
                Border.all(color: AppColors.primary.withValues(alpha: 0.35)),
          ),
          child: Row(
            children: [
              const Icon(Icons.person_pin_circle, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                rankByXP
                    ? 'Hang cua ban theo XP: #$rank'
                    : 'Hang cua ban theo diem: #$rank',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ],
          ),
        );
      },
    );
  }

  // Podium top 3 kieu Olympic
  Widget _buildPodium(List<UserModel> top3) {
    final user1 = top3[0];
    final user2 = top3.length > 1 ? top3[1] : null;
    final user3 = top3.length > 2 ? top3[2] : null;

    return Container(
      padding: const EdgeInsets.all(AppSizes.padding),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (user2 != null)
            Expanded(
              child: _buildPodiumItem(
                user2,
                rank: 2,
                height: 110,
                color: Colors.grey.shade400,
                icon: FontAwesomeIcons.medal,
              ),
            )
          else
            const Expanded(child: SizedBox()),
          Expanded(
            child: _buildPodiumItem(
              user1,
              rank: 1,
              height: 150,
              color: Colors.amber,
              icon: FontAwesomeIcons.crown,
            ),
          ),
          if (user3 != null)
            Expanded(
              child: _buildPodiumItem(
                user3,
                rank: 3,
                height: 90,
                color: Colors.brown.shade300,
                icon: FontAwesomeIcons.medal,
              ),
            )
          else
            const Expanded(child: SizedBox()),
        ],
      ),
    );
  }

  Widget _buildPodiumItem(
    UserModel u, {
    required int rank,
    required double height,
    required Color color,
    required IconData icon,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        CircleAvatar(
          radius: rank == 1 ? 34 : 28,
          backgroundColor: color,
          child: CircleAvatar(
            radius: rank == 1 ? 30 : 24,
            backgroundColor: Colors.white,
            child: Text(
              u.displayName.isNotEmpty ? u.displayName[0].toUpperCase() : 'U',
              style: TextStyle(
                fontSize: rank == 1 ? 24 : 18,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          u.displayName.isEmpty ? 'An danh' : u.displayName,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
        Text(
          '${u.totalScore}d',
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          height: height,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color, color.withValues(alpha: 0.7)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
          ),
          child: Center(
            child: Text(
              '$rank',
              style: const TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    ).animate(delay: (rank * 200).ms).fadeIn().slideY(begin: 0.3, end: 0);
  }

  Widget _buildRankCard(
      UserModel u, int rank, bool isMe, int index, bool rankByXP) {
    final metricValue = rankByXP ? u.totalXP : u.totalScore;
    final metricLabel = rankByXP ? 'XP' : 'Diem';
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isMe ? AppColors.primary.withValues(alpha: 0.1) : Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radius),
        border: isMe ? Border.all(color: AppColors.primary, width: 2) : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            alignment: Alignment.center,
            child: Text(
              '$rank',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: isMe ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            radius: 22,
            backgroundColor: AppColors.primary.withValues(alpha: 0.15),
            child: Text(
              u.displayName.isNotEmpty ? u.displayName[0].toUpperCase() : 'U',
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        u.displayName.isEmpty ? 'An danh' : u.displayName,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isMe) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'Ban',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                Text(
                  'Lv ${u.level} - ${u.totalXP} XP',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: [
                  const Icon(FontAwesomeIcons.trophy,
                      color: Colors.orange, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    '$metricValue',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.orange,
                    ),
                  ),
                ],
              ),
              Text(
                metricLabel,
                style: const TextStyle(
                  fontSize: 10,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    )
        .animate(delay: (index * 30).ms)
        .fadeIn(duration: 250.ms)
        .slideX(begin: 0.1, end: 0);
  }
}
