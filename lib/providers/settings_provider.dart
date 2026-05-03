import 'package:flutter/material.dart';
import '../services/audio_service.dart';
import '../services/local_storage.dart';
import '../services/notification_service.dart';
import '../utils/app_localizations.dart';

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

  /// Load tất cả settings + đồng bộ schedule thông báo hiện tại.
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

    // Nếu user đã bật nhắc nhở từ phiên trước, đảm bảo schedule còn sống
    // (sau khi gỡ & cài lại app, hoặc sau reboot trên một số OEM).
    if (_notificationEnabled) {
      try {
        await _rescheduleReminder();
      } catch (e) {
        // Hệ thống đã revoke quyền thông báo — tự tắt flag để UI phản ánh đúng.
        debugPrint('[Settings] reschedule failed: $e → turning off flag');
        _notificationEnabled = false;
        await LocalStorage.setNotificationEnabled(false);
        notifyListeners();
      }
    }
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

  /// Bật/tắt thông báo. Trả về true nếu thao tác thành công
  /// (khi bật: đã có quyền; khi tắt: luôn true).
  Future<bool> toggleNotification(bool value) async {
    if (value) {
      bool granted = false;
      try {
        granted = await NotificationService.instance.requestPermissions();
      } catch (_) {
        granted = false;
      }
      if (!granted) {
        // Không bật được vì thiếu quyền — UI sẽ hiện snackbar hướng dẫn.
        return false;
      }
      _notificationEnabled = true;
      await LocalStorage.setNotificationEnabled(true);
      notifyListeners();
      try {
        await _rescheduleReminder();
      } catch (_) {
        // Schedule lỗi không làm rớt state — switch vẫn ON.
      }
      return true;
    } else {
      _notificationEnabled = false;
      await LocalStorage.setNotificationEnabled(false);
      notifyListeners();
      try {
        await NotificationService.instance.cancelDailyReminder();
      } catch (_) {}
      return true;
    }
  }

  Future<void> setLanguage(String value) async {
    _language = value;
    await LocalStorage.setLanguage(value);
    notifyListeners();
    // Ngôn ngữ thay đổi → reschedule để nội dung thông báo đúng tiếng.
    if (_notificationEnabled) {
      await _rescheduleReminder();
    }
  }

  Future<void> setReminderTime(TimeOfDay time) async {
    _reminderHour = time.hour;
    _reminderMinute = time.minute;
    await LocalStorage.setReminderHour(time.hour);
    await LocalStorage.setReminderMinute(time.minute);
    notifyListeners();
    if (_notificationEnabled) {
      await _rescheduleReminder();
    }
  }

  Future<void> setUserRating(int stars) async {
    _userRating = stars;
    await LocalStorage.setUserRating(stars);
    notifyListeners();
  }

  /// Đặt lại schedule theo state hiện tại (giờ + ngôn ngữ).
  Future<void> _rescheduleReminder() async {
    final title = AppLocalizations.tr(_language, 'notification_title');
    final body = AppLocalizations.tr(_language, 'notification_body');
    await NotificationService.instance.scheduleDailyReminder(
      hour: _reminderHour,
      minute: _reminderMinute,
      title: title,
      body: body,
    );
  }
}
