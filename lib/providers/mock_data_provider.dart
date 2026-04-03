import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/campaign.dart';
import '../models/activity_entry.dart';

class CampaignsNotifier extends Notifier<List<Campaign>> {
  @override
  List<Campaign> build() {
    return [
      Campaign(
        id: '1',
        name: 'Morning Run',
        goal: 'Run every day for 30 days',
        totalDays: 30,
        currentDay: 18,
        isActive: true,
        dayHistory: List.generate(18, (i) => i % 5 != 3),
      ),
      Campaign(
        id: '2',
        name: 'Daily Reading',
        goal: 'Read 20 pages per day for 21 days',
        totalDays: 21,
        currentDay: 21,
        isActive: false,
        dayHistory: List.generate(21, (i) => i % 7 != 6),
      ),
      Campaign(
        id: '3',
        name: 'No Sugar',
        goal: 'Avoid sugar for 14 days',
        totalDays: 14,
        currentDay: 7,
        isActive: true,
        dayHistory: List.generate(7, (_) => true),
      ),
      Campaign(
        id: '4',
        name: 'Meditation',
        goal: 'Meditate 10 min daily for 30 days',
        totalDays: 30,
        currentDay: 5,
        isActive: true,
        dayHistory: List.generate(5, (i) => i != 2),
      ),
    ];
  }

  void add(Campaign campaign) {
    state = [...state, campaign];
  }
}

final campaignsProvider =
    NotifierProvider<CampaignsNotifier, List<Campaign>>(
        CampaignsNotifier.new);

final activityFeedProvider = Provider<List<ActivityEntry>>((ref) {
  final now = DateTime.now();
  return [
    ActivityEntry(
      campaignName: 'Morning Run',
      date: now.subtract(const Duration(hours: 2)),
      completed: true,
    ),
    ActivityEntry(
      campaignName: 'No Sugar',
      date: now.subtract(const Duration(hours: 5)),
      completed: true,
    ),
    ActivityEntry(
      campaignName: 'Meditation',
      date: now.subtract(const Duration(days: 1)),
      completed: false,
    ),
    ActivityEntry(
      campaignName: 'Daily Reading',
      date: now.subtract(const Duration(days: 1, hours: 3)),
      completed: true,
    ),
    ActivityEntry(
      campaignName: 'Morning Run',
      date: now.subtract(const Duration(days: 2)),
      completed: true,
    ),
  ];
});

final statsProvider = Provider<Map<String, int>>((ref) {
  final campaigns = ref.watch(campaignsProvider);
  final active = campaigns.where((c) => c.isActive).length;
  final completed = campaigns.where((c) => !c.isActive).length;
  final longestStreak = campaigns
      .map((c) => _computeStreak(c.dayHistory))
      .fold(0, (a, b) => a > b ? a : b);
  return {
    'total': campaigns.length,
    'active': active,
    'completed': completed,
    'longestStreak': longestStreak,
  };
});

int _computeStreak(List<bool> history) {
  var streak = 0;
  for (final day in history.reversed) {
    if (day) {
      streak++;
    } else {
      break;
    }
  }
  return streak;
}
