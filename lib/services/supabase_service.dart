import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/campaign.dart';

const _kSupabaseUrl = 'https://euxbkoxtetsqhiiitpvv.supabase.co';
const _kSupabaseAnonKey = 'sb_publishable_OOV_2axp4m8Ne1pLLwlzeQ_laQPn2Vn';

class SupabaseService {
  static Future<void> initialize() async {
    await Supabase.initialize(url: _kSupabaseUrl, anonKey: _kSupabaseAnonKey);
  }

  static SupabaseClient get client => Supabase.instance.client;

  // ── Campaign serialization ──────────────────────────────────────────────

  static Map<String, dynamic> campaignToMap(Campaign c, String userId) {
    return {
      'id': c.id,
      'user_id': userId,
      'name': c.name,
      'goal': c.goal,
      'total_days': c.totalDays,
      'current_day': c.currentDay,
      'is_active': c.isActive,
      'day_history': c.dayHistory.map((b) => b ? 1 : 0).join(','),
      'last_check_in_date': c.lastCheckInDate,
      'reminder_enabled': c.reminderEnabled,
      'reminder_time': c.reminderTime,
      'color_hex': c.colorHex,
      'icon_name': c.iconName,
      'goal_type': c.goalType.index,
      'metric_name': c.metricName,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  static Campaign campaignFromMap(Map<String, dynamic> map) {
    final dayHistoryStr = map['day_history'] as String? ?? '';
    final dayHistory = dayHistoryStr.isEmpty
        ? <bool>[]
        : dayHistoryStr.split(',').map((s) => s.trim() == '1').toList();
    final goalTypeRaw = map['goal_type'] as int? ?? 0;
    final goalTypeIndex = goalTypeRaw.clamp(0, GoalType.values.length - 1);
    return Campaign(
      id: map['id'] as String,
      name: map['name'] as String,
      goal: map['goal'] as String? ?? map['name'] as String,
      totalDays: map['total_days'] as int,
      currentDay: map['current_day'] as int? ?? 0,
      isActive: map['is_active'] as bool? ?? true,
      dayHistory: dayHistory,
      lastCheckInDate: map['last_check_in_date'] as String?,
      reminderEnabled: map['reminder_enabled'] as bool? ?? false,
      reminderTime: map['reminder_time'] as String?,
      colorHex: map['color_hex'] as String? ?? '4C6EAD',
      iconName: map['icon_name'] as String? ?? 'fitness_center',
      goalType: GoalType.values[goalTypeIndex],
      metricName: map['metric_name'] as String? ?? '',
    );
  }

  // ── Campaign DB operations ──────────────────────────────────────────────

  static Future<List<Campaign>> fetchCampaigns(String userId) async {
    final data = await client
        .from('campaigns')
        .select()
        .eq('user_id', userId)
        .order('created_at');
    return (data as List).map((m) => campaignFromMap(m as Map<String, dynamic>)).toList();
  }

  static Future<void> upsertCampaign(Campaign campaign, String userId) async {
    await client.from('campaigns').upsert(campaignToMap(campaign, userId));
  }

  static Future<void> deleteCampaign(String campaignId) async {
    await client.from('campaigns').delete().eq('id', campaignId);
  }

  static Future<void> deleteAllCampaigns(String userId) async {
    await client.from('campaigns').delete().eq('user_id', userId);
  }
}
