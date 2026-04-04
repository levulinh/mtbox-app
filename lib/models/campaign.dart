class Campaign {
  final String id;
  final String name;
  final String goal;
  final int totalDays;
  final int currentDay;
  final bool isActive;
  final List<bool> dayHistory;
  final String? lastCheckInDate;

  const Campaign({
    required this.id,
    required this.name,
    required this.goal,
    required this.totalDays,
    required this.currentDay,
    required this.isActive,
    required this.dayHistory,
    this.lastCheckInDate,
  });

  double get progressPercent => currentDay / totalDays;

  int get completedDays => dayHistory.where((d) => d).length;

  bool get checkedInToday {
    if (lastCheckInDate == null) return false;
    final now = DateTime.now();
    final today =
        '${now.year}-${_pad(now.month)}-${_pad(now.day)}';
    return lastCheckInDate == today;
  }

  int get currentStreak {
    var streak = 0;
    for (final day in dayHistory.reversed) {
      if (day) {
        streak++;
      } else {
        break;
      }
    }
    return streak;
  }

  int get bestStreak {
    var best = 0;
    var current = 0;
    for (final day in dayHistory) {
      if (day) {
        current++;
        if (current > best) best = current;
      } else {
        current = 0;
      }
    }
    return best;
  }

  bool get hasStreak => dayHistory.isNotEmpty;

  /// True when the current streak was preceded by a missed day (streak was broken).
  bool get isStreakBroken {
    if (dayHistory.isEmpty) return false;
    final idx = dayHistory.length - currentStreak - 1;
    return idx >= 0 && !dayHistory[idx];
  }

  /// Display count — never shows 0 (resets to 1 after a miss per design).
  int get streakDisplayCount => currentStreak == 0 ? 1 : currentStreak;

  static String _pad(int n) => n.toString().padLeft(2, '0');
}
