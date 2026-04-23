import 'package:flutter/material.dart';
import '../services/audio_service.dart';
import '../services/local_storage.dart';

/// ⚙️ Provider quản lý settings của app
class SettingsProvider extends ChangeNotifier {
  bool _isDarkMode = false;
  bool _soundEnabled = true;
  bool _musicEnabled = true;
  bool _notificationEnabled = true;
  String _language = 'vi';
  int _reminderHour = 20;
  int _reminderMinute = 0;
  int _userRating = 0;

  bool get isDarkMode => _isDarkMode;
  bool get soundEnabled => _soundEnabled;
  bool get musicEnabled => _musicEnabled;
  bool get notificationEnabled => _notificationEnabled;
  String get language => _language;
  int get reminderHour => _reminderHour;
  int get reminderMinute => _reminderMinute;
  int get userRating => _userRating;

  TimeOfDay get reminderTime =>
      TimeOfDay(hour: _reminderHour, minute: _reminderMinute);

  /// Load tất cả settings
  Future<void> loadSettings() async {
    _isDarkMode = await LocalStorage.getDarkMode();
    _soundEnabled = await LocalStorage.getSoundEnabled();
    _musicEnabled = await LocalStorage.getMusicEnabled();
    _notificationEnabled = await LocalStorage.getNotificationEnabled();
    _language = await LocalStorage.getLanguage();
    _reminderHour = await LocalStorage.getReminderHour();
    _reminderMinute = await LocalStorage.getReminderMinute();
    _userRating = await LocalStorage.getUserRating();
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
    await AudioService.instance.setSoundEnabled(value);
    if (value) AudioService.instance.playClick();
    notifyListeners();
  }

  Future<void> toggleMusic(bool value) async {
    _musicEnabled = value;
    await LocalStorage.setMusicEnabled(value);
    await AudioService.instance.setMusicEnabled(value);
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

  Future<void> setReminderTime(TimeOfDay time) async {
    _reminderHour = time.hour;
    _reminderMinute = time.minute;
    await LocalStorage.setReminderHour(time.hour);
    await LocalStorage.setReminderMinute(time.minute);
    notifyListeners();
  }

  Future<void> setUserRating(int stars) async {
    _userRating = stars;
    await LocalStorage.setUserRating(stars);
    notifyListeners();
  }
}
