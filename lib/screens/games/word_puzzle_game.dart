import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
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

/// 🔤 GAME 3: XẾP CHỮ - Xếp các chữ cái thành từ tiếng Anh đúng
class WordPuzzleGame extends StatefulWidget {
  final String level;
  final List<VocabModel>? words;
  final String? packId;
  final int? levelIndex;
  const WordPuzzleGame({
    super.key,
    required this.level,
    this.words,
    this.packId,
    this.levelIndex,
  });

  @override
  State<WordPuzzleGame> createState() => _WordPuzzleGameState();
}

class _WordPuzzleGameState extends State<WordPuzzleGame> {
  List<VocabModel> _words = [];
  int _currentIdx = 0;
  int _score = 0;
  bool _isLoading = true;

  List<String> _shuffledLetters = [];
  List<String?> _selectedLetters = [];
  List<int> _selectedIndexes = [];
  bool _showResult = false;
  bool _isCorrect = false;

  @override
  void initState() {
    super.initState();
    context.read<GameProvider>().startGame();
    _loadGame();
  }

  Future<void> _loadGame() async {
    final List<VocabModel> all;
    if (widget.words != null && widget.words!.isNotEmpty) {
      all = List<VocabModel>.from(widget.words!);
    } else {
      all = await JsonService.loadVocab(widget.level);
    }
    all.shuffle(Random());
    _words = all.take(AppConstants.puzzleGameWords).toList();
    setState(() {
      _isLoading = false;
      _setupPuzzle();
    });
  }

  void _setupPuzzle() {
    final word = _words[_currentIdx].word.toUpperCase();
    final letters = word.split('');
    letters.shuffle(Random());
    _shuffledLetters = letters;
    _selectedLetters = List.filled(word.length, null);
    _selectedIndexes = [];
    _showResult = false;
    _isCorrect = false;
  }

  void _onLetterTap(int shuffledIdx) {
    if (_showResult || _selectedIndexes.contains(shuffledIdx)) return;

    final emptyPos = _selectedLetters.indexOf(null);
    if (emptyPos == -1) return;

    setState(() {
      _selectedLetters[emptyPos] = _shuffledLetters[shuffledIdx];
      _selectedIndexes.add(shuffledIdx);
    });

    // Đã điền đủ -> kiểm tra
    if (!_selectedLetters.contains(null)) {
      _checkAnswer();
    }
  }

  void _onSelectedLetterTap(int pos) {
    if (_showResult || _selectedLetters[pos] == null) return;

    setState(() {
      // Trả lại letter về shuffled (unlock lại index)
      final letter = _selectedLetters[pos];
      // Tìm 1 shuffled index đang bị dùng mà chứa letter này
      for (final idx in _selectedIndexes) {
        if (_shuffledLetters[idx] == letter) {
          _selectedIndexes.remove(idx);
          break;
        }
      }
      _selectedLetters[pos] = null;
    });
  }

  void _checkAnswer() {
    final userAnswer = _selectedLetters.join();
    final correct = _words[_currentIdx].word.toUpperCase();

    setState(() {
      _showResult = true;
      _isCorrect = userAnswer == correct;
    });

    if (_isCorrect) {
      _score += 20;
      context.read<GameProvider>()
        ..addCorrect()
        ..addScore(20);
      AudioService.instance.playCorrect();
    } else {
      context.read<GameProvider>().addWrong();
      AudioService.instance.playWrong();
    }

    Future.delayed(const Duration(milliseconds: 1800), _nextWord);
  }

  void _clearAnswer() {
    setState(() {
      _selectedLetters = List.filled(_selectedLetters.length, null);
      _selectedIndexes = [];
    });
  }

  void _useHint() {
    final user = context.read<UserProvider>().user;
    if (user == null || user.totalCoins < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không đủ coin! (cần 10)')),
      );
      return;
    }

    // Tìm chữ đầu tiên chưa điền đúng
    final word = _words[_currentIdx].word.toUpperCase();
    for (int i = 0; i < word.length; i++) {
      if (_selectedLetters[i] != word[i]) {
        // Xóa vị trí hiện tại (nếu có)
        if (_selectedLetters[i] != null) {
          _onSelectedLetterTap(i);
        }
        // Tìm index shuffled chưa dùng, có ký tự đúng
        for (int j = 0; j < _shuffledLetters.length; j++) {
          if (!_selectedIndexes.contains(j) && _shuffledLetters[j] == word[i]) {
            setState(() {
              _selectedLetters[i] = _shuffledLetters[j];
              _selectedIndexes.add(j);
            });
            break;
          }
        }
        break;
      }
    }

    context.read<UserProvider>().updateLocalUser(addCoins: -10);
  }

  void _nextWord() {
    if (!mounted) return;
    if (_currentIdx >= _words.length - 1) {
      _endGame();
      return;
    }
    setState(() {
      _currentIdx++;
      _setupPuzzle();
    });
  }

  Future<void> _endGame() async {
    final user = context.read<UserProvider>().user;
    if (user == null) return;

    final result = await context.read<GameProvider>().finishGame(
          userId: user.uid,
          userName: user.displayName,
          gameType: AppConstants.gameWordPuzzle,
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
        gameType: AppConstants.gameWordPuzzle,
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
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: LoadingWidget(message: 'Đang chuẩn bị câu đố...'),
      );
    }

    final vocab = _words[_currentIdx];

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            _buildProgress(),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSizes.padding),
                child: Column(
                  children: [
                    _buildHintCard(vocab),
                    const SizedBox(height: 24),
                    _buildAnswerSlots(),
                    const SizedBox(height: 24),
                    if (_showResult) _buildResultFeedback(vocab),
                    if (!_showResult) _buildLetterBank(),
                    const SizedBox(height: 24),
                    if (!_showResult) _buildActionButtons(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.md, AppSpacing.md, AppSpacing.md, AppSpacing.sm),
      child: Row(
        children: [
          InkWell(
            onTap: () => Navigator.pop(context),
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFFF9800).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(LucideIcons.trophy,
                    color: Color(0xFFFF9800), size: 16),
                const SizedBox(width: 6),
                Text(
                  '$_score',
                  style: AppText.subtitle.copyWith(
                    color: const Color(0xFFFF9800),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgress() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.padding),
      child: Column(
        children: [
          Text(
            'Câu ${_currentIdx + 1} / ${_words.length}',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          LinearPercentIndicator(
            lineHeight: 8,
            percent: (_currentIdx + 1) / _words.length,
            backgroundColor: Colors.grey.shade200,
            linearGradient:
                const LinearGradient(colors: AppColors.gradientPink),
            barRadius: const Radius.circular(8),
            padding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }

  Widget _buildHintCard(VocabModel vocab) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: AppColors.gradientPink,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondary.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          if (vocab.isEmoji)
            Text(vocab.image, style: const TextStyle(fontSize: 56))
          else
            const Icon(FontAwesomeIcons.lightbulb,
                color: Colors.white, size: 48),
          const SizedBox(height: 12),
          const Text(
            'Xếp các chữ thành từ có nghĩa:',
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 6),
          Text(
            vocab.meaning,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnswerSlots() {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 6,
      runSpacing: 6,
      children: List.generate(_selectedLetters.length, (i) {
        final letter = _selectedLetters[i];
        final isCorrect =
            _showResult && letter == _words[_currentIdx].word.toUpperCase()[i];
        final isWrong = _showResult && letter != null && !_isCorrect;

        return InkWell(
          onTap: () => _onSelectedLetterTap(i),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 42,
            height: 52,
            decoration: BoxDecoration(
              gradient: letter != null
                  ? LinearGradient(
                      colors: isWrong
                          ? [Colors.red.shade300, Colors.red.shade500]
                          : isCorrect || !_showResult
                              ? AppColors.gradientPurple
                              : AppColors.gradientPurple,
                    )
                  : null,
              color: letter == null ? Colors.white : null,
              borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
              border: Border.all(
                color:
                    letter == null ? Colors.grey.shade300 : Colors.transparent,
                width: 2,
              ),
            ),
            child: Center(
              child: Text(
                letter ?? '',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: letter == null ? Colors.grey : Colors.white,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildLetterBank() {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      runSpacing: 8,
      children: List.generate(_shuffledLetters.length, (i) {
        final isUsed = _selectedIndexes.contains(i);
        return InkWell(
          onTap: () => _onLetterTap(i),
          child: AnimatedOpacity(
            opacity: isUsed ? 0.3 : 1.0,
            duration: const Duration(milliseconds: 200),
            child: Container(
              width: 52,
              height: 62,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppSizes.radius),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  width: 2,
                ),
                boxShadow: isUsed
                    ? []
                    : [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
              ),
              child: Center(
                child: Text(
                  _shuffledLetters[i],
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: isUsed ? Colors.grey : AppColors.primary,
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _clearAnswer,
            icon: const Icon(LucideIcons.eraser),
            label: const Text('Xóa hết'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.radius),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _useHint,
            icon: const Icon(LucideIcons.lightbulb),
            label: const Text('Gợi ý (-10)'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.radius),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResultFeedback(VocabModel vocab) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _isCorrect ? Colors.green.shade50 : Colors.red.shade50,
        borderRadius: BorderRadius.circular(AppSizes.radius),
        border: Border.all(
          color: _isCorrect ? Colors.green : Colors.red,
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Icon(
            _isCorrect ? Icons.check_circle : Icons.cancel,
            color: _isCorrect ? Colors.green : Colors.red,
            size: 48,
          ),
          const SizedBox(height: 8),
          Text(
            _isCorrect ? 'Chính xác!' : 'Đáp án đúng:',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: _isCorrect ? Colors.green : Colors.red,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            vocab.word.toUpperCase(),
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    ).animate().scale(
          duration: 400.ms,
          curve: Curves.elasticOut,
        );
  }
}
