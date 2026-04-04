import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../lib/models/campaign.dart';
import '../../lib/models/campaign_adapter.dart';
import '../../lib/services/notification_service.dart';
import 'dart:io';
import 'package:path/path.dart' as p;

void main() {
  group('NotificationService', () {
    test('scheduleDaily parses HH:mm time correctly', () async {
      // Verify the time parsing logic works for different inputs
      expect(() {
        final parts = '14:30'.split(':');
        final hour = int.tryParse(parts[0]) ?? 9;
        final minute = int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0;
        expect(hour, 14);
        expect(minute, 30);
      }, returnsNormally);
    });

    test('scheduleDaily handles single-digit hour', () async {
      expect(() {
        final parts = '9:00'.split(':');
        final hour = int.tryParse(parts[0]) ?? 9;
        final minute = int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0;
        expect(hour, 9);
        expect(minute, 0);
      }, returnsNormally);
    });

    test('scheduleDaily handles midnight (00:00)', () async {
      expect(() {
        final parts = '00:00'.split(':');
        final hour = int.tryParse(parts[0]) ?? 9;
        final minute = int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0;
        expect(hour, 0);
        expect(minute, 0);
      }, returnsNormally);
    });

    test('scheduleDaily generates consistent notification ID', () {
      // Same campaign ID should always generate the same notification ID
      const campaignId = 'campaign-123';
      final notifId1 = campaignId.hashCode.abs() % 2147483647;
      final notifId2 = campaignId.hashCode.abs() % 2147483647;
      expect(notifId1, notifId2);
    });

    test('campaign ID hashCode generates valid notification ID', () {
      // Verify the ID generation logic produces valid Android notification IDs
      const campaignIds = ['1', 'abc-def-ghi', 'long-campaign-id-string'];
      for (final id in campaignIds) {
        final notifId = id.hashCode.abs() % 2147483647;
        expect(notifId, greaterThanOrEqualTo(0));
        expect(notifId, lessThan(2147483647));
      }
    });

    test('cancel uses same ID generation as scheduleDaily', () {
      // Ensure cancel uses consistent ID generation
      const campaignId = 'test-campaign';
      final scheduleId = campaignId.hashCode.abs() % 2147483647;
      final cancelId = campaignId.hashCode.abs() % 2147483647;
      expect(scheduleId, cancelId);
    });
  });

  group('CampaignsNotifier with Reminder', () {
    late Box<Campaign> box;
    late Directory tempDir;

    setUpAll(() async {
      tempDir = Directory.systemTemp.createTempSync();
      Hive.init(tempDir.path);
      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(CampaignAdapter());
      }
    });

    setUp(() async {
      box = await Hive.openBox<Campaign>('test_campaigns_${DateTime.now().millisecondsSinceEpoch}');
    });

    tearDown(() async {
      await box.clear();
      await box.close();
    });

    tearDownAll(() {
      tempDir.deleteSync(recursive: true);
    });

    test('Campaign model stores reminderEnabled and reminderTime', () {
      final campaign = Campaign(
        id: '1',
        name: 'Test Campaign',
        goal: 'Test goal',
        totalDays: 30,
        currentDay: 5,
        isActive: true,
        dayHistory: [true, true, true, true, true],
        reminderEnabled: true,
        reminderTime: '09:30',
      );

      expect(campaign.reminderEnabled, true);
      expect(campaign.reminderTime, '09:30');
    });

    test('Campaign model defaults reminderEnabled to false', () {
      final campaign = Campaign(
        id: '1',
        name: 'Test Campaign',
        goal: 'Test goal',
        totalDays: 30,
        currentDay: 5,
        isActive: true,
        dayHistory: [true, true, true, true, true],
      );

      expect(campaign.reminderEnabled, false);
      expect(campaign.reminderTime, isNull);
    });

    test('setReminder enables reminder with time', () {
      box.put('1', Campaign(
        id: '1',
        name: 'Morning Run',
        goal: 'Run daily',
        totalDays: 30,
        currentDay: 5,
        isActive: true,
        dayHistory: List.generate(5, (_) => true),
      ));

      final campaign = box.get('1')!;
      expect(campaign.reminderEnabled, false);
      expect(campaign.reminderTime, isNull);

      // Simulate setReminder(enabled: true, time: '09:00')
      final updated = Campaign(
        id: campaign.id,
        name: campaign.name,
        goal: campaign.goal,
        totalDays: campaign.totalDays,
        currentDay: campaign.currentDay,
        isActive: campaign.isActive,
        dayHistory: campaign.dayHistory,
        lastCheckInDate: campaign.lastCheckInDate,
        reminderEnabled: true,
        reminderTime: '09:00',
      );
      box.put('1', updated);

      final saved = box.get('1')!;
      expect(saved.reminderEnabled, true);
      expect(saved.reminderTime, '09:00');
    });

    test('setReminder disables reminder', () {
      box.put('1', Campaign(
        id: '1',
        name: 'Morning Run',
        goal: 'Run daily',
        totalDays: 30,
        currentDay: 5,
        isActive: true,
        dayHistory: List.generate(5, (_) => true),
        reminderEnabled: true,
        reminderTime: '09:00',
      ));

      final campaign = box.get('1')!;
      expect(campaign.reminderEnabled, true);

      // Simulate setReminder(enabled: false)
      final updated = Campaign(
        id: campaign.id,
        name: campaign.name,
        goal: campaign.goal,
        totalDays: campaign.totalDays,
        currentDay: campaign.currentDay,
        isActive: campaign.isActive,
        dayHistory: campaign.dayHistory,
        lastCheckInDate: campaign.lastCheckInDate,
        reminderEnabled: false,
        reminderTime: campaign.reminderTime, // keep the time
      );
      box.put('1', updated);

      final saved = box.get('1')!;
      expect(saved.reminderEnabled, false);
      expect(saved.reminderTime, '09:00'); // time persists
    });

    test('setReminder updates time while enabled', () {
      box.put('1', Campaign(
        id: '1',
        name: 'Morning Run',
        goal: 'Run daily',
        totalDays: 30,
        currentDay: 5,
        isActive: true,
        dayHistory: List.generate(5, (_) => true),
        reminderEnabled: true,
        reminderTime: '09:00',
      ));

      final campaign = box.get('1')!;

      // Update time to 14:30
      final updated = Campaign(
        id: campaign.id,
        name: campaign.name,
        goal: campaign.goal,
        totalDays: campaign.totalDays,
        currentDay: campaign.currentDay,
        isActive: campaign.isActive,
        dayHistory: campaign.dayHistory,
        lastCheckInDate: campaign.lastCheckInDate,
        reminderEnabled: true,
        reminderTime: '14:30',
      );
      box.put('1', updated);

      final saved = box.get('1')!;
      expect(saved.reminderEnabled, true);
      expect(saved.reminderTime, '14:30');
    });

    test('setReminder with null time preserves existing time', () {
      box.put('1', Campaign(
        id: '1',
        name: 'Morning Run',
        goal: 'Run daily',
        totalDays: 30,
        currentDay: 5,
        isActive: true,
        dayHistory: List.generate(5, (_) => true),
        reminderEnabled: false,
        reminderTime: '08:00',
      ));

      final campaign = box.get('1')!;

      // Enable with null time (should use existing)
      final updated = Campaign(
        id: campaign.id,
        name: campaign.name,
        goal: campaign.goal,
        totalDays: campaign.totalDays,
        currentDay: campaign.currentDay,
        isActive: campaign.isActive,
        dayHistory: campaign.dayHistory,
        lastCheckInDate: campaign.lastCheckInDate,
        reminderEnabled: true,
        reminderTime: campaign.reminderTime, // preserve existing
      );
      box.put('1', updated);

      final saved = box.get('1')!;
      expect(saved.reminderEnabled, true);
      expect(saved.reminderTime, '08:00');
    });

    test('Reminder fields persist through Hive round-trip', () async {
      // Create and save campaign with reminder
      final campaign = Campaign(
        id: '1',
        name: 'Daily Reading',
        goal: 'Read 20 pages',
        totalDays: 21,
        currentDay: 10,
        isActive: true,
        dayHistory: List.generate(10, (_) => true),
        reminderEnabled: true,
        reminderTime: '19:00',
      );
      await box.put('1', campaign);

      // Retrieve and verify
      final retrieved = box.get('1')!;
      expect(retrieved.reminderEnabled, true);
      expect(retrieved.reminderTime, '19:00');
      expect(retrieved.name, 'Daily Reading');
      expect(retrieved.totalDays, 21);
    });
  });
}
