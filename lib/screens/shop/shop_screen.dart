import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../config/design_tokens.dart';
import '../../config/theme.dart';
import '../../models/vocab_pack_model.dart';
import '../../providers/user_provider.dart';
import '../../services/audio_service.dart';
import '../../services/json_service.dart';
import '../../utils/helpers.dart';
import '../../widgets/bubble_back_button.dart';
import '../../widgets/loading_widget.dart';

/// 🛍️ Màn Shop — mua gói từ vựng theo chủ đề bằng coin
class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  late Future<List<VocabPack>> _packsFuture;

  @override
  void initState() {
    super.initState();
    _packsFuture = JsonService.loadPacks();
  }

  Color _parseHex(String h) {
    final hex = h.replaceFirst('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BubbleBackButton(),
        title: Text('Cửa hàng', style: AppText.title.copyWith(fontSize: 20)),
        centerTitle: true,
      ),
      body: Consumer<UserProvider>(
        builder: (context, userProv, _) {
          final user = userProv.user;
          return Column(
            children: [
              _buildCoinHeader(user?.totalCoins ?? 0),
              Expanded(
                child: FutureBuilder<List<VocabPack>>(
                  future: _packsFuture,
                  builder: (ctx, snap) {
                    if (snap.connectionState == ConnectionState.waiting) {
                      return const LoadingWidget(
                          message: 'Đang tải cửa hàng...');
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
                      return const EmptyState(
                        icon: LucideIcons.packageOpen,
                        title: 'Chưa có gói nào',
                        subtitle: 'Hãy quay lại sau nhé',
                      );
                    }
                    return GridView.builder(
                      padding: const EdgeInsets.all(AppSizes.padding),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.78,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: packs.length,
                      itemBuilder: (ctx, i) {
                        final pack = packs[i];
                        final owned = pack.isFree ||
                            (user?.ownedPacks.contains(pack.id) ?? false);
                        return _buildPackCard(pack, owned, i);
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCoinHeader(int coins) {
    return Container(
      margin: const EdgeInsets.fromLTRB(
          AppSpacing.md, 0, AppSpacing.md, AppSpacing.sm),
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.md),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: AppColors.gradientGold),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: AppShadow.colored(const Color(0xFFFFB300)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.25),
              shape: BoxShape.circle,
            ),
            child: const Icon(FontAwesomeIcons.coins,
                color: Colors.white, size: 22),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Số coin của bạn',
                  style: AppText.caption.copyWith(
                    color: Colors.white.withValues(alpha: 0.95),
                    fontSize: 12,
                  ),
                ),
                Text(
                  '$coins',
                  style: AppText.display
                      .copyWith(color: Colors.white, fontSize: 24),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPackCard(VocabPack pack, bool owned, int index) {
    final colors = pack.gradient.map(_parseHex).toList();
    return GestureDetector(
      onTap: () => _onTapPack(pack, owned),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: colors.length >= 2
                ? colors
                : [AppColors.primary, AppColors.primaryDark],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppSizes.radius),
          boxShadow: [
            BoxShadow(
              color: colors.first.withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(pack.emoji, style: const TextStyle(fontSize: 34)),
                if (owned)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_circle, color: Colors.white, size: 14),
                        SizedBox(width: 4),
                        Text(
                          'Đã có',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              pack.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              pack.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.85),
                fontSize: 12,
              ),
            ),
            const Spacer(),
            Row(
              children: [
                Icon(LucideIcons.bookOpen,
                    color: Colors.white.withValues(alpha: 0.9), size: 14),
                const SizedBox(width: 4),
                Text(
                  '${pack.wordCount} từ',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                if (owned)
                  const Icon(LucideIcons.check, color: Colors.white, size: 18)
                else if (pack.isFree)
                  const Text(
                    'MIỄN PHÍ',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 12,
                    ),
                  )
                else
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(FontAwesomeIcons.coins,
                          color: Colors.white, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        '${pack.coinPrice}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ),
      )
          .animate(delay: (index * 60).ms)
          .fadeIn(duration: 300.ms)
          .slideY(begin: 0.1, end: 0),
    );
  }

  void _onTapPack(VocabPack pack, bool owned) {
    if (owned) {
      Helpers.showSnackBar(context, 'Bạn đã sở hữu gói "${pack.title}"');
      return;
    }
    if (pack.isFree) {
      _confirmPurchase(pack);
      return;
    }
    _confirmPurchase(pack);
  }

  void _confirmPurchase(VocabPack pack) {
    final user = context.read<UserProvider>().user;
    final coins = user?.totalCoins ?? 0;
    final canAfford = coins >= pack.coinPrice;

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radius)),
        title: Row(
          children: [
            Text(pack.emoji, style: const TextStyle(fontSize: 28)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                pack.title,
                style:
                    const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(pack.description,
                style: const TextStyle(
                    fontSize: 13, color: AppColors.textSecondary)),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(LucideIcons.bookOpen, size: 16),
                const SizedBox(width: 6),
                Text('${pack.wordCount} từ vựng',
                    style: const TextStyle(fontSize: 13)),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(FontAwesomeIcons.coins,
                    size: 14, color: Colors.orange),
                const SizedBox(width: 6),
                Text(
                  pack.isFree
                      ? 'Miễn phí'
                      : 'Giá: ${pack.coinPrice} coin  (bạn có $coins)',
                  style: TextStyle(
                    fontSize: 13,
                    color: canAfford ? null : Colors.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: canAfford
                ? () async {
                    Navigator.pop(dialogCtx);
                    await _doPurchase(pack);
                  }
                : null,
            child: Text(pack.isFree ? 'Nhận' : 'Mua'),
          ),
        ],
      ),
    );
  }

  Future<void> _doPurchase(VocabPack pack) async {
    final userProv = context.read<UserProvider>();
    final err = await userProv.purchasePack(
      packId: pack.id,
      price: pack.coinPrice,
    );
    if (!mounted) return;
    if (err == null) {
      AudioService.instance.playUiClickAsset();
      Helpers.showSuccess(context, 'Đã mở khoá gói "${pack.title}"! 🎉');
    } else {
      AudioService.instance.playWrong();
      Helpers.showError(context, err);
    }
  }
}
