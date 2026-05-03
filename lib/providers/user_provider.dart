import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import '../config/rewards.dart';
import '../models/level_reward_model.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../utils/streak_calculator.dart';

/// 👤 Provider quản lý state của user
class UserProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();

  /// Trần dung lượng avatar sau khi base64-encode (Firestore doc ≤ 1MB).
  /// Giới hạn 500KB để chừa chỗ cho các field khác của user.
  static const int _maxAvatarBytes = 500 * 1024;

  UserModel? _user;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _user != null;
  String? get errorMessage => _errorMessage;

  /// Khởi tạo - load user hiện tại nếu đã đăng nhập
  Future<void> init() async {
    final current = _authService.currentUser;
    if (current != null) {
      _user = await _firestoreService.getUser(current.uid);
      notifyListeners();
    }
  }

  /// Đăng ký
  Future<bool> register({
    required String email,
    required String password,
    required String displayName,
  }) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      _user = await _authService.register(
        email: email,
        password: password,
        displayName: displayName,
      );
      _setLoading(false);
      return _user != null;
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      return false;
    }
  }

  /// Đăng nhập
  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      _user = await _authService.login(email: email, password: password);
      _setLoading(false);
      return _user != null;
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      return false;
    }
  }

  /// Đăng xuất
  Future<void> logout() async {
    await _authService.logout();
    _user = null;
    notifyListeners();
  }

  /// Reset password
  Future<bool> resetPassword(String email) async {
    try {
      await _authService.resetPassword(email);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Refresh user từ Firestore
  Future<void> refreshUser() async {
    if (_user == null) return;
    _user = await _firestoreService.getUser(_user!.uid);
    notifyListeners();
  }

  /// Cập nhật hiển thị
  Future<void> updateDisplayName(String name) async {
    if (_user == null) return;
    await _firestoreService.updateDisplayName(_user!.uid, name);
    _user = _user!.copyWith(displayName: name);
    notifyListeners();
  }

  /// Lưu avatar dạng base64 data URI vào Firestore.
  /// Tránh phụ thuộc Firebase Storage (cần Blaze plan từ 10/2024).
  ///
  /// File avatar đã được image_picker resize về 400×400 JPEG quality 75
  /// → thường ~25-50KB raw, ~35-70KB sau base64 encoding.
  Future<String> updateAvatar(File file) async {
    if (_user == null) throw 'Chưa đăng nhập';

    final bytes = await file.readAsBytes();
    if (bytes.length > _maxAvatarBytes) {
      throw 'Ảnh quá lớn (${(bytes.length / 1024).round()}KB). '
          'Chọn ảnh khác hoặc giảm độ phân giải.';
    }

    final dataUri = 'data:image/jpeg;base64,${base64Encode(bytes)}';
    await _firestoreService.updateAvatarUrl(_user!.uid, dataUri);
    _user = _user!.copyWith(avatarUrl: dataUri);
    notifyListeners();
    return dataUri;
  }

  /// Cập nhật user local (sau khi chơi xong game)
  void updateLocalUser({
    int? addScore,
    int? addCoins,
    int? addXP,
  }) {
    if (_user == null) return;
    _user = _user!.copyWith(
      totalScore: _user!.totalScore + (addScore ?? 0),
      totalCoins: _user!.totalCoins + (addCoins ?? 0),
      totalXP: _user!.totalXP + (addXP ?? 0),
    );
    notifyListeners();
  }

  /// Cập nhật streak local từ outcome trả về sau `finishGame`.
  /// Gọi cùng với `updateLocalUser` để UI thấy streak mới ngay.
  void applyStreakOutcome(StreakOutcome outcome) {
    if (_user == null) return;
    _user = _user!.copyWith(
      streak: outcome.newStreak,
      longestStreak: outcome.newLongest,
      lastPlayedDate: DateTime.now(),
    );
    notifyListeners();
  }

  /// Key tiến độ dùng chung: "gameType|packId"
  static String progressKey(String gameType, String packId) =>
      '$gameType|$packId';

  /// Đọc level cao nhất đã pass trong (gameType, packId). 0 nếu chưa chơi.
  int getProgress(String gameType, String packId) {
    if (_user == null) return 0;
    return _user!.progress[progressKey(gameType, packId)] ?? 0;
  }

  /// Ghi nhận pass 1 level — chỉ update nếu level mới cao hơn.
  /// Trả về LevelReward nếu đây là lần đầu pass level này (có thưởng), null nếu không.
  Future<LevelReward?> recordLevelComplete({
    required String gameType,
    required String packId,
    required int level,
  }) async {
    if (_user == null) return null;
    final key = progressKey(gameType, packId);
    final current = _user!.progress[key] ?? 0;
    if (level <= current) return null;

    final reward = LevelRewardConfig.forLevel(level);

    // Update local user ngay — UI hiển thị mượt
    final newMap = Map<String, int>.from(_user!.progress);
    newMap[key] = level;
    _user = _user!.copyWith(
      progress: newMap,
      totalCoins: _user!.totalCoins + reward.coins,
      totalXP: _user!.totalXP + reward.xp,
    );
    notifyListeners();

    try {
      await _firestoreService.updateLevelProgress(
        uid: _user!.uid,
        key: key,
        level: level,
        coinReward: reward.coins,
        xpReward: reward.xp,
      );
    } catch (_) {
      // lỗi mạng — giữ state local, sẽ đồng bộ lần refresh kế
    }

    return reward;
  }

  /// Mua gói từ vựng — trả về null nếu thành công, lỗi nếu thất bại
  Future<String?> purchasePack({
    required String packId,
    required int price,
  }) async {
    if (_user == null) return 'Vui lòng đăng nhập';
    try {
      final updated = await _firestoreService.purchasePack(
        uid: _user!.uid,
        packId: packId,
        price: price,
      );
      _user = updated;
      notifyListeners();
      return null;
    } catch (e) {
      final msg = e.toString().replaceFirst('Exception: ', '');
      return msg;
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}