import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:test/test.dart';
import 'package:mtbox_app/models/campaign.dart';
import 'package:mtbox_app/models/campaign_adapter.dart';
import 'package:mtbox_app/providers/mock_data_provider.dart';

void main() {
  // ── Campaign.checkedInToday ──────────────────────────────────────────────

  group('Campaign.checkedInToday', () {
    test('returns false when lastCheckInDate is null', () {
      final c = Campaign(
        id: '1',
        name: 'Run',
        goal: 'goal',
        totalDays: 30,
        currentDay: 0,
        isActive: true,
        dayHistory: [],
        lastCheckInDate: null,
      );
      expect(c.checkedInToday, isFalse);
    });

    test('returns true when lastCheckInDate matches today', () {
      final now = DateTime.now();
      final today =
          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
      final c = Campaign(
        id: '2',
        name: 'Run',
        goal: 'goal',
        totalDays: 30,
        currentDay: 5,
        isActive: true,
        dayHistory: List.generate(5, (_) => true),
        lastCheckInDate: today,
      );
      expect(c.checkedInToday, isTrue);
    });

    test('returns false when lastCheckInDate is yesterday', () {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final dateStr =
          '${yesterday.year}-${yesterday.month.toString().padLeft(2, '0')}-${yesterday.day.toString().padLeft(2, '0')}';
      final c = Campaign(
        id: '3',
        name: 'Run',
        goal: 'goal',
        totalDays: 30,
        currentDay: 5,
        isActive: true,
        dayHistory: List.generate(5, (_) => true),
        lastCheckInDate: dateStr,
      );
      expect(c.checkedInToday, isFalse);
    });
  });

  // ── Campaign.currentStreak ───────────────────────────────────────────────

  group('Campaign.currentStreak', () {
    Campaign make(List<bool> history) => Campaign(
          id: 'x',
          name: 'x',
          goal: 'x',
          totalDays: history.length + 1,
          currentDay: history.length,
          isActive: true,
          dayHistory: history,
        );

    test('returns 0 for empty history', () {
      expect(make([]).currentStreak, equals(0));
    });

    test('returns full length when all days are true', () {
      expect(make([true, true, true]).currentStreak, equals(3));
    });

    test('returns 0 when last day is false', () {
      expect(make([true, true, false]).currentStreak, equals(0));
    });

    test('counts only the trailing run of trues', () {
      // [true, false, true, true] → last two true → streak 2
      expect(make([true, false, true, true]).currentStreak, equals(2));
    });

    test('returns 1 when only the last day is true', () {
      expect(make([false, false, true]).currentStreak, equals(1));
    });

    test('single false entry returns 0', () {
      expect(make([false]).currentStreak, equals(0));
    });

    test('single true entry returns 1', () {
      expect(make([true]).currentStreak, equals(1));
    });
  });

  // ── CampaignsNotifier.checkIn() ──────────────────────────────────────────

  group('CampaignsNotifier.checkIn()', () {
    late Directory tempDir;

    setUpAll(() async {
      tempDir = await Directory.systemTemp.createTemp('hive_checkin_test');
      Hive.init(tempDir.path);
      Hive.registerAdapter(CampaignAdapter());
    });

    setUp(() async {
      await Hive.openBox<Campaign>('campaigns');
    });

    tearDown(() async {
      final box = Hive.box<Campaign>('campaigns');
      await box.clear();
      await box.close();
    });

    tearDownAll(() async {
      await Hive.close();
      await tempDir.delete(recursive: true);
    });

    Campaign _makeActive({int currentDay = 5, List<bool>? history}) {
      return Campaign(
        id: 'active-1',
        name: 'Morning Run',
        goal: 'Run 30 days',
        totalDays: 30,
        currentDay: currentDay,
        isActive: true,
        dayHistory: history ?? List.generate(currentDay, (_) => true),
        lastCheckInDate: null,
      );
    }

    ProviderContainer _container() {
      final c = ProviderContainer();
      addTearDown(c.dispose);
      return c;
    }

    test('happy path: increments currentDay by 1', () {
      final box = Hive.box<Campaign>('campaigns');
      box.put('active-1', _makeActive(currentDay: 5));

      final container = _container();
      container.read(campaignsProvider); // initialise notifier
      container.read(campaignsProvider.notifier).checkIn('active-1');

      final updated =
          container.read(campaignsProvider).firstWhere((c) => c.id == 'active-1');
      expect(updated.currentDay, equals(6));
    });

    test('happy path: appends true to dayHistory', () {
      final box = Hive.box<Campaign>('campaigns');
      box.put('active-1', _makeActive(currentDay: 3, history: [true, true, true]));

      final container = _container();
      container.read(campaignsProvider);
      container.read(campaignsProvider.notifier).checkIn('active-1');

      final updated =
          container.read(campaignsProvider).firstWhere((c) => c.id == 'active-1');
      expect(updated.dayHistory.length, equals(4));
      expect(updated.dayHistory.last, isTrue);
    });

    test('happy path: sets lastCheckInDate to today', () {
      final box = Hive.box<Campaign>('campaigns');
      box.put('active-1', _makeActive());

      final container = _container();
      container.read(campaignsProvider);
      container.read(campaignsProvider.notifier).checkIn('active-1');

      final now = DateTime.now();
      final today =
          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
      final updated =
          container.read(campaignsProvider).firstWhere((c) => c.id == 'active-1');
      expect(updated.lastCheckInDate, equals(today));
    });

    test('happy path: state reflects updated campaign', () {
      final box = Hive.box<Campaign>('campaigns');
      box.put('active-1', _makeActive(currentDay: 10));

      final container = _container();
      container.read(campaignsProvider);
      container.read(campaignsProvider.notifier).checkIn('active-1');

      expect(container.read(campaignsProvider).any((c) => c.id == 'active-1'),
          isTrue);
      expect(
        container.read(campaignsProvider).firstWhere((c) => c.id == 'active-1').checkedInToday,
        isTrue,
      );
    });

    test('double check-in: second call is a no-op', () {
      final box = Hive.box<Campaign>('campaigns');
      box.put('active-1', _makeActive(currentDay: 5));

      final container = _container();
      container.read(campaignsProvider);
      container.read(campaignsProvider.notifier).checkIn('active-1');
      container.read(campaignsProvider.notifier).checkIn('active-1');

      final updated =
          container.read(campaignsProvider).firstWhere((c) => c.id == 'active-1');
      expect(updated.currentDay, equals(6)); // only incremented once
      expect(updated.dayHistory.length, equals(6));
    });

    test('inactive campaign: checkIn is ignored', () {
      final box = Hive.box<Campaign>('campaigns');
      final inactive = Campaign(
        id: 'inactive-1',
        name: 'Done',
        goal: 'goal',
        totalDays: 10,
        currentDay: 10,
        isActive: false,
        dayHistory: List.generate(10, (_) => true),
        lastCheckInDate: null,
      );
      box.put('inactive-1', inactive);

      final container = _container();
      container.read(campaignsProvider);
      container.read(campaignsProvider.notifier).checkIn('inactive-1');

      final unchanged =
          container.read(campaignsProvider).firstWhere((c) => c.id == 'inactive-1');
      expect(unchanged.currentDay, equals(10));
      expect(unchanged.lastCheckInDate, isNull);
    });

    test('unknown campaignId: does not crash or alter state', () {
      final container = _container();
      container.read(campaignsProvider); // seeds 4 campaigns
      final countBefore = container.read(campaignsProvider).length;

      expect(
        () => container.read(campaignsProvider.notifier).checkIn('no-such-id'),
        returnsNormally,
      );
      expect(container.read(campaignsProvider).length, equals(countBefore));
    });
  });

  // ── CampaignAdapter — backward compat (lastCheckInDate) ─────────────────

  group('CampaignAdapter — lastCheckInDate backward compat', () {
    late Directory tempDir;

    setUpAll(() async {
      tempDir = await Directory.systemTemp.createTemp('hive_adapter_compat_test');
      Hive.init(tempDir.path);
      // Adapter may already be registered from another group in same process — guard
      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(CampaignAdapter());
      }
    });

    setUp(() async {
      await Hive.openBox<Campaign>('campaigns_compat');
    });

    tearDown(() async {
      final box = Hive.box<Campaign>('campaigns_compat');
      await box.clear();
      await box.close();
    });

    tearDownAll(() async {
      await Hive.close();
      await tempDir.delete(recursive: true);
    });

    test('round-trips a campaign with a non-null lastCheckInDate', () async {
      final box = Hive.box<Campaign>('campaigns_compat');
      final c = Campaign(
        id: 'with-date',
        name: 'Dated',
        goal: 'test',
        totalDays: 7,
        currentDay: 3,
        isActive: true,
        dayHistory: [true, true, true],
        lastCheckInDate: '2026-04-04',
      );
      await box.put(c.id, c);
      final retrieved = box.get(c.id)!;
      expect(retrieved.lastCheckInDate, equals('2026-04-04'));
    });

    test('round-trips a campaign with lastCheckInDate = null', () async {
      final box = Hive.box<Campaign>('campaigns_compat');
      final c = Campaign(
        id: 'no-date',
        name: 'No Date',
        goal: 'test',
        totalDays: 7,
        currentDay: 0,
        isActive: true,
        dayHistory: [],
        lastCheckInDate: null,
      );
      await box.put(c.id, c);
      final retrieved = box.get(c.id)!;
      expect(retrieved.lastCheckInDate, isNull);
    });

    test('checkedInToday is correct after a round-trip with today date', () async {
      final now = DateTime.now();
      final today =
          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
      final box = Hive.box<Campaign>('campaigns_compat');
      final c = Campaign(
        id: 'today-rt',
        name: 'Today',
        goal: 'test',
        totalDays: 10,
        currentDay: 3,
        isActive: true,
        dayHistory: [true, true, true],
        lastCheckInDate: today,
      );
      await box.put(c.id, c);
      expect(box.get(c.id)!.checkedInToday, isTrue);
    });
  });
}
