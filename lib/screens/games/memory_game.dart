import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../config/constants.dart';
import '../../config/design_tokens.dart';
import '../../config/theme.dart';
import '../../models/vocab_model.dart';
import '../../models/level_reward_model.dart';
import '../../providers/game_provider.dart';
import '../../providers/user_provider.dart';
import '../../services/audio_service.dart';
import '../../services/json_service.dart';
import '../../widgets/loading_widget.dart';
import 'game_result_screen.dart';

/// 🧠 GAME 4: LẬT THẺ (Memory / Pexeso)
///
/// Số cặp/round scale theo level: L1=4, L2=6, L3=8 → level mới nhiều cặp hơn.
/// Lật 2 thẻ, nếu cùng vocabId → giữ lật. Nếu khác → úp lại sau 800ms.
/// Điểm: max 100, mỗi cặp lần đầu = `100/totalPairs`đ; sau khi sai = nửa.
/// Sao tính theo thời gian còn lại khi ghép xong toàn bộ:
///   • Ghép xong + còn ≥50s → 3⭐ (đủ điều kiện mở level mới).
///   • Ghép xong + còn ≥30s → 2⭐.
///   • Ghép xong + còn ≥1s  → 1⭐.
///   • Chưa ghép xong       → 0⭐.
class MemoryGame extends StatefulWidget {
  final String level;
  final List<VocabModel>? words;
  final String? packId;
  final int? levelIndex;
  const MemoryGame({
    super.key,
    required this.level,
    this.words,
    this.packId,
    this.levelIndex,
  });

  @override
  State<MemoryGame> createState() => _MemoryGameState();
}

class _MemoryGameState extends State<MemoryGame> {
  static const int _totalTime = 90;
  static const int _maxScore = 100;
  // Ngưỡng thời gian còn lại để chấm sao (giây).
  static const int _starThreshold3 = 50;
  static const int _starThreshold2 = 30;
  static const int _starThreshold1 = 1;

  /// Số cặp/round theo level: level cao → nhiều cặp hơn để lật.
  int get _pairsPerRound {
    switch (widget.levelIndex) {
      case 1:
        return 4;
      case 2:
        return 6;
      case 3:
        return 8;
      default:
        return 6;
    }
  }

  /// Số cột grid khớp với số cặp để layout cân đối.
  int get _gridCrossAxisCount {
    switch (_pairsPerRound) {
      case 4:
        return 4; // 8 thẻ → 4 cột × 2 hàng
      case 8:
        return 4; // 16 thẻ → 4 cột × 4 hàng
      case 6:
      default:
        return 3; // 12 thẻ → 3 cột × 4 hàng
    }
  }

  List<VocabModel> _pool = [];
  List<VocabModel> _remainingPool = [];
  List<_MemoryCard> _cards = [];

  _MemoryCard? _firstPick;
  _MemoryCard? _secondPick;
  bool _canTap = true;

  /// Pair (theo vocabId) đã từng bị mismatch — match sau chỉ được nửa điểm.
  final Set<String> _failedPairIds = {};

  int _firstAttemptMatches = 0;
  int _afterFailMatches = 0;
  int _lastSentScore = 0;
  int _round = 1;
  int _totalRounds = 3;
  int _timeLeft = _totalTime;
  Timer? _timer;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    context.read<GameProvider>().startGame();
    _loadInitial();
  }

  Future<void> _loadInitial() async {
    if (widget.words != null && widget.words!.isNotEmpty) {
      _pool = _dedupeWords(widget.words!);
    } else {
      final loaded = await JsonService.loadVocab(widget.level);
      _pool = _dedupeWords(loaded);
    }
    _remainingPool = List<VocabModel>.from(_pool)..shuffle(Random());
    // No-repeat: nếu pool < pairs * 3 → ít round hơn.
    _totalRounds = (_pool.length ~/ _pairsPerRound).clamp(1, 3);
    _setupRound();
    if (!mounted) return;
    setState(() => _isLoading = false);
    _startTimer();
  }

  String _wordKey(VocabModel v) {
    if (v.id.trim().isNotEmpty) return v.id.trim();
    return '${v.word.toLowerCase()}|${v.meaning.toLowerCase()}';
  }

  List<VocabModel> _dedupeWords(List<VocabModel> list) {
    final seen = <String>{};
    final out = <VocabModel>[];
    for (final v in list) {
      final key = _wordKey(v);
      if (seen.add(key)) out.add(v);
    }
    return out;
  }

  void _setupRound() {
    final takeCount = _remainingPool.length >= _pairsPerRound
        ? _pairsPerRound
        : _remainingPool.length;
    final pairs = _remainingPool.take(takeCount).toList();
    _remainingPool.removeRange(0, takeCount);

    final cards = <_MemoryCard>[];
    for (final v in pairs) {
      cards.add(_MemoryCard(
        vocabId: v.id,
        text: v.word,
        isWord: true,
      ));
      cards.add(_MemoryCard(
        vocabId: v.id,
        text: v.meaning,
        isWord: false,
      ));
    }
    cards.shuffle(Random());

    setState(() {
      _cards = cards;
      _firstPick = null;
      _secondPick = null;
      _canTap = true;
      _failedPairIds.clear();
    });
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_timeLeft > 0) {
        setState(() => _timeLeft--);
      } else {
        _endGame();
      }
    });
  }

  void _onTapCard(_MemoryCard c) {
    if (!_canTap || c.isFlipped || c.isMatched) return;
    AudioService.instance.playClick();

    setState(() {
      c.isFlipped = true;
      if (_firstPick == null) {
        _firstPick = c;
      } else {
        _secondPick = c;
        _canTap = false;
      }
    });

    if (_firstPick != null && _secondPick != null) {
      _checkMatch();
    }
  }

  int get _totalPairs => (_totalRounds * _pairsPerRound).clamp(1, 1 << 30);

  int get _score {
    final raw = _firstAttemptMatches + 0.5 * _afterFailMatches;
    final scaled = (raw / _totalPairs * _maxScore).round();
    return scaled > _maxScore ? _maxScore : scaled;
  }

  /// Đồng bộ delta sang GameProvider sau mỗi lần match.
  void _syncProviderScore() {
    final current = _score;
    final delta = current - _lastSentScore;
    if (delta == 0) return;
    _lastSentScore = current;
    context.read<GameProvider>().addScore(delta);
  }

  void _checkMatch() {
    final first = _firstPick!;
    final second = _secondPick!;
    // Match khi cùng vocabId và 1 cái là word, cái kia là meaning.
    final matched =
        first.vocabId == second.vocabId && first.isWord != second.isWord;

    if (matched) {
      final isFirstAttempt = !_failedPairIds.contains(first.vocabId);
      setState(() {
        first.isMatched = true;
        second.isMatched = true;
        if (isFirstAttempt) {
          _firstAttemptMatches++;
        } else {
          _afterFailMatches++;
        }
        _firstPick = null;
        _secondPick = null;
        _canTap = true;
      });
      if (isFirstAttempt) {
        context.read<GameProvider>().addCorrect();
      }
      _syncProviderScore();
      AudioService.instance.playCorrect();

      // Hết thẻ trong round → next
      if (_cards.every((c) => c.isMatched)) {
        _nextRound();
      }
    } else {
      // Sai — mark pair failed, úp lại sau 800ms.
      _failedPairIds.add(first.vocabId);
      _failedPairIds.add(second.vocabId);
      context.read<GameProvider>().addWrong();
      AudioService.instance.playWrong();

      Future.delayed(const Duration(milliseconds: 800), () {
        if (!mounted) return;
        setState(() {
          first.isFlipped = false;
          second.isFlipped = false;
          _firstPick = null;
          _secondPick = null;
          _canTap = true;
        });
      });
    }
  }

  Future<void> _nextRound() async {
    if (_round >= _totalRounds) {
      _endGame();
      return;
    }
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    setState(() => _round++);
    _setupRound();
  }

  /// Tính sao Memory: chỉ tính khi ghép xong toàn bộ. Sao theo `_timeLeft`.
  /// 3⭐ (đủ điều kiện mở level mới) khi còn ≥ `_starThreshold3` giây.
  int _calcMemoryStars() {
    final pairsMatched = _firstAttemptMatches + _afterFailMatches;
    final allMatched = _totalPairs > 0 && pairsMatched >= _totalPairs;
    if (!allMatched) return 0;
    if (_timeLeft >= _starThreshold3) return 3;
    if (_timeLeft >= _starThreshold2) return 2;
    if (_timeLeft >= _starThreshold1) return 1;
    return 0;
  }

  Future<void> _endGame() async {
    _timer?.cancel();
    final user = context.read<UserProvider>().user;
    if (user == null) return;

    final memoryStats = MemoryStats(
      pairsMatched: _firstAttemptMatches + _afterFailMatches,
      pairsTotal: _totalPairs,
      timeLeft: _timeLeft,
      totalTime: _totalTime,
    );
    final memoryStars = _calcMemoryStars();

    final outcome = await context.read<GameProvider>().finishGame(
          userId: user.uid,
          userName: user.displayName,
          gameType: AppConstants.gameMemory,
          level: widget.level,
        );
    final result = outcome.result;

    if (!mounted) return;
    final userProv = context.read<UserProvider>();
    userProv.updateLocalUser(
      addScore: _score,
      addCoins: result.coinsEarned + outcome.streak.bonusCoins,
      addXP: result.xpEarned + outcome.streak.bonusXP,
    );
    userProv.applyStreakOutcome(outcome.streak);

    LevelReward? reward;
    // Mở level mới chỉ khi ghép xong toàn bộ + còn ≥ _starThreshold3 giây.
    if (widget.packId != null &&
        widget.levelIndex != null &&
        memoryStars >= 3) {
      reward = await userProv.recordLevelComplete(
        gameType: AppConstants.gameMemory,
        packId: widget.packId!,
        level: widget.levelIndex!,
      );
    }

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => GameResultScreen(
          result: result,
          levelReward: reward,
          packId: widget.packId,
          levelIndex: widget.levelIndex,
          streakOutcome: outcome.streak,
          memoryStats: memoryStats,
          overrideStars: memoryStars,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: LoadingWidget(message: 'Đang chuẩn bị thẻ...'),
      );
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _confirmExit();
      },
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              _buildTopBar(),
              const SizedBox(height: 12),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 4),
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: _gridCrossAxisCount,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 0.85,
                    ),
                    itemCount: _cards.length,
                    itemBuilder: (ctx, i) => _FlipCardView(
                      card: _cards[i],
                      onTap: () => _onTapCard(_cards[i]),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.md, AppSpacing.sm, AppSpacing.md, AppSpacing.md),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: AppShadow.soft,
      ),
      child: Row(
        children: [
          InkWell(
            onTap: _confirmExit,
            borderRadius: BorderRadius.circular(AppRadius.pill),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Theme.of(context).cardTheme.color ?? Colors.white,
                shape: BoxShape.circle,
                boxShadow: AppShadow.soft,
              ),
              child: Icon(Icons.close,
                  size: 20, color: Theme.of(context).colorScheme.onSurface),
            ),
          ),
          const Spacer(),
          _buildStat(LucideIcons.trophy, '$_score',
              const Color(0xFFFF9800)),
          const SizedBox(width: 8),
          _buildStat(
              LucideIcons.timer,
              '${_timeLeft}s',
              _timeLeft <= 15
                  ? const Color(0xFFFF5252)
                  : const Color(0xFF2196F3)),
          const SizedBox(width: 8),
          _buildStat(LucideIcons.target, '$_round/$_totalRounds',
              const Color(0xFF43A047)),
        ],
      ),
    );
  }

  Widget _buildStat(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: color),
          const SizedBox(width: 5),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w800,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  void _confirmExit() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Thoát game?'),
        content: const Text('Bạn sẽ mất tiến trình hiện tại.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Chơi tiếp'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Thoát'),
          ),
        ],
      ),
    );
  }
}

/// Model 1 thẻ trong memory game.
class _MemoryCard {
  final String vocabId;
  final String text;
  final bool isWord;
  bool isFlipped;
  bool isMatched;

  _MemoryCard({
    required this.vocabId,
    required this.text,
    required this.isWord,
  })  : isFlipped = false,
        isMatched = false;
}

/// Widget thẻ với flip 3D animation (Matrix4.rotateY).
class _FlipCardView extends StatelessWidget {
  final _MemoryCard card;
  final VoidCallback onTap;

  const _FlipCardView({required this.card, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final showFront = card.isFlipped || card.isMatched;
    return GestureDetector(
      onTap: onTap,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: showFront ? 1 : 0),
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
        builder: (context, value, _) {
          final angle = value * pi;
          final isBackVisible = value < 0.5;
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.0015) // perspective
              ..rotateY(angle),
            child: isBackVisible
                ? _buildBack(card.isWord)
                : Transform(
                    alignment: Alignment.center,
                    // Flip ngược để chữ không bị mirror khi angle > pi/2
                    transform: Matrix4.identity()..rotateY(pi),
                    child: _buildFront(),
                  ),
          );
        },
      ),
    );
  }

  Widget _buildBack(bool isWord) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: AppColors.gradientPurple,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Decorative rings
          Positioned(
            top: -8,
            right: -8,
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -8,
            left: -8,
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
            ),
          ),
          // Hint badge: góc trên-trái, cho biết thẻ thuộc loại English / VN
          Positioned(
            top: 6,
            left: 6,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.22),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                isWord ? 'EN' : 'VI',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
          Center(
            child: Icon(
              isWord ? LucideIcons.globe : LucideIcons.languages,
              color: Colors.white.withValues(alpha: 0.85),
              size: 30,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFront() {
    final gradient =
        card.isMatched ? _matchedGradient : _frontGradient(card.isWord);
    final borderGlow = card.isMatched ? Colors.green : Colors.transparent;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderGlow, width: 2),
        boxShadow: [
          BoxShadow(
            color: gradient.first.withValues(alpha: 0.35),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Stack(
          children: [
            Center(
              child: Text(
                card.text,
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: card.text.length > 10 ? 12 : 15,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  height: 1.2,
                ),
              ),
            ),
            if (card.isMatched)
              const Positioned(
                top: 4,
                right: 4,
                child: Icon(Icons.check_circle,
                    color: Colors.white, size: 16),
              ),
          ],
        ),
      ),
    );
  }

  List<Color> _frontGradient(bool isWord) {
    // Word = xanh dương, Meaning = hồng — giúp user phân biệt nhanh
    return isWord ? AppColors.gradientBlue : AppColors.gradientPink;
  }

  static const List<Color> _matchedGradient = [
    Color(0xFF43E97B),
    Color(0xFF38F9D7),
  ];
}
