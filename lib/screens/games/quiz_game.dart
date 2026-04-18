import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:provider/provider.dart';

import '../../config/constants.dart';
import '../../config/theme.dart';
import '../../models/vocab_model.dart';
import '../../providers/game_provider.dart';
import '../../providers/user_provider.dart';
import '../../services/json_service.dart';
import '../../widgets/loading_widget.dart';
import 'game_result_screen.dart';

/// ❓ GAME 2: TRẮC NGHIỆM - Hiển thị từ tiếng Anh, chọn nghĩa đúng trong 4 đáp án
class QuizGame extends StatefulWidget {
  final String level;
  const QuizGame({super.key, required this.level});

  @override
  State<QuizGame> createState() => _QuizGameState();
}

class _QuizGameState extends State<QuizGame> {
  List<VocabModel> _allWords = [];
  List<VocabModel> _questions = [];
  List<List<VocabModel>> _options = [];
  int _currentIdx = 0;
  int _score = 0;
  VocabModel? _selectedAnswer;
  bool _showResult = false;
  bool _isLoading = true;
  Timer? _timer;
  int _timeLeftForQuestion = 15;
  final FlutterTts _tts = FlutterTts();

  @override
  void initState() {
    super.initState();
    context.read<GameProvider>().startGame();
    _loadGame();
    _tts.setLanguage('en-US');
    _tts.setSpeechRate(0.5);
  }

  Future<void> _loadGame() async {
    _allWords = await JsonService.loadVocab(widget.level);
    _allWords.shuffle(Random());

    _questions = _allWords.take(AppConstants.quizGameQuestions).toList();
    _options = _questions.map(_generateOptions).toList();

    setState(() => _isLoading = false);
    _startQuestionTimer();
  }

  List<VocabModel> _generateOptions(VocabModel correct) {
    final distractors = _allWords
        .where((w) => w.id != correct.id)
        .toList()
      ..shuffle();
    final opts = [correct, ...distractors.take(3)];
    opts.shuffle();
    return opts;
  }

  void _startQuestionTimer() {
    _timer?.cancel();
    _timeLeftForQuestion = 15;
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_timeLeftForQuestion > 0) {
        setState(() => _timeLeftForQuestion--);
      } else {
        _timeOut();
      }
    });
  }

  void _timeOut() {
    _timer?.cancel();
    setState(() {
      _showResult = true;
      _selectedAnswer = null;
    });
    context.read<GameProvider>().addWrong();
    Future.delayed(const Duration(seconds: 2), _nextQuestion);
  }

  Future<void> _speak() async {
    if (_questions.isNotEmpty) {
      await _tts.speak(_questions[_currentIdx].word);
    }
  }

  void _selectAnswer(VocabModel answer) {
    if (_showResult) return;
    _timer?.cancel();

    final isCorrect = answer.id == _questions[_currentIdx].id;
    setState(() {
      _selectedAnswer = answer;
      _showResult = true;
      if (isCorrect) {
        _score += (10 + _timeLeftForQuestion);
        context.read<GameProvider>()
          ..addCorrect()
          ..addScore(10 + _timeLeftForQuestion);
      } else {
        context.read<GameProvider>().addWrong();
      }
    });

    Future.delayed(const Duration(milliseconds: 1500), _nextQuestion);
  }

  void _nextQuestion() {
    if (!mounted) return;
    if (_currentIdx >= _questions.length - 1) {
      _endGame();
      return;
    }
    setState(() {
      _currentIdx++;
      _selectedAnswer = null;
      _showResult = false;
    });
    _startQuestionTimer();
  }

  Future<void> _endGame() async {
    _timer?.cancel();
    final user = context.read<UserProvider>().user;
    if (user == null) return;

    final result = await context.read<GameProvider>().finishGame(
      userId: user.uid,
      userName: user.displayName,
      gameType: AppConstants.gameQuiz,
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
    _tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: LoadingWidget(message: 'Đang chuẩn bị câu hỏi...'),
      );
    }

    final question = _questions[_currentIdx];
    final options = _options[_currentIdx];

    return Scaffold(
      backgroundColor: AppColors.background,
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
                    _buildQuestionCard(question),
                    const SizedBox(height: 24),
                    ..._buildOptions(options, question),
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
      padding: const EdgeInsets.all(AppSizes.padding),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
          Expanded(
            child: Center(
              child: Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: _timeLeftForQuestion <= 5 ? Colors.red : Colors.blue,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(LucideIcons.timer,
                        color: Colors.white, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '${_timeLeftForQuestion}s',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(LucideIcons.trophy,
                    color: Colors.orange, size: 16),
                const SizedBox(width: 4),
                Text(
                  '$_score',
                  style: const TextStyle(
                    color: Colors.orange,
                    fontWeight: FontWeight.w700,
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Câu ${_currentIdx + 1} / ${_questions.length}',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                '${((_currentIdx + 1) / _questions.length * 100).toInt()}%',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearPercentIndicator(
            lineHeight: 8,
            percent: (_currentIdx + 1) / _questions.length,
            backgroundColor: Colors.grey.shade200,
            linearGradient: const LinearGradient(
                colors: AppColors.gradientPurple),
            barRadius: const Radius.circular(8),
            padding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(VocabModel q) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: AppColors.gradientPurple,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Nghĩa của từ này là gì?',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          if (q.isEmoji)
            Text(q.image, style: const TextStyle(fontSize: 56))
          else
            const Icon(FontAwesomeIcons.book,
                color: Colors.white, size: 56),
          const SizedBox(height: 12),
          Text(
            q.word,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (q.pronunciation.isNotEmpty)
            Text(
              q.pronunciation,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 16,
                fontStyle: FontStyle.italic,
              ),
            ),
          const SizedBox(height: 12),
          InkWell(
            onTap: _speak,
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(FontAwesomeIcons.volumeHigh,
                      color: Colors.white, size: 16),
                  SizedBox(width: 6),
                  Text(
                    'Phát âm',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    )
        .animate(key: ValueKey(_currentIdx))
        .fadeIn(duration: 400.ms)
        .slideY(begin: 0.1, end: 0);
  }

  List<Widget> _buildOptions(List<VocabModel> opts, VocabModel correct) {
    return List.generate(opts.length, (i) {
      final opt = opts[i];
      final isCorrect = opt.id == correct.id;
      final isSelected = _selectedAnswer?.id == opt.id;

      Color? bgColor;
      Color? borderColor;
      IconData? icon;

      if (_showResult) {
        if (isCorrect) {
          bgColor = Colors.green.shade50;
          borderColor = Colors.green;
          icon = Icons.check_circle;
        } else if (isSelected) {
          bgColor = Colors.red.shade50;
          borderColor = Colors.red;
          icon = Icons.cancel;
        }
      }

      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: InkWell(
          onTap: () => _selectAnswer(opt),
          borderRadius: BorderRadius.circular(AppSizes.radius),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: bgColor ?? Colors.white,
              borderRadius: BorderRadius.circular(AppSizes.radius),
              border: Border.all(
                color: borderColor ?? Colors.grey.shade200,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 4,
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      String.fromCharCode(65 + i), // A, B, C, D
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    opt.meaning,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                if (icon != null)
                  Icon(icon, color: borderColor, size: 22),
              ],
            ),
          ),
        ),
      )
          .animate(delay: (i * 80).ms, key: ValueKey('$_currentIdx-$i'))
          .fadeIn(duration: 300.ms)
          .slideX(begin: 0.1, end: 0);
    });
  }
}