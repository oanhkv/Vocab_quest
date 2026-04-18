import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../config/constants.dart';
import '../models/game_result_model.dart';
import '../models/user_model.dart';

/// 🔥 Service xử lý Firestore
class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ============ USER ============

  /// Lấy thông tin user
  Future<UserModel?> getUser(String uid) async {
    try {
      final doc =
      await _db.collection(AppConstants.usersCollection).doc(uid).get();
      if (doc.exists) return UserModel.fromFirestore(doc);
      return null;
    } catch (e) {
      debugPrint('Error getUser: $e');
      return null;
    }
  }

  /// Stream user (realtime)
  Stream<UserModel?> streamUser(String uid) {
    return _db
        .collection(AppConstants.usersCollection)
        .doc(uid)
        .snapshots()
        .map((doc) => doc.exists ? UserModel.fromFirestore(doc) : null);
  }

  /// Cập nhật user
  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    await _db.collection(AppConstants.usersCollection).doc(uid).update(data);
  }

  /// Cập nhật thông tin hiển thị
  Future<void> updateDisplayName(String uid, String displayName) async {
    await updateUser(uid, {'displayName': displayName});
  }

  // ============ GAME RESULT ============

  /// Lưu kết quả game
  Future<void> saveGameResult(GameResultModel result) async {
    // Lưu vào collection game_results
    await _db
        .collection(AppConstants.gameResultsCollection)
        .add(result.toMap());

    // Cập nhật tổng điểm, coin, XP của user
    await _db
        .collection(AppConstants.usersCollection)
        .doc(result.userId)
        .update({
      'totalScore': FieldValue.increment(result.score),
      'totalCoins': FieldValue.increment(result.coinsEarned),
      'totalXP': FieldValue.increment(result.xpEarned),
      'lastPlayedDate': Timestamp.fromDate(DateTime.now()),
    });
  }

  /// Lấy lịch sử chơi của user (stream)
  Stream<List<GameResultModel>> streamUserHistory(String userId) {
    return _db
        .collection(AppConstants.gameResultsCollection)
        .where('userId', isEqualTo: userId)
        .orderBy('playedAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snap) =>
        snap.docs.map((d) => GameResultModel.fromFirestore(d)).toList());
  }

  /// Lấy lịch sử (future - một lần)
  Future<List<GameResultModel>> getUserHistory(String userId) async {
    final snap = await _db
        .collection(AppConstants.gameResultsCollection)
        .where('userId', isEqualTo: userId)
        .orderBy('playedAt', descending: true)
        .limit(50)
        .get();

    return snap.docs.map((d) => GameResultModel.fromFirestore(d)).toList();
  }

  // ============ LEADERBOARD ============

  /// Bảng xếp hạng Top 100 theo tổng điểm
  Stream<List<UserModel>> streamLeaderboard({int limit = 100}) {
    return _db
        .collection(AppConstants.usersCollection)
        .orderBy('totalScore', descending: true)
        .limit(limit)
        .snapshots()
        .map((snap) =>
        snap.docs.map((d) => UserModel.fromFirestore(d)).toList());
  }

  /// Bảng xếp hạng theo XP
  Stream<List<UserModel>> streamLeaderboardByXP({int limit = 100}) {
    return _db
        .collection(AppConstants.usersCollection)
        .orderBy('totalXP', descending: true)
        .limit(limit)
        .snapshots()
        .map((snap) =>
        snap.docs.map((d) => UserModel.fromFirestore(d)).toList());
  }

  // ============ STATISTICS ============

  /// Thống kê tổng số lần chơi theo game type
  Future<Map<String, int>> getGameStats(String userId) async {
    final snap = await _db
        .collection(AppConstants.gameResultsCollection)
        .where('userId', isEqualTo: userId)
        .get();

    final stats = <String, int>{
      'matching': 0,
      'quiz': 0,
      'word_puzzle': 0,
      'total': 0,
    };

    for (final doc in snap.docs) {
      final type = doc.data()['gameType'] as String? ?? '';
      if (stats.containsKey(type)) {
        stats[type] = stats[type]! + 1;
      }
      stats['total'] = stats['total']! + 1;
    }

    return stats;
  }
}