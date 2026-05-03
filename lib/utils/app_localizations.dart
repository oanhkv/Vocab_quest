import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';

/// 🌐 Bản dịch gọn cho app (vi / en)
class AppLocalizations {
  static const Map<String, Map<String, String>> _strings = {
    'vi': {
      // Settings screen
      'settings_title': 'Cài đặt',
      'section_appearance': 'Giao diện',
      'section_sound': 'Âm thanh',
      'section_notification': 'Thông báo',
      'section_language': 'Ngôn ngữ',
      'section_info': 'Thông tin',
      'dark_mode': 'Chế độ tối',
      'dark_mode_sub': 'Giao diện thân thiện với mắt',
      'sound_effect': 'Hiệu ứng âm thanh',
      'sound_effect_sub': 'Âm thanh khi chơi game',
      'bg_music': 'Nhạc nền',
      'bg_music_sub': 'Phát nhạc khi mở app',
      'notification_reminder': 'Nhắc nhở học tập',
      'notification_reminder_sub': 'Nhắc bạn học mỗi ngày',
      'reminder_time': 'Giờ nhắc hàng ngày',
      'reminder_time_sub': 'Nhấn để đổi giờ nhắc',
      'notification_title': '📚 Đến giờ học từ vựng!',
      'notification_body':
          'Dành 5 phút ôn từ mới nào, VocabQuest đang chờ bạn 🚀',
      'notification_permission_denied':
          'Chưa cấp quyền thông báo. Vui lòng bật trong Cài đặt hệ thống.',
      'notification_scheduled': 'Đã đặt nhắc nhở lúc %s hàng ngày ✅',
      'notification_cancelled': 'Đã tắt nhắc nhở học tập',
      'language_label': 'Ngôn ngữ giao diện',
      'about_app': 'Về ứng dụng',
      'about_app_sub': 'Phiên bản',
      'rate_app': 'Đánh giá ứng dụng',
      'rate_app_sub': 'Cho chúng tôi 5 sao nhé!',
      'rate_app_thanks': 'Cảm ơn bạn đã đánh giá %d sao! ⭐',
      'rate_app_dialog_title': 'Đánh giá VocabQuest',
      'rate_app_dialog_sub': 'Bạn thấy ứng dụng thế nào?',
      'share_app': 'Chia sẻ ứng dụng',
      'share_app_sub': 'Giới thiệu cho bạn bè',
      'share_copied': 'Đã sao chép liên kết chia sẻ! 📋',
      'share_text':
          '📚 Học từ vựng cùng VocabQuest!\nTải ứng dụng tại: https://vocabquest.app',
      'logout': 'Đăng xuất',
      'logout_confirm': 'Bạn có chắc muốn đăng xuất không?',
      'cancel': 'Hủy',
      'close': 'Đóng',
      'save': 'Lưu',
      'choose_language': 'Chọn ngôn ngữ',
      'footer': 'Made with ❤️ by VocabQuest Team',

      // Home screen
      'home_hello': 'Xin chào 👋',
      'home_welcome_new': 'Học viên mới',
      'home_challenge_today': 'THỬ THÁCH HÔM NAY',
      'home_challenge_sub': 'Học %d XP\nđể giữ streak',
      'home_stat_score': 'Điểm',
      'home_stat_coin': 'Coin',
      'home_stat_xp': 'XP',
      'home_shortcut_profile': 'Hồ sơ',
      'home_shortcut_settings': 'Cài đặt',
      'home_shortcut_badges': 'Huy hiệu',
      'home_shortcut_saved': 'Đã lưu',
      'home_action_play': 'Chơi ngay',
      'home_action_play_sub': 'Chọn mini game',
      'home_action_ranking': 'Xếp hạng',
      'home_action_ranking_sub': 'Top người chơi',
      'home_action_history': 'Lịch sử',
      'home_action_history_sub': 'Kết quả đã chơi',
      'home_action_shop': 'Cửa hàng',
      'home_action_shop_sub': 'Gói từ vựng',
      'home_action_explore': 'Khám phá',

      // Profile screen
      'profile_title': 'Hồ sơ',
      'profile_please_login': 'Vui lòng đăng nhập',
      'profile_level_short': 'Lv',
      'profile_level_full': 'Cấp %d',
      'profile_stats_title': 'Thống kê game',
      'profile_stat_total': 'Tổng',
      'profile_stat_matching': 'Nối từ',
      'profile_stat_quiz': 'Quiz',
      'profile_stat_puzzle': 'Xếp chữ',
      'profile_streak': 'Streak',
      'profile_streak_record': 'Streak (kỷ lục %d)',
      'profile_menu_history': 'Lịch sử chơi',
      'profile_menu_leaderboard': 'Bảng xếp hạng',
      'profile_menu_settings': 'Cài đặt',
      'profile_menu_logout': 'Đăng xuất',
      'profile_updated': 'Đã cập nhật',
      'profile_logout_confirm_title': 'Đăng xuất?',

      // Game menu
      'gm_title': 'Mini Game',
      'gm_featured': '⭐ Gợi ý hôm nay',
      'gm_featured_sub': 'Luyện game được chơi nhiều nhất',
      'gm_all': '🎮 Tất cả mini game',
      'gm_all_sub': 'Chọn game để pick gói từ vựng',
      'gm_ready': 'Sẵn sàng luyện từ?',
      'gm_ready_sub': 'Chọn 1 mini-game bên dưới để bắt đầu 🚀',
      'gm_play_now': 'Chơi ngay',
      'gm_matching_desc': 'Ghép từ tiếng Anh với nghĩa tiếng Việt',
      'gm_quiz_desc': '4 đáp án cho mỗi câu hỏi — chọn đúng nhé!',
      'gm_puzzle_desc': 'Sắp xếp các chữ cái thành từ đúng',
      'gm_game_matching': 'Nối từ',
      'gm_game_quiz': 'Trắc nghiệm',
      'gm_game_puzzle': 'Xếp chữ',
      'gm_game_memory': 'Lật thẻ',
      'gm_memory_desc': 'Lật thẻ tìm cặp từ — rèn trí nhớ từ vựng',

      // Leaderboard
      'lb_title': 'Bảng xếp hạng',

      // Favorites / Saved
      'fav_added': 'Đã thêm vào yêu thích ❤️',
      'fav_removed': 'Đã bỏ khỏi yêu thích',
      'fav_title': 'Game đã lưu',
      'fav_empty_title': 'Chưa có game yêu thích',
      'fav_empty_sub':
          'Vào mục Mini Game, nhấn biểu tượng trái tim để lưu game bạn thích nhé 💖',
      'fav_browse_games': 'Xem tất cả mini game',
    },
    'en': {
      // Settings screen
      'settings_title': 'Settings',
      'section_appearance': 'Appearance',
      'section_sound': 'Sound',
      'section_notification': 'Notifications',
      'section_language': 'Language',
      'section_info': 'About',
      'dark_mode': 'Dark mode',
      'dark_mode_sub': 'Easier on the eyes',
      'sound_effect': 'Sound effects',
      'sound_effect_sub': 'In-game sound',
      'bg_music': 'Background music',
      'bg_music_sub': 'Play music when app opens',
      'notification_reminder': 'Learning reminder',
      'notification_reminder_sub': 'Remind me to study every day',
      'reminder_time': 'Daily reminder time',
      'reminder_time_sub': 'Tap to change reminder time',
      'notification_title': '📚 Time to study vocabulary!',
      'notification_body':
          'Spend 5 minutes learning new words — VocabQuest is waiting! 🚀',
      'notification_permission_denied':
          'Notification permission denied. Please enable it in system Settings.',
      'notification_scheduled': 'Daily reminder set at %s ✅',
      'notification_cancelled': 'Study reminder turned off',
      'language_label': 'App language',
      'about_app': 'About app',
      'about_app_sub': 'Version',
      'rate_app': 'Rate the app',
      'rate_app_sub': 'Give us 5 stars!',
      'rate_app_thanks': 'Thanks for your %d-star rating! ⭐',
      'rate_app_dialog_title': 'Rate VocabQuest',
      'rate_app_dialog_sub': 'How do you like the app?',
      'share_app': 'Share app',
      'share_app_sub': 'Tell your friends',
      'share_copied': 'Share link copied! 📋',
      'share_text':
          '📚 Learn vocabulary with VocabQuest!\nDownload: https://vocabquest.app',
      'logout': 'Log out',
      'logout_confirm': 'Are you sure you want to log out?',
      'cancel': 'Cancel',
      'close': 'Close',
      'save': 'Save',
      'choose_language': 'Choose language',
      'footer': 'Made with ❤️ by VocabQuest Team',

      // Home screen
      'home_hello': 'Hello 👋',
      'home_welcome_new': 'New learner',
      'home_challenge_today': 'TODAY\'S CHALLENGE',
      'home_challenge_sub': 'Earn %d XP\nto keep your streak',
      'home_stat_score': 'Score',
      'home_stat_coin': 'Coins',
      'home_stat_xp': 'XP',
      'home_shortcut_profile': 'Profile',
      'home_shortcut_settings': 'Settings',
      'home_shortcut_badges': 'Badges',
      'home_shortcut_saved': 'Saved',
      'home_action_play': 'Play now',
      'home_action_play_sub': 'Pick a mini-game',
      'home_action_ranking': 'Ranking',
      'home_action_ranking_sub': 'Top players',
      'home_action_history': 'History',
      'home_action_history_sub': 'Recent results',
      'home_action_shop': 'Shop',
      'home_action_shop_sub': 'Vocab packs',
      'home_action_explore': 'Explore',

      // Profile screen
      'profile_title': 'Profile',
      'profile_please_login': 'Please log in',
      'profile_level_short': 'Lv',
      'profile_level_full': 'Level %d',
      'profile_stats_title': 'Game stats',
      'profile_stat_total': 'Total',
      'profile_stat_matching': 'Matching',
      'profile_stat_quiz': 'Quiz',
      'profile_stat_puzzle': 'Puzzle',
      'profile_streak': 'Streak',
      'profile_streak_record': 'Streak (best %d)',
      'profile_menu_history': 'Play history',
      'profile_menu_leaderboard': 'Leaderboard',
      'profile_menu_settings': 'Settings',
      'profile_menu_logout': 'Log out',
      'profile_updated': 'Updated',
      'profile_logout_confirm_title': 'Log out?',

      // Game menu
      'gm_title': 'Mini Games',
      'gm_featured': '⭐ Today\'s pick',
      'gm_featured_sub': 'Play the most popular game',
      'gm_all': '🎮 All mini games',
      'gm_all_sub': 'Pick a game to choose your vocab pack',
      'gm_ready': 'Ready to learn?',
      'gm_ready_sub': 'Pick a mini-game below to start 🚀',
      'gm_play_now': 'Play now',
      'gm_matching_desc': 'Match English words to Vietnamese meanings',
      'gm_quiz_desc': 'Pick the right answer among 4 options!',
      'gm_puzzle_desc': 'Arrange letters to form the correct word',
      'gm_game_matching': 'Matching',
      'gm_game_quiz': 'Quiz',
      'gm_game_puzzle': 'Word Puzzle',
      'gm_game_memory': 'Memory',
      'gm_memory_desc': 'Flip cards to find matching pairs — train your memory',

      // Leaderboard
      'lb_title': 'Leaderboard',

      // Favorites / Saved
      'fav_added': 'Added to favorites ❤️',
      'fav_removed': 'Removed from favorites',
      'fav_title': 'Saved games',
      'fav_empty_title': 'No favorites yet',
      'fav_empty_sub':
          'Go to Mini Games and tap the heart icon on any game to save it here 💖',
      'fav_browse_games': 'Browse all mini games',
    },
  };

  static String tr(String lang, String key) {
    return _strings[lang]?[key] ?? _strings['vi']![key] ?? key;
  }
}

/// Extension để mọi màn dễ dàng dịch: `context.t('home_hello')`.
/// Dùng `watch` → widget rebuild khi user đổi ngôn ngữ.
extension LocalizedContext on BuildContext {
  String t(String key) {
    final lang = watch<SettingsProvider>().language;
    return AppLocalizations.tr(lang, key);
  }

  /// Không reactive — dùng trong callback hoặc initState.
  String tr(String key) {
    final lang = read<SettingsProvider>().language;
    return AppLocalizations.tr(lang, key);
  }
}
