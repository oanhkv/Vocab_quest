import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../config/constants.dart';
import '../../config/theme.dart';
import '../../models/vocab_model.dart';
import '../../providers/game_provider.dart';
import '../../providers/user_provider.dart';
import '../../services/json_service.dart';
import '../../widgets/loading_widget.dart';
import 'game_result_screen.dart';

/// 🧩 GAME 1: NỐI TỪ - Match từ tiếng Anh với nghĩa tiếng Việt
class MatchingGame extends StatefulWidget {
  final String level;
  const MatchingGame({super.key, required this.level});

  @override
  State<MatchingGame> createState() => _MatchingGameState();
}

class _MatchingGameState extends State<MatchingGame> {
  List<VocabModel> _words = [];
  List<VocabModel> _shuffledMeanings = [];
  VocabModel? _selectedWord;
  VocabModel? _selectedMeaning;
  final Set<String> _matched = {};
  int _score = 0;
  int _round = 1;
  int _timeLeft = 60;
  Timer? _timer;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    context.read<GameProvider>().startGame();
    _loadGame();
  }

  Future<void> _loadGame() async {
    final all = await JsonService.loadVocab(widget.level);
    all.shuffle(Random());
    setState(() {
      _words = all.take(AppConstants.matchingGamePairs).toList();
      _shuffledMeanings = List.from(_words)..shuffle(Random());
      _isLoading = false;
    });
    _startTimer();
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

        if (_matched.length == _words.length) {
          _nextRound();
        }
      } else {
        // Nối sai
        context.read<GameProvider>().addWrong();
        Future.delayed(const Duration(milliseconds: 500), () {
          if (!mounted) return;
          setState(() {
            _selectedWord = null;
            _selectedMeaning = null;
          });
        });
      }
    }
  }

  Future<void> _nextRound() async {
    if (_round >= 3) {
      _endGame();
      return;
    }
    await Future.delayed(const Duration(milliseconds: 600));
    setState(() => _round++);
    _loadGame();
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
    context.read<UserProvider>().updateLocalUser(
      addScore: _score,
      addCoins: result.coinsEarned,
      addXP: result.xpEarned,
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => GameResultScreen(result: result)),
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
      backgroundColor: AppColors.background,
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
      padding: const EdgeInsets.all(AppSizes.padding),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => _confirmExit(),
          ),
          _buildStat(LucideIcons.trophy, '$_score', Colors.orange),
          const SizedBox(width: 12),
          _buildStat(LucideIcons.timer, '${_timeLeft}s',
              _timeLeft <= 10 ? Colors.red : Colors.blue),
          const SizedBox(width: 12),
          _buildStat(LucideIcons.target, '$_round/3', Colors.green),
        ],
      ),
    );
  }

  Widget _buildStat(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w700,
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
                    const Icon(LucideIcons.image, size: 36, color: Colors.white),
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
    required List<Color> gradient,
    required VoidCallback onTap,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      child: InkWell(
        onTap: isMatched ? null : onTap,
        borderRadius: BorderRadius.circular(AppSizes.radius),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isMatched
                  ? [Colors.green.shade400, Colors.green.shade600]
                  : gradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(AppSizes.radius),
            border: Border.all(
              color: isSelected ? Colors.white : Colors.transparent,
              width: 3,
            ),
            boxShadow: [
              BoxShadow(
                color: (isMatched ? Colors.green : gradient.first)
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
                  child: Icon(Icons.check_circle,
                      color: Colors.white, size: 20),
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