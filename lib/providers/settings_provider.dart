import 'package:flutter/material.dart';
import '../services/local_storage.dart';

/// ⚙️ Provider quản lý settings của app
class SettingsProvider extends ChangeNotifier {
  bool _isDarkMode = false;
  bool _soundEnabled = true;
  bool _musicEnabled = true;
  bool _notificationEnabled = true;
  String _language = 'vi';

  bool get isDarkMode => _isDarkMode;
  bool get soundEnabled => _soundEnabled;
  bool get musicEnabled => _musicEnabled;
  bool get notificationEnabled => _notificationEnabled;
  String get language => _language;

  /// Load tất cả settings
  Future<void> loadSettings() async {
    _isDarkMode = await LocalStorage.getDarkMode();
    _soundEnabled = await LocalStorage.getSoundEnabled();
    _musicEnabled = await LocalStorage.getMusicEnabled();
    _notificationEnabled = await LocalStorage.getNotificationEnabled();
    _language = await LocalStorage.getLanguage();
    notifyListeners();
  }

  Future<void> toggleDarkMode(bool value) async {
    _isDarkMode = value;
    await LocalStorage.setDarkMode(value);
    notifyListeners();
  }

  Future<void> toggleSound(bool value) async {
    _soundEnabled = value;
    await LocalStorage.setSoundEnabled(value);
    notifyListeners();
  }

  Future<void> toggleMusic(bool value) async {
    _musicEnabled = value;
    await LocalStorage.setMusicEnabled(value);
    notifyListeners();
  }

  Future<void> toggleNotification(bool value) async {
    _notificationEnabled = value;
    await LocalStorage.setNotificationEnabled(value);
    notifyListeners();
  }

  Future<void> setLanguage(String value) async {
    _language = value;
    await LocalStorage.setLanguage(value);
    notifyListeners();
  }
}