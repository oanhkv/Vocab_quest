import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

/// 🔔 Service xử lý thông báo nhắc nhở học tập hàng ngày.
///
/// Dùng `flutter_local_notifications` + `timezone` để schedule một
/// local notification lặp lại mỗi ngày vào đúng giờ user chọn.
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  /// ID cố định của reminder hàng ngày (để cancel/reschedule).
  static const int _dailyReminderId = 1001;

  static const String _channelId = 'daily_reminder';
  static const String _channelName = 'Nhắc nhở học tập';
  static const String _channelDescription =
      'Nhắc bạn học từ vựng VocabQuest mỗi ngày';

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;
  bool _requestingPermission = false;

  /// Khởi tạo plugin + timezone. Gọi một lần ở main().
  Future<void> init() async {
    if (_initialized) return;

    tzdata.initializeTimeZones();
    // App tập trung thị trường VN → mặc định múi giờ Hà Nội.
    // Nếu sau này muốn đa vùng, thay bằng package `flutter_timezone`.
    try {
      tz.setLocalLocation(tz.getLocation('Asia/Ho_Chi_Minh'));
    } catch (_) {
      // Nếu thiếu location (hiếm), fallback UTC để không crash.
      tz.setLocalLocation(tz.UTC);
    }

    const androidInit =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const initSettings =
        InitializationSettings(android: androidInit, iOS: iosInit);

    await _plugin.initialize(initSettings);

    // Tạo channel trước để user có thể quản lý trong Settings > Notifications.
    final androidImpl = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await androidImpl?.createNotificationChannel(
      const AndroidNotificationChannel(
        _channelId,
        _channelName,
        description: _channelDescription,
        importance: Importance.high,
      ),
    );

    _initialized = true;
  }

  /// Xin quyền gửi thông báo. Gọi khi user bật switch trong Settings.
  /// Trả về true nếu được cấp quyền (hoặc platform không yêu cầu).
  Future<bool> requestPermissions() async {
    await init();

    // Chống double-call (user bật switch 2 lần liên tiếp khi dialog còn hiện).
    if (_requestingPermission) return false;
    _requestingPermission = true;

    try {
      final androidImpl = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      if (androidImpl != null) {
        // Android 13+ (API 33) cần POST_NOTIFICATIONS runtime permission.
        bool notifGranted = true;
        try {
          notifGranted =
              await androidImpl.requestNotificationsPermission() ?? true;
        } catch (_) {
          // Nếu đang có dialog khác mở — coi như chưa được cấp.
          notifGranted = false;
        }
        // Android 12+ (API 31) cần user bật SCHEDULE_EXACT_ALARM trong Settings.
        // Chỉ mở khi đã có quyền notification — tránh permission conflict.
        if (notifGranted) {
          try {
            await androidImpl.requestExactAlarmsPermission();
          } catch (_) {
            // Một số OEM không có màn hình này, hoặc Android < 12.
          }
        }
        return notifGranted;
      }

      final iosImpl = _plugin.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();
      if (iosImpl != null) {
        final ok = await iosImpl.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        return ok ?? false;
      }

      return true;
    } finally {
      _requestingPermission = false;
    }
  }

  /// Schedule (hoặc reschedule) thông báo nhắc học tập hàng ngày.
  ///
  /// Nếu đã tồn tại schedule cũ, sẽ cancel trước rồi đặt mới.
  Future<void> scheduleDailyReminder({
    required int hour,
    required int minute,
    required String title,
    required String body,
  }) async {
    await init();
    await _plugin.cancel(_dailyReminderId);

    // Kiểm tra Android có đang cho app gửi thông báo không. Nếu không — báo
    // lỗi ra log (UI có thể bắt qua try/catch ở provider).
    final androidImpl = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (androidImpl != null) {
      final enabled =
          await androidImpl.areNotificationsEnabled() ?? false;
      if (!enabled) {
        debugPrint('🔕 [Notif] Notifications disabled in system settings');
        throw 'Quyền thông báo đã bị tắt trong Cài đặt hệ thống';
      }
    }

    final scheduled = _nextInstanceOf(hour, minute);
    debugPrint(
        '🔔 [Notif] Schedule daily @$hour:$minute → next=$scheduled (tz=${tz.local.name})');

    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );
    const iosDetails = DarwinNotificationDetails();
    const details =
        NotificationDetails(android: androidDetails, iOS: iosDetails);

    try {
      await _plugin.zonedSchedule(
        _dailyReminderId,
        title,
        body,
        scheduled,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time, // lặp hàng ngày
      );
      debugPrint('✅ [Notif] Scheduled exact');
    } on PlatformException catch (e) {
      debugPrint('⚠️ [Notif] PlatformException: ${e.code} — ${e.message}');
      // Nếu user chưa cấp SCHEDULE_EXACT_ALARM, fallback sang inexact.
      if (e.code == 'exact_alarms_not_permitted') {
        await _plugin.zonedSchedule(
          _dailyReminderId,
          title,
          body,
          scheduled,
          details,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: DateTimeComponents.time,
        );
        debugPrint('✅ [Notif] Scheduled inexact (fallback)');
      } else {
        rethrow;
      }
    }
  }

  /// Hủy thông báo nhắc học tập.
  Future<void> cancelDailyReminder() async {
    await init();
    await _plugin.cancel(_dailyReminderId);
  }

  /// Đã có schedule đang active hay chưa (để debug).
  Future<bool> hasPendingReminder() async {
    await init();
    final pending = await _plugin.pendingNotificationRequests();
    return pending.any((p) => p.id == _dailyReminderId);
  }

  tz.TZDateTime _nextInstanceOf(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    if (!scheduled.isAfter(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }
}
