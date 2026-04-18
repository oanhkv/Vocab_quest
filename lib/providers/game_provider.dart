import 'package:flutter/material.dart';
import '../models/game_result_model.dart';
import '../models/vocab_model.dart';
import '../services/firestore_service.dart';
import '../services/json_service.dart';

/// 🎮 Provider quản lý state game
class GameProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  List<VocabModel> _currentVocab = [];
  int _currentScore = 0;
  int _correctAnswers = 0;
  int _totalQuestions = 0;
  DateTime? _startTime;
  bool _isLoading = false;

  List<VocabModel> get currentVocab => _currentVocab;
  int get currentScore => _currentScore;
  int get correctAnswers => _correctAnswers;
  int get totalQuestions => _totalQuestions;
  bool get isLoading => _isLoading;

  /// Load từ vựng theo level
  Future<void> loadVocab(String level) async {
    _isLoading = true;
    notifyListeners();

    _currentVocab = await JsonService.loadVocab(level);

    _isLoading = false;
    notifyListeners();
  }

  /// Bắt đầu game
  void startGame() {
    _currentScore = 0;
    _correctAnswers = 0;
    _totalQuestions = 0;
    _startTime = DateTime.now();
  }

  /// Cộng điểm
  void addScore(int points) {
    _currentScore += points;
    notifyListeners();
  }

  /// Tăng đúng
  void addCorrect() {
    _correctAnswers++;
    _totalQuestions++;
    notifyListeners();
  }

  /// Tăng sai
  void addWrong() {
    _totalQuestions++;
    notifyListeners();
  }

  /// Lưu kết quả
  Future<GameResultModel> finishGame({
    required String userId,
    required String userName,
    required String gameType,
    required String level,
  }) async {
    final duration =
        DateTime.now().difference(_startTime ?? DateTime.now()).inSeconds;

    // Tính coin và XP thưởng
    final rewards = _calculateRewards(
      score: _currentScore,
      correct: _correctAnswers,
      total: _totalQuestions == 0 ? 1 : _totalQuestions,
      timeSeconds: duration,
      level: level,
    );

    final result = GameResultModel(
      userId: userId,
      userDisplayName: userName,
      gameType: gameType,
      level: level,
      score: _currentScore,
      correctAnswers: _correctAnswers,
      totalQuestions: _totalQuestions,
      timeTakenSeconds: duration,
      coinsEarned: rewards['coins']!,
      xpEarned: rewards['xp']!,
      playedAt: DateTime.now(),
    );

    // Lưu Firestore
    await _firestoreService.saveGameResult(result);

    return result;
  }

  /// Tính thưởng
  Map<String, int> _calculateRewards({
    required int score,
    required int correct,
    required int total,
    required int timeSeconds,
    required String level,
  }) {
    final accuracy = correct / total;
    int coins = (score * 0.5).round();
    int xp = score;

    // Bonus accuracy
    if (accuracy == 1.0) {
      coins += 50;
      xp += 30;
    } else if (accuracy >= 0.8) {
      coins += 20;
      xp += 15;
    }

    // Bonus tốc độ
    if (timeSeconds < 30) coins += 10;

    // Bonus theo level
    switch (level) {
      case 'intermediate':
        xp = (xp * 1.5).round();
        break;
      case 'advanced':
        xp = xp * 2;
        break;
    }

    return {'coins': coins, 'xp': xp};
  }

  /// Reset
  void reset() {
    _currentScore = 0;
    _correctAnswers = 0;
    _totalQuestions = 0;
    _startTime = null;
    notifyListeners();
  }
}