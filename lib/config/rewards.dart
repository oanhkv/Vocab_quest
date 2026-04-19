import '../models/level_reward_model.dart';

/// 🎯 Cấu hình thưởng khi pass level
class LevelRewardConfig {
  static const Map<int, int> _coins = {
    1: 30,
    2: 60,
    3: 150,
  };
  static const Map<int, int> _xp = {
    1: 20,
    2: 40,
    3: 100,
  };
  static const int totalLevels = 3;

  static LevelReward forLevel(int levelIndex) {
    return LevelReward(
      levelIndex: levelIndex,
      coins: _coins[levelIndex] ?? 30,
      xp: _xp[levelIndex] ?? 20,
      packCompleted: levelIndex >= totalLevels,
    );
  }
}
