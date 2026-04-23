import 'package:cloud_firestore/cloud_firestore.dart';

/// 👤 Model người dùng
class UserModel {
  final String uid;
  final String email;
  final String displayName;
  final String avatarUrl;
  final int totalScore;
  final int totalCoins;
  final int totalXP;
  final int level;
  final int streak; // Số ngày liên tiếp đăng nhập
  final int hearts; // Số tim hiện tại (tối đa 5)
  final List<String> ownedPacks; // các gói từ vựng đã sở hữu
  final Map<String, int>
      progress; // key "gameType|packId" -> level cao nhất đã pass (0-3)
  final DateTime? lastPlayedDate;
  final DateTime createdAt;

  UserModel({
    required this.uid,
    required this.email,
    this.displayName = '',
    this.avatarUrl = '',
    this.totalScore = 0,
    this.totalCoins = 100, // Thưởng 100 coin khi đăng ký
    this.totalXP = 0,
    this.level = 1,
    this.streak = 0,
    this.hearts = 5,
    List<String>? ownedPacks,
    Map<String, int>? progress,
    this.lastPlayedDate,
    DateTime? createdAt,
  })  : ownedPacks =
            ownedPacks ?? const ['beginner', 'intermediate', 'advanced'],
        progress = progress ?? <String, int>{},
        createdAt = createdAt ?? DateTime.now();

  /// Chuyển từ Firestore DocumentSnapshot
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final raw = doc.data();
    final data =
        raw is Map ? Map<String, dynamic>.from(raw) : <String, dynamic>{};
    int asInt(dynamic v, int fallback) {
      if (v is int) return v;
      if (v is num) return v.toInt();
      if (v is String) return int.tryParse(v) ?? fallback;
      return fallback;
    }

    String asString(dynamic v) => v is String ? v : (v?.toString() ?? '');
    DateTime? asDate(dynamic v) {
      if (v is Timestamp) return v.toDate();
      if (v is DateTime) return v;
      return null;
    }

    final rawPacks = data['ownedPacks'];
    final packs = rawPacks is List
        ? rawPacks.map((e) => e.toString()).toList()
        : <String>['beginner', 'intermediate', 'advanced'];
    final rawProgress = data['progress'];
    final prog = <String, int>{};
    if (rawProgress is Map) {
      rawProgress.forEach((k, v) {
        prog[k.toString()] = asInt(v, 0);
      });
    }
    return UserModel(
      uid: doc.id,
      email: asString(data['email']),
      displayName: asString(data['displayName']),
      avatarUrl: asString(data['avatarUrl']),
      totalScore: asInt(data['totalScore'], 0),
      totalCoins: asInt(data['totalCoins'], 0),
      totalXP: asInt(data['totalXP'], 0),
      level: asInt(data['level'], 1),
      streak: asInt(data['streak'], 0),
      hearts: asInt(data['hearts'], 5),
      ownedPacks: packs,
      progress: prog,
      lastPlayedDate: asDate(data['lastPlayedDate']),
      createdAt: asDate(data['createdAt']) ?? DateTime.now(),
    );
  }

  /// Chuyển sang Map để lưu vào Firestore
  Map<String, dynamic> toMap() => {
        'email': email,
        'displayName': displayName,
        'avatarUrl': avatarUrl,
        'totalScore': totalScore,
        'totalCoins': totalCoins,
        'totalXP': totalXP,
        'level': level,
        'streak': streak,
        'hearts': hearts,
        'ownedPacks': ownedPacks,
        'progress': progress,
        'lastPlayedDate':
            lastPlayedDate != null ? Timestamp.fromDate(lastPlayedDate!) : null,
        'createdAt': Timestamp.fromDate(createdAt),
      };

  /// Copy với các giá trị mới
  UserModel copyWith({
    String? displayName,
    String? avatarUrl,
    int? totalScore,
    int? totalCoins,
    int? totalXP,
    int? level,
    int? streak,
    int? hearts,
    List<String>? ownedPacks,
    Map<String, int>? progress,
    DateTime? lastPlayedDate,
  }) {
    return UserModel(
      uid: uid,
      email: email,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      totalScore: totalScore ?? this.totalScore,
      totalCoins: totalCoins ?? this.totalCoins,
      totalXP: totalXP ?? this.totalXP,
      level: level ?? this.level,
      streak: streak ?? this.streak,
      hearts: hearts ?? this.hearts,
      ownedPacks: ownedPacks ?? this.ownedPacks,
      progress: progress ?? this.progress,
      lastPlayedDate: lastPlayedDate ?? this.lastPlayedDate,
      createdAt: createdAt,
    );
  }
}
