class Campaign {
  final String id;
  final String name;
  final String goal;
  final int totalDays;
  final int currentDay;
  final bool isActive;
  final List<bool> dayHistory;

  const Campaign({
    required this.id,
    required this.name,
    required this.goal,
    required this.totalDays,
    required this.currentDay,
    required this.isActive,
    required this.dayHistory,
  });

  double get progressPercent => currentDay / totalDays;

  int get completedDays => dayHistory.where((d) => d).length;

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
}
