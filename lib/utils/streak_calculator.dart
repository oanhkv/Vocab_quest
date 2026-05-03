// 🔥 Helper tính streak (số ngày liên tiếp học) + milestone reward.
// Pure function — không đụng Firestore. Được gọi bên trong transaction
// khi `saveGameResult` để đảm bảo cập nhật atomic.

/// Mốc streak → coin + XP thưởng thêm (ngoài thưởng game thường).
const Map<int, StreakMilestone> streakMilestones = {
  3: StreakMilestone(bonusCoins: 30, bonusXP: 20),
  7: StreakMilestone(bonusCoins: 100, bonusXP: 75),
  14: StreakMilestone(bonusCoins: 200, bonusXP: 150),
  30: StreakMilestone(bonusCoins: 500, bonusXP: 400),
  60: StreakMilestone(bonusCoins: 1000, bonusXP: 800),
  100: StreakMilestone(bonusCoins: 2500, bonusXP: 2000),
};

class StreakMilestone {
  final int bonusCoins;
  final int bonusXP;
  const StreakMilestone({required this.bonusCoins, required this.bonusXP});
}

/// Kết quả tính streak sau khi chơi xong 1 game.
class StreakOutcome {
  /// Streak mới sau khi cập nhật (>= 0).
  final int newStreak;

  /// Longest streak mới (max(old, newStreak)).
  final int newLongest;

  /// Hôm nay là ngày chơi đầu tiên (streak tăng) hay đã chơi rồi.
  final bool streakIncreased;

  /// Mốc vừa đạt (3/7/14/30/60/100) — null nếu không đạt mốc mới.
  final int? milestoneHit;

  /// Bonus coin từ milestone (0 nếu không đạt).
  final int bonusCoins;

  /// Bonus XP từ milestone (0 nếu không đạt).
  final int bonusXP;

  const StreakOutcome({
    required this.newStreak,
    required this.newLongest,
    required this.streakIncreased,
    this.milestoneHit,
    this.bonusCoins = 0,
    this.bonusXP = 0,
  });

  bool get hasBonus => bonusCoins > 0 || bonusXP > 0;
}

/// Tính streak mới dựa trên ngày chơi lần trước và ngày hiện tại.
///
/// Luật:
/// - Cùng ngày (đã chơi hôm nay rồi): giữ nguyên streak, không tăng.
/// - Ngày kế tiếp (hôm qua): streak += 1 → có thể trigger milestone.
/// - Cách > 1 ngày (bỏ ngày): reset về 1.
/// - Chưa có lastPlayed: streak = 1.
StreakOutcome computeStreakUpdate({
  required DateTime? lastPlayed,
  required DateTime now,
  required int currentStreak,
  required int longestStreak,
}) {
  final today = DateTime(now.year, now.month, now.day);

  if (lastPlayed == null) {
    return StreakOutcome(
      newStreak: 1,
      newLongest: longestStreak < 1 ? 1 : longestStreak,
      streakIncreased: true,
      // streak = 1 không phải milestone
    );
  }

  final last = DateTime(lastPlayed.year, lastPlayed.month, lastPlayed.day);
  final deltaDays = today.difference(last).inDays;

  int newStreak;
  bool increased;

  if (deltaDays == 0) {
    // Đã chơi hôm nay — không thay đổi
    return StreakOutcome(
      newStreak: currentStreak,
      newLongest: longestStreak,
      streakIncreased: false,
    );
  } else if (deltaDays == 1) {
    newStreak = currentStreak + 1;
    increased = true;
  } else {
    // Bỏ ngày → reset
    newStreak = 1;
    increased = true;
  }

  final newLongest = newStreak > longestStreak ? newStreak : longestStreak;

  // Check milestone (chỉ khi streak thực sự tăng)
  int? milestone;
  int bonusCoins = 0;
  int bonusXP = 0;
  if (increased && streakMilestones.containsKey(newStreak)) {
    milestone = newStreak;
    final m = streakMilestones[newStreak]!;
    bonusCoins = m.bonusCoins;
    bonusXP = m.bonusXP;
  }

  return StreakOutcome(
    newStreak: newStreak,
    newLongest: newLongest,
    streakIncreased: increased,
    milestoneHit: milestone,
    bonusCoins: bonusCoins,
    bonusXP: bonusXP,
  );
}
