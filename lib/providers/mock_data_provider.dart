import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/campaign.dart';
import '../models/activity_entry.dart';
import '../services/supabase_service.dart';

const _kCampaignsBox = 'campaigns';

// Fixed IDs for sample campaigns so they can be deleted on dismiss.
const _kSampleReadDailyId = 'sample-read-daily';
const _kSampleExerciseId = 'sample-exercise';

final _sampleCampaigns = [
  Campaign(
    id: _kSampleReadDailyId,
    name: 'Read Daily',
    goal: 'Read Daily',
    totalDays: 30,
    currentDay: 10,
    isActive: true,
    // 3 missed, then 7 done → streak = 7
    dayHistory: [false, false, false, true, true, true, true, true, true, true],
    colorHex: '4C6EAD',
    iconName: 'menu_book',
  ),
  Campaign(
    id: _kSampleExerciseId,
    name: 'Exercise 5x/Week',
    goal: 'Exercise 5x/Week',
    totalDays: 20,
    currentDay: 5,
    isActive: true,
    // 2 missed, then 3 done → streak = 3
    dayHistory: [false, false, true, true, true],
    colorHex: 'B5735A',
    iconName: 'fitness_center',
  ),
];

class CampaignsNotifier extends Notifier<List<Campaign>> {
  RealtimeChannel? _realtimeChannel;

  @override
  List<Campaign> build() {
    final box = Hive.box<Campaign>(_kCampaignsBox);
    if (box.isEmpty) {
      for (final c in _sampleCampaigns) {
        box.put(c.id, c);
      }
      Hive.box('settings').put('hasSampleData', true);
    }
    // Load from Supabase and subscribe to realtime changes (fire-and-forget).
    Future.microtask(_syncFromSupabase);
    _subscribeRealtime();
    ref.onDispose(() => _realtimeChannel?.unsubscribe());
    return box.values.toList();
  }

  // ── Supabase sync ─────────────────────────────────────────────────────

  Future<void> _syncFromSupabase() async {
    final userId = SupabaseService.client.auth.currentUser?.id;
    if (userId == null) return;
    try {
      final campaigns = await SupabaseService.fetchCampaigns(userId);
      if (campaigns.isEmpty) {
        // New user — push local (sample) campaigns to Supabase.
        final box = Hive.box<Campaign>(_kCampaignsBox);
        for (final c in box.values) {
          await SupabaseService.upsertCampaign(c, userId);
        }
        return;
      }
      // Merge: Supabase is source of truth — overwrite Hive.
      final box = Hive.box<Campaign>(_kCampaignsBox);
      await box.clear();
      for (final c in campaigns) {
        await box.put(c.id, c);
      }
      state = box.values.toList();
    } catch (_) {
      // Network failure — local Hive data remains active.
    }
  }

  void _subscribeRealtime() {
    final userId = SupabaseService.client.auth.currentUser?.id;
    if (userId == null) return;
    _realtimeChannel = SupabaseService.client
        .channel('campaigns_data_$userId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'campaigns',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: userId,
          ),
          callback: _handleRealtimeChange,
        );
    _realtimeChannel!.subscribe();
  }

  void _handleRealtimeChange(PostgresChangePayload payload) {
    final box = Hive.box<Campaign>(_kCampaignsBox);
    switch (payload.eventType) {
      case PostgresChangeEvent.insert:
      case PostgresChangeEvent.update:
        final campaign = SupabaseService.campaignFromMap(payload.newRecord);
        box.put(campaign.id, campaign);
        state = box.values.toList();
      case PostgresChangeEvent.delete:
        final id = payload.oldRecord['id'] as String?;
        if (id != null) {
          box.delete(id);
          state = box.values.toList();
        }
      default:
        break;
    }
  }

  void _upsertAsync(Campaign campaign) {
    final userId = SupabaseService.client.auth.currentUser?.id;
    if (userId == null) return;
    SupabaseService.upsertCampaign(campaign, userId).ignore();
  }

  /// Deletes the 2 sample campaigns and clears the sample-data flag.
  void dismissSamples() {
    final box = Hive.box<Campaign>(_kCampaignsBox);
    box.delete(_kSampleReadDailyId);
    box.delete(_kSampleExerciseId);
    Hive.box('settings').put('hasSampleData', false);
    state = box.values.toList();
    SupabaseService.deleteCampaign(_kSampleReadDailyId).ignore();
    SupabaseService.deleteCampaign(_kSampleExerciseId).ignore();
  }

  void add(Campaign campaign) {
    final box = Hive.box<Campaign>(_kCampaignsBox);
    box.put(campaign.id, campaign);
    state = box.values.toList();
    _upsertAsync(campaign);
  }

  /// Returns true if this check-in completed the campaign goal.
  bool checkIn(String campaignId) {
    final box = Hive.box<Campaign>(_kCampaignsBox);
    final campaign = box.get(campaignId);
    if (campaign == null || !campaign.isActive || campaign.checkedInToday) {
      return false;
    }
    final now = DateTime.now();
    final dateStr =
        '${now.year}-${_pad(now.month)}-${_pad(now.day)}';
    final newCurrentDay = campaign.currentDay + 1;
    final isCompleted = newCurrentDay >= campaign.totalDays;
    final updated = Campaign(
      id: campaign.id,
      name: campaign.name,
      goal: campaign.goal,
      totalDays: campaign.totalDays,
      currentDay: newCurrentDay,
      isActive: !isCompleted,
      dayHistory: [...campaign.dayHistory, true],
      lastCheckInDate: dateStr,
      colorHex: campaign.colorHex,
      iconName: campaign.iconName,
      goalType: campaign.goalType,
      metricName: campaign.metricName,
    );
    box.put(campaignId, updated);
    state = box.values.toList();
    _upsertAsync(updated);
    return isCompleted;
  }

  void update(
    String campaignId, {
    required String name,
    required int totalDays,
    String? colorHex,
    String? iconName,
    GoalType? goalType,
    String? metricName,
  }) {
    final box = Hive.box<Campaign>(_kCampaignsBox);
    final campaign = box.get(campaignId);
    if (campaign == null) return;
    final updated = Campaign(
      id: campaign.id,
      name: name,
      goal: name,
      totalDays: totalDays,
      currentDay: campaign.currentDay,
      isActive: campaign.isActive,
      dayHistory: campaign.dayHistory,
      lastCheckInDate: campaign.lastCheckInDate,
      reminderEnabled: campaign.reminderEnabled,
      reminderTime: campaign.reminderTime,
      colorHex: colorHex ?? campaign.colorHex,
      iconName: iconName ?? campaign.iconName,
      goalType: goalType ?? campaign.goalType,
      metricName: metricName ?? campaign.metricName,
    );
    box.put(campaignId, updated);
    state = box.values.toList();
    _upsertAsync(updated);
  }

  void delete(String campaignId) {
    final box = Hive.box<Campaign>(_kCampaignsBox);
    box.delete(campaignId);
    state = box.values.toList();
    SupabaseService.deleteCampaign(campaignId).ignore();
  }

  void setReminder(String campaignId, {required bool enabled, String? time}) {
    final box = Hive.box<Campaign>(_kCampaignsBox);
    final campaign = box.get(campaignId);
    if (campaign == null) return;
    final updated = Campaign(
      id: campaign.id,
      name: campaign.name,
      goal: campaign.goal,
      totalDays: campaign.totalDays,
      currentDay: campaign.currentDay,
      isActive: campaign.isActive,
      dayHistory: campaign.dayHistory,
      lastCheckInDate: campaign.lastCheckInDate,
      reminderEnabled: enabled,
      reminderTime: time ?? campaign.reminderTime,
      colorHex: campaign.colorHex,
      iconName: campaign.iconName,
      goalType: campaign.goalType,
      metricName: campaign.metricName,
    );
    box.put(campaignId, updated);
    state = box.values.toList();
    _upsertAsync(updated);
  }

  static String _pad(int n) => n.toString().padLeft(2, '0');
}

final campaignsProvider =
    NotifierProvider<CampaignsNotifier, List<Campaign>>(
        CampaignsNotifier.new);

/// True while sample campaigns are present (first-run state).
class SampleDataNotifier extends Notifier<bool> {
  @override
  bool build() {
    return Hive.box('settings').get('hasSampleData', defaultValue: false)
        as bool;
  }

  void dismiss() {
    state = false;
  }
}

final hasSampleDataProvider =
    NotifierProvider<SampleDataNotifier, bool>(SampleDataNotifier.new);

// Mock device names rotated across historical activity entries
const _kMockActivityDevices = ['iPhone 14 Pro', 'MacBook Pro', 'iPad Air'];

final activityFeedProvider = Provider<List<ActivityEntry>>((ref) {
  final campaigns = ref.watch(campaignsProvider);
  final today = DateTime.now();
  final todayDate = DateTime(today.year, today.month, today.day);
  final List<ActivityEntry> entries = [];

  for (final campaign in campaigns) {
    if (campaign.dayHistory.isEmpty) {
      if (campaign.isActive) {
        entries.add(ActivityEntry(
          campaignName: campaign.name,
          date: todayDate,
          completed: false,
          dayNumber: campaign.currentDay + 1,
          totalDays: campaign.totalDays,
          isPending: true,
        ));
      }
      continue;
    }

    // Anchor the last dayHistory element to lastCheckInDate when available,
    // otherwise estimate from today.
    DateTime anchor;
    if (campaign.lastCheckInDate != null) {
      final parts = campaign.lastCheckInDate!.split('-');
      anchor = DateTime(
        int.parse(parts[0]),
        int.parse(parts[1]),
        int.parse(parts[2]),
      );
    } else {
      anchor = todayDate.subtract(
          Duration(days: campaign.dayHistory.length - 1));
    }

    for (int i = 0; i < campaign.dayHistory.length; i++) {
      final daysBack = campaign.dayHistory.length - 1 - i;
      // Assign mock device names to historical completed entries so the
      // activity feed shows device attribution for sync awareness.
      final String? device = campaign.dayHistory[i]
          ? _kMockActivityDevices[i % _kMockActivityDevices.length]
          : null;
      entries.add(ActivityEntry(
        campaignName: campaign.name,
        date: anchor.subtract(Duration(days: daysBack)),
        completed: campaign.dayHistory[i],
        dayNumber: i + 1,
        totalDays: campaign.totalDays,
        deviceName: device,
      ));
    }

    // Add pending entry for active campaigns not yet checked in today.
    if (campaign.isActive && !campaign.checkedInToday) {
      entries.add(ActivityEntry(
        campaignName: campaign.name,
        date: todayDate,
        completed: false,
        dayNumber: campaign.currentDay + 1,
        totalDays: campaign.totalDays,
        isPending: true,
      ));
    }
  }

  entries.sort((a, b) => b.date.compareTo(a.date));
  return entries;
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
