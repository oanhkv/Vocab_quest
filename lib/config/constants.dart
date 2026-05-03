/// 📋 Hằng số toàn app
class AppConstants {
  static const String appName = 'VocabQuest';
  static const String appTagline = 'Học từ vựng - Vui chơi mỗi ngày';
  static const String appVersion = '1.0.0';

  // Firestore collections
  static const String usersCollection = 'users';
  static const String gameResultsCollection = 'game_results';
  static const String userSettingsCollection = 'user_settings';
  static const String achievementsCollection = 'achievements';

  // SharedPreferences keys
  static const String keyIsDarkMode = 'isDarkMode';
  static const String keySoundEnabled = 'soundEnabled';
  static const String keyMusicEnabled = 'musicEnabled';
  static const String keyLanguage = 'language';
  static const String keyNotificationEnabled = 'notificationEnabled';
  static const String keyReminderHour = 'reminderHour';
  static const String keyReminderMinute = 'reminderMinute';
  static const String keyUserRating = 'userRating';
  static const String keyIsFirstTime = 'isFirstTime';
  static const String keyFavoriteGames = 'favoriteGames';

  // Game types
  static const String gameMatching = 'matching';
  static const String gameQuiz = 'quiz';
  static const String gameWordPuzzle = 'word_puzzle';
  static const String gameMemory = 'memory';

  // Levels
  static const String levelBeginner = 'beginner';
  static const String levelIntermediate = 'intermediate';
  static const String levelAdvanced = 'advanced';

  // Asset paths
  static const String vocabBeginnerJson = 'assets/data/vocab_beginner.json';
  static const String vocabIntermediateJson =
      'assets/data/vocab_intermediate.json';
  static const String vocabAdvancedJson = 'assets/data/vocab_advanced.json';

  // Game config
  static const int matchingGamePairs = 4;
  static const int quizGameQuestions = 10;
  static const int puzzleGameWords = 5;
  static const int gameTimeSeconds = 60;
}

/// 🏆 Level XP - cần bao nhiêu XP để lên cấp
class LevelSystem {
  static const Map<int, int> xpThresholds = {
    1: 0,
    2: 100,
    3: 250,
    4: 500,
    5: 1000,
    6: 2000,
    7: 3500,
    8: 5500,
    9: 8000,
    10: 12000,
  };

  static int getLevelFromXP(int xp) {
    int level = 1;
    xpThresholds.forEach((key, value) {
      if (xp >= value) level = key;
    });
    return level;
  }

  static int getXPForNextLevel(int currentLevel) {
    return xpThresholds[currentLevel + 1] ?? 99999;
  }
}