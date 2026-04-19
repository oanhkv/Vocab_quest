/// 🎁 Thưởng khi pass 1 level lần đầu
class LevelReward {
  final int levelIndex;    // 1 / 2 / 3
  final int coins;
  final int xp;
  final bool packCompleted; // L3 pass → hoàn thành cả pack

  const LevelReward({
    required this.levelIndex,
    required this.coins,
    required this.xp,
    this.packCompleted = false,
  });

  bool get hasReward => coins > 0 || xp > 0;
}
