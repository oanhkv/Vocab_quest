import 'package:shared_preferences/shared_preferences.dart';
import '../config/constants.dart';

/// 💾 Service lưu trữ cục bộ với SharedPreferences
class LocalStorage {
  static SharedPreferences? _prefs;

  static Future<SharedPreferences> get _instance async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  // Dark mode
  static Future<bool> getDarkMode() async {
    final prefs = await _instance;
    return prefs.getBool(AppConstants.keyIsDarkMode) ?? false;
  }

  static Future<void> setDarkMode(bool value) async {
    final prefs = await _instance;
    await prefs.setBool(AppConstants.keyIsDarkMode, value);
  }

  // Sound
  static Future<bool> getSoundEnabled() async {
    final prefs = await _instance;
    return prefs.getBool(AppConstants.keySoundEnabled) ?? true;
  }

  static Future<void> setSoundEnabled(bool value) async {
    final prefs = await _instance;
    await prefs.setBool(AppConstants.keySoundEnabled, value);
  }

  // Music
  static Future<bool> getMusicEnabled() async {
    final prefs = await _instance;
    return prefs.getBool(AppConstants.keyMusicEnabled) ?? true;
  }

  static Future<void> setMusicEnabled(bool value) async {
    final prefs = await _instance;
    await prefs.setBool(AppConstants.keyMusicEnabled, value);
  }

  // Language
  static Future<String> getLanguage() async {
    final prefs = await _instance;
    return prefs.getString(AppConstants.keyLanguage) ?? 'vi';
  }

  static Future<void> setLanguage(String value) async {
    final prefs = await _instance;
    await prefs.setString(AppConstants.keyLanguage, value);
  }

  // Notification
  static Future<bool> getNotificationEnabled() async {
    final prefs = await _instance;
    return prefs.getBool(AppConstants.keyNotificationEnabled) ?? true;
  }

  static Future<void> setNotificationEnabled(bool value) async {
    final prefs = await _instance;
    await prefs.setBool(AppConstants.keyNotificationEnabled, value);
  }

  // Reminder time (daily learning reminder)
  static Future<int> getReminderHour() async {
    final prefs = await _instance;
    return prefs.getInt(AppConstants.keyReminderHour) ?? 20;
  }

  static Future<void> setReminderHour(int value) async {
    final prefs = await _instance;
    await prefs.setInt(AppConstants.keyReminderHour, value);
  }

  static Future<int> getReminderMinute() async {
    final prefs = await _instance;
    return prefs.getInt(AppConstants.keyReminderMinute) ?? 0;
  }

  static Future<void> setReminderMinute(int value) async {
    final prefs = await _instance;
    await prefs.setInt(AppConstants.keyReminderMinute, value);
  }

  // User rating (0 = chưa đánh giá)
  static Future<int> getUserRating() async {
    final prefs = await _instance;
    return prefs.getInt(AppConstants.keyUserRating) ?? 0;
  }

  static Future<void> setUserRating(int value) async {
    final prefs = await _instance;
    await prefs.setInt(AppConstants.keyUserRating, value);
  }

  // Favorite games (list gameType IDs)
  static Future<List<String>> getFavoriteGames() async {
    final prefs = await _instance;
    return prefs.getStringList(AppConstants.keyFavoriteGames) ?? [];
  }

  static Future<void> setFavoriteGames(List<String> ids) async {
    final prefs = await _instance;
    await prefs.setStringList(AppConstants.keyFavoriteGames, ids);
  }

  // First time
  static Future<bool> getIsFirstTime() async {
    final prefs = await _instance;
    return prefs.getBool(AppConstants.keyIsFirstTime) ?? true;
  }

  static Future<void> setIsFirstTime(bool value) async {
    final prefs = await _instance;
    await prefs.setBool(AppConstants.keyIsFirstTime, value);
  }

  // Xóa tất cả
  static Future<void> clearAll() async {
    final prefs = await _instance;
    await prefs.clear();
  }
}