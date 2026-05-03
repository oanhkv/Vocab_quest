import 'package:flutter/material.dart';
import '../services/local_storage.dart';

/// ❤️ Provider quản lý danh sách game yêu thích (đã lưu).
///
/// Lưu tại SharedPreferences — offline, không đụng Firestore.
class FavoritesProvider extends ChangeNotifier {
  Set<String> _ids = {};
  bool _loaded = false;

  Set<String> get ids => _ids;
  List<String> get idList => _ids.toList();
  int get count => _ids.length;
  bool get isLoaded => _loaded;

  Future<void> load() async {
    final list = await LocalStorage.getFavoriteGames();
    _ids = list.toSet();
    _loaded = true;
    notifyListeners();
  }

  bool isFavorite(String gameId) => _ids.contains(gameId);

  /// Toggle. Trả về true nếu sau khi toggle là favorite (đã thêm).
  Future<bool> toggle(String gameId) async {
    final wasFav = _ids.contains(gameId);
    if (wasFav) {
      _ids.remove(gameId);
    } else {
      _ids.add(gameId);
    }
    await LocalStorage.setFavoriteGames(_ids.toList());
    notifyListeners();
    return !wasFav;
  }
}
