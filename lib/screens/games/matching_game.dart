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

/// 🧩 GAME 1: NỐI TỪ - Match từ tiếng Anh với nghĩa tiếng Việt
class MatchingGame extends StatefulWidget {
  final String level;
  final List<VocabModel>? words;
  final String? packId;
  final int? levelIndex;
  const MatchingGame({
    super.key,
    required this.level,
    this.words,
    this.packId,
    this.levelIndex,
  });

  @override
  State<MatchingGame> createState() => _MatchingGameState();
}

class _MatchingGameState extends State<MatchingGame> {
  List<VocabModel> _pool = []; // toàn bộ từ được phép dùng trong trận (dedupe)
  List<VocabModel> _remainingPool = []; // từ chưa dùng ở các round trước
  List<VocabModel> _words = [];
  List<VocabModel> _shuffledMeanings = [];
  VocabModel? _selectedWord;
  VocabModel? _selectedMeaning;
  final Set<String> _matched = {};
  Set<String> _wrongIds = {}; // cặp vừa nối sai — hiển thị đỏ
  int _score = 0;
  int _round = 1;
  int _totalRounds = 3;
  int _timeLeft = 60;
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
    final maxNoRepeatRounds = _pool.length ~/ AppConstants.matchingGamePairs;
    _totalRounds = maxNoRepeatRounds.clamp(1, 3);
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
    if (_remainingPool.length < AppConstants.matchingGamePairs) {
      _remainingPool = List<VocabModel>.from(_pool)..shuffle(Random());
    }
    final takeCount = _remainingPool.length >= AppConstants.matchingGamePairs
        ? AppConstants.matchingGamePairs
        : _remainingPool.length;
    final pairs = _remainingPool.take(takeCount).toList();
    _remainingPool.removeRange(0, takeCount);
    final meanings = List<VocabModel>.from(pairs)..shuffle(Random());
    setState(() {
      _words = pairs;
      _shuffledMeanings = meanings;
      _matched.clear();
      _selectedWord = null;
      _selectedMeaning = null;
      _wrongIds = {};
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

  void _onSelectWord(VocabModel v) {
    if (_matched.contains(v.id)) return;
    setState(() => _selectedWord = v);
    _checkMatch();
  }

  void _onSelectMeaning(VocabModel v) {
    if (_matched.contains(v.id)) return;
    setState(() => _selectedMeaning = v);
    _checkMatch();
  }

  void _checkMatch() {
    if (_selectedWord != null && _selectedMeaning != null) {
      if (_selectedWord!.id == _selectedMeaning!.id) {
        // Nối đúng
        setState(() {
          _matched.add(_selectedWord!.id);
          _score += 10;
          _selectedWord = null;
          _selectedMeaning = null;
        });
        context.read<GameProvider>()
          ..addCorrect()
          ..addScore(10);
        AudioService.instance.playCorrect();

        if (_matched.length == _words.length) {
          _nextRound();
        }
      } else {
        // Nối sai — hiện đỏ 2 ô 600ms rồi reset
        context.read<GameProvider>().addWrong();
        AudioService.instance.playWrong();
        final wrongWordId = _selectedWord!.id;
        final wrongMeaningId = _selectedMeaning!.id;
        setState(() {
          _wrongIds = {wrongWordId, wrongMeaningId};
        });
        Future.delayed(const Duration(milliseconds: 600), () {
          if (!mounted) return;
          setState(() {
            _selectedWord = null;
            _selectedMeaning = null;
            _wrongIds = {};
          });
        });
      }
    }
  }

  Future<void> _nextRound() async {
    if (_round >= _totalRounds) {
      _endGame();
      return;
    }
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() => _round++);
    _setupRound();
  }

  Future<void> _endGame() async {
    _timer?.cancel();
    final user = context.read<UserProvider>().user;
    if (user == null) return;

    final result = await context.read<GameProvider>().finishGame(
          userId: user.uid,
          userName: user.displayName,
          gameType: AppConstants.gameMatching,
          level: widget.level,
        );

    if (!mounted) return;
    final userProv = context.read<UserProvider>();
    userProv.updateLocalUser(
      addScore: _score,
      addCoins: result.coinsEarned,
      addXP: result.xpEarned,
    );
    LevelReward? reward;
    if (widget.packId != null &&
        widget.levelIndex != null &&
        result.stars >= 2) {
      reward = await userProv.recordLevelComplete(
        gameType: AppConstants.gameMatching,
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
        body: LoadingWidget(message: 'Đang chuẩn bị game...'),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            const SizedBox(height: 16),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    Expanded(child: _buildWordColumn()),
                    const SizedBox(width: 8),
                    Expanded(child: _buildMeaningColumn()),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
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
            onTap: () => _confirmExit(),
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
          _buildStat(LucideIcons.trophy, '$_score', const Color(0xFFFF9800)),
          const SizedBox(width: 8),
          _buildStat(
              LucideIcons.timer,
              '${_timeLeft}s',
              _timeLeft <= 10
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

  Widget _buildWordColumn() {
    return Column(
      children: _words.map((v) {
        final isMatched = _matched.contains(v.id);
        final isSelected = _selectedWord?.id == v.id;
        final isWrong = _wrongIds.contains(v.id);
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _buildCard(
              content: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (v.isEmoji)
                    Text(v.image, style: const TextStyle(fontSize: 40))
                  else
                    const Icon(LucideIcons.image,
                        size: 36, color: Colors.white),
                  const SizedBox(height: 4),
                  Text(
                    v.word,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              isMatched: isMatched,
              isSelected: isSelected,
              isWrong: isWrong,
              gradient: AppColors.gradientPurple,
              onTap: () => _onSelectWord(v),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMeaningColumn() {
    return Column(
      children: _shuffledMeanings.map((v) {
        final isMatched = _matched.contains(v.id);
        final isSelected = _selectedMeaning?.id == v.id;
        final isWrong = _wrongIds.contains(v.id);
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _buildCard(
              content: Center(
                child: Text(
                  v.meaning,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              isMatched: isMatched,
              isSelected: isSelected,
              isWrong: isWrong,
              gradient: AppColors.gradientPink,
              onTap: () => _onSelectMeaning(v),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCard({
    required Widget content,
    required bool isMatched,
    required bool isSelected,
    required bool isWrong,
    required List<Color> gradient,
    required VoidCallback onTap,
  }) {
    final List<Color> activeGradient;
    if (isWrong) {
      activeGradient = [Colors.red.shade400, Colors.red.shade700];
    } else if (isMatched) {
      activeGradient = [Colors.green.shade400, Colors.green.shade600];
    } else {
      activeGradient = gradient;
    }
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      child: InkWell(
        onTap: isMatched ? null : onTap,
        borderRadius: BorderRadius.circular(AppSizes.radius),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: activeGradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(AppSizes.radius),
            border: Border.all(
              color: isWrong
                  ? Colors.red.shade900
                  : (isSelected ? Colors.white : Colors.transparent),
              width: 3,
            ),
            boxShadow: [
              BoxShadow(
                color: (isWrong
                        ? Colors.red
                        : (isMatched ? Colors.green : gradient.first))
                    .withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            children: [
              content,
              if (isMatched)
                const Positioned(
                  top: 0,
                  right: 0,
                  child:
                      Icon(Icons.check_circle, color: Colors.white, size: 20),
                ),
            ],
          ),
        ),
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
