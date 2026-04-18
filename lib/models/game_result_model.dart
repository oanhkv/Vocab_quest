import 'package:cloud_firestore/cloud_firestore.dart';

/// 🎮 Model kết quả chơi game
class GameResultModel {
  final String id;
  final String userId;
  final String userDisplayName;
  final String gameType;           // matching / quiz / word_puzzle
  final String level;              // beginner / intermediate / advanced
  final int score;                 // Điểm số
  final int correctAnswers;        // Số câu đúng
  final int totalQuestions;        // Tổng số câu
  final int timeTakenSeconds;      // Thời gian chơi (giây)
  final int coinsEarned;           // Số coin nhận được
  final int xpEarned;              // Số XP nhận được
  final DateTime playedAt;

  GameResultModel({
    this.id = '',
    required this.userId,
    required this.userDisplayName,
    required this.gameType,
    required this.level,
    required this.score,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.timeTakenSeconds,
    required this.coinsEarned,
    required this.xpEarned,
    required this.playedAt,
  });

  /// Độ chính xác (%)
  double get accuracy =>
      totalQuestions == 0 ? 0 : (correctAnswers / totalQuestions) * 100;

  /// Rating 1-3 sao dựa trên accuracy
  int get stars {
    if (accuracy >= 90) return 3;
    if (accuracy >= 60) return 2;
    if (accuracy >= 30) return 1;
    return 0;
  }

  factory GameResultModel.fromFirestore(DocumentSnapshot doc) {
    final raw = doc.data();
    final data = raw is Map
        ? Map<String, dynamic>.from(raw as Map)
        : <String, dynamic>{};
    int asInt(dynamic v, int fallback) {
      if (v is int) return v;
      if (v is num) return v.toInt();
      if (v is String) return int.tryParse(v) ?? fallback;
      return fallback;
    }
    String asString(dynamic v, [String fallback = '']) =>
        v is String ? v : (v?.toString() ?? fallback);
    return GameResultModel(
      id: doc.id,
      userId: asString(data['userId']),
      userDisplayName: asString(data['userDisplayName']),
      gameType: asString(data['gameType']),
      level: asString(data['level'], 'beginner'),
      score: asInt(data['score'], 0),
      correctAnswers: asInt(data['correctAnswers'], 0),
      totalQuestions: asInt(data['totalQuestions'], 0),
      timeTakenSeconds: asInt(data['timeTakenSeconds'], 0),
      coinsEarned: asInt(data['coinsEarned'], 0),
      xpEarned: asInt(data['xpEarned'], 0),
      playedAt: data['playedAt'] is Timestamp
          ? (data['playedAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
    'userId': userId,
    'userDisplayName': userDisplayName,
    'gameType': gameType,
    'level': level,
    'score': score,
    'correctAnswers': correctAnswers,
    'totalQuestions': totalQuestions,
    'timeTakenSeconds': timeTakenSeconds,
    'coinsEarned': coinsEarned,
    'xpEarned': xpEarned,
    'playedAt': Timestamp.fromDate(playedAt),
  };

  String get gameTypeDisplay {
    switch (gameType) {
      case 'matching':
        return 'Nối từ';
      case 'quiz':
        return 'Trắc nghiệm';
      case 'word_puzzle':
        return 'Xếp chữ';
      default:
        return gameType;
    }
  }

  String get levelDisplay {
    switch (level) {
      case 'beginner':
        return 'Sơ cấp';
      case 'intermediate':
        return 'Trung cấp';
      case 'advanced':
        return 'Nâng cao';
      default:
        return level;
    }
  }
}