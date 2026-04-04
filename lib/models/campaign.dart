import 'package:flutter/material.dart';

// Available campaign color palette (hex strings, no #)
const kCampaignColorOptions = [
  '4C6EAD', // Blue
  'B5735A', // Terracotta
  '5A8A6E', // Forest
  '9B6B9B', // Plum
  'C4A052', // Amber
  '6B8A9B', // Steel
  '8B7355', // Khaki
  '9B5A6B', // Rose
];

// Available campaign icons: (name, IconData)
const kCampaignIconOptions = [
  ('fitness_center', Icons.fitness_center),
  ('menu_book', Icons.menu_book),
  ('directions_run', Icons.directions_run),
  ('self_improvement', Icons.self_improvement),
  ('language', Icons.language),
  ('code', Icons.code),
  ('music_note', Icons.music_note),
  ('restaurant', Icons.restaurant),
];

class Campaign {
  final String id;
  final String name;
  final String goal;
  final int totalDays;
  final int currentDay;
  final bool isActive;
  final List<bool> dayHistory;
  final String? lastCheckInDate;
  final bool reminderEnabled;
  final String? reminderTime; // "HH:mm" 24h format, e.g. "09:00"
  final String colorHex; // e.g. '4C6EAD' (no #)
  final String iconName; // e.g. 'fitness_center'

  const Campaign({
    required this.id,
    required this.name,
    required this.goal,
    required this.totalDays,
    required this.currentDay,
    required this.isActive,
    required this.dayHistory,
    this.lastCheckInDate,
    this.reminderEnabled = false,
    this.reminderTime,
    this.colorHex = '4C6EAD',
    this.iconName = 'fitness_center',
  });

  /// The campaign's accent color, parsed from [colorHex].
  Color get campaignColor =>
      Color(int.parse(colorHex, radix: 16) | 0xFF000000);

  /// The campaign's icon, looked up by [iconName].
  IconData get iconData {
    for (final (name, icon) in kCampaignIconOptions) {
      if (name == iconName) return icon;
    }
    return Icons.fitness_center;
  }

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
