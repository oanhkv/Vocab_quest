import 'package:flutter/material.dart';
import '../config/rewards.dart';
import '../models/level_reward_model.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';

/// 👤 Provider quản lý state của user
class UserProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();

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