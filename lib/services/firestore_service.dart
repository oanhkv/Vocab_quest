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

  /// Cập nhật tiến độ level + thưởng (chỉ ghi nếu level mới cao hơn hiện tại).
  /// Key dạng "gameType|packId". Trả về true nếu thực sự đã ghi (lần đầu pass).
  Future<bool> updateLevelProgress({
    required String uid,
    required String key,
    required int level,
    int coinReward = 0,
    int xpReward = 0,
  }) async {
    final docRef = _db.collection(AppConstants.usersCollection).doc(uid);
    return _db.runTransaction<bool>((txn) async {
      final snap = await txn.get(docRef);
      if (!snap.exists) return false;
      final dynamic data = snap.data();
      final dynamic raw = (data is Map) ? data['progress'] : null;
      int current = 0;
      if (raw is Map) {
        final dynamic v = raw[key];
        if (v is num) current = v.toInt();
      }
      if (level <= current) return false;
      final Map<String, dynamic> update = {'progress.$key': level};
      if (coinReward > 0) {
        update['totalCoins'] = FieldValue.increment(coinReward);
      }
      if (xpReward > 0) {
        update['totalXP'] = FieldValue.increment(xpReward);
      }
      txn.update(docRef, update);
      return true;
    });
  }

  /// Mua gói từ vựng - giao dịch nguyên tử (trừ coin + append ownedPacks)
  /// Ném exception nếu không đủ coin hoặc đã sở hữu gói.
  Future<UserModel> purchasePack({
    required String uid,
    required String packId,
    required int price,
  }) async {
    final docRef = _db.collection(AppConstants.usersCollection).doc(uid);
    return _db.runTransaction<UserModel>((txn) async {
      final snap = await txn.get(docRef);
      if (!snap.exists) {
        throw Exception('Không tìm thấy user');
      }
      final data = Map<String, dynamic>.from(snap.data() as Map);
      final int coins = (data['totalCoins'] as num?)?.toInt() ?? 0;
      final List<String> owned =
          (data['ownedPacks'] as List?)?.map((e) => e.toString()).toList() ??
              [];

      if (owned.contains(packId)) {
        throw Exception('Bạn đã sở hữu gói này');
      }
      if (coins < price) {
        throw Exception('Không đủ coin (cần $price, có $coins)');
      }

      final newCoins = coins - price;
      final newOwned = [...owned, packId];
      txn.update(docRef, {
        'totalCoins': newCoins,
        'ownedPacks': newOwned,
      });

      data['totalCoins'] = newCoins;
      data['ownedPacks'] = newOwned;
      return UserModel.fromFirestore(snap);
    }).then((_) async {
      final fresh = await getUser(uid);
      if (fresh == null) throw Exception('Không load lại được user');
      return fresh;
    });
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
  /// Chỉ filter server-side theo userId (không cần composite index) rồi sắp
  /// xếp & giới hạn ở client.
  Stream<List<GameResultModel>> streamUserHistory(String userId) {
    return _db
        .collection(AppConstants.gameResultsCollection)
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snap) {
      final list =
          snap.docs.map((d) => GameResultModel.fromFirestore(d)).toList();
      list.sort((a, b) => b.playedAt.compareTo(a.playedAt));
      if (list.length > 50) return list.sublist(0, 50);
      return list;
    });
  }

  /// Lấy lịch sử (future - một lần)
  Future<List<GameResultModel>> getUserHistory(String userId) async {
    final snap = await _db
        .collection(AppConstants.gameResultsCollection)
        .where('userId', isEqualTo: userId)
        .get();

    final list =
        snap.docs.map((d) => GameResultModel.fromFirestore(d)).toList();
    list.sort((a, b) => b.playedAt.compareTo(a.playedAt));
    if (list.length > 50) return list.sublist(0, 50);
    return list;
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

  /// Lay hang cua user theo tong diem (1-based). Null neu khong ton tai user.
  Future<int?> getUserRankByScore(String uid) async {
    final userDoc =
        await _db.collection(AppConstants.usersCollection).doc(uid).get();
    if (!userDoc.exists) return null;
    final userScore =
        ((userDoc.data() ?? const <String, dynamic>{})['totalScore'] as num?)
                ?.toInt() ??
            0;

    final higher = await _db
        .collection(AppConstants.usersCollection)
        .where('totalScore', isGreaterThan: userScore)
        .count()
        .get();
    final higherCount = higher.count ?? 0;
    return higherCount + 1;
  }

  /// Lay hang cua user theo tong XP (1-based). Null neu khong ton tai user.
  Future<int?> getUserRankByXP(String uid) async {
    final userDoc =
        await _db.collection(AppConstants.usersCollection).doc(uid).get();
    if (!userDoc.exists) return null;
    final userXP =
        ((userDoc.data() ?? const <String, dynamic>{})['totalXP'] as num?)
                ?.toInt() ??
            0;

    final higher = await _db
        .collection(AppConstants.usersCollection)
        .where('totalXP', isGreaterThan: userXP)
        .count()
        .get();
    final higherCount = higher.count ?? 0;
    return higherCount + 1;
  }

  /// Nap 10 du lieu mau leaderboard de demo (merge = true, khong ghi de email).
  Future<void> seedLeaderboardDemoUsers() async {
    final now = DateTime.now();
    final sampleUsers = <Map<String, dynamic>>[
      {
        'uid': 'demo_u001',
        'displayName': 'Alice',
        'totalScore': 9800,
        'totalXP': 6200,
        'totalCoins': 540,
        'level': 8,
        'streak': 12,
        'hearts': 5
      },
      {
        'uid': 'demo_u002',
        'displayName': 'Bob',
        'totalScore': 9200,
        'totalXP': 5900,
        'totalCoins': 430,
        'level': 8,
        'streak': 8,
        'hearts': 5
      },
      {
        'uid': 'demo_u003',
        'displayName': 'Charlie',
        'totalScore': 8700,
        'totalXP': 5600,
        'totalCoins': 390,
        'level': 7,
        'streak': 5,
        'hearts': 4
      },
      {
        'uid': 'demo_u004',
        'displayName': 'Daisy',
        'totalScore': 8100,
        'totalXP': 5200,
        'totalCoins': 300,
        'level': 7,
        'streak': 4,
        'hearts': 5
      },
      {
        'uid': 'demo_u005',
        'displayName': 'Eric',
        'totalScore': 7600,
        'totalXP': 4800,
        'totalCoins': 280,
        'level': 6,
        'streak': 9,
        'hearts': 5
      },
      {
        'uid': 'demo_u006',
        'displayName': 'Fiona',
        'totalScore': 6900,
        'totalXP': 4300,
        'totalCoins': 260,
        'level': 6,
        'streak': 2,
        'hearts': 3
      },
      {
        'uid': 'demo_u007',
        'displayName': 'George',
        'totalScore': 6300,
        'totalXP': 3900,
        'totalCoins': 220,
        'level': 5,
        'streak': 3,
        'hearts': 5
      },
      {
        'uid': 'demo_u008',
        'displayName': 'Hana',
        'totalScore': 5900,
        'totalXP': 3600,
        'totalCoins': 200,
        'level': 5,
        'streak': 1,
        'hearts': 4
      },
      {
        'uid': 'demo_u009',
        'displayName': 'Ivan',
        'totalScore': 5300,
        'totalXP': 3200,
        'totalCoins': 180,
        'level': 4,
        'streak': 6,
        'hearts': 5
      },
      {
        'uid': 'demo_u010',
        'displayName': 'Julia',
        'totalScore': 4700,
        'totalXP': 2800,
        'totalCoins': 150,
        'level': 4,
        'streak': 2,
        'hearts': 5
      },
    ];

    final batch = _db.batch();
    for (final u in sampleUsers) {
      final ref =
          _db.collection(AppConstants.usersCollection).doc(u['uid'] as String);
      batch.set(
          ref,
          {
            'email': '${u['uid']}@example.com',
            'displayName': u['displayName'],
            'avatarUrl': '',
            'totalScore': u['totalScore'],
            'totalCoins': u['totalCoins'],
            'totalXP': u['totalXP'],
            'level': u['level'],
            'streak': u['streak'],
            'hearts': u['hearts'],
            'ownedPacks': const ['beginner', 'intermediate', 'advanced'],
            'progress': {'quiz|beginner': 3, 'matching|beginner': 3},
            'lastPlayedDate': Timestamp.fromDate(now),
            'createdAt': Timestamp.fromDate(now),
          },
          SetOptions(merge: true));
    }
    await batch.commit();
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
