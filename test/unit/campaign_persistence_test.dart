import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:test/test.dart';
import 'package:mtbox_app/models/campaign.dart';
import 'package:mtbox_app/models/campaign_adapter.dart';
import 'package:mtbox_app/providers/mock_data_provider.dart';

void main() {
  late Directory tempDir;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('hive_persistence_test');
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

  // ── CampaignAdapter ───────────────────────────────────────────────────────

  group('CampaignAdapter', () {
    test('typeId is 0', () {
      expect(CampaignAdapter().typeId, equals(0));
    });

    test('round-trips all fields of a Campaign correctly', () async {
      final box = Hive.box<Campaign>('campaigns');
      final original = Campaign(
        id: 'rt-1',
        name: 'Round Trip',
        goal: 'Run every day',
        totalDays: 30,
        currentDay: 15,
        isActive: true,
        dayHistory: List.generate(15, (i) => i % 3 != 0),
      );
      await box.put(original.id, original);
      final retrieved = box.get(original.id)!;

      expect(retrieved.id, equals(original.id));
      expect(retrieved.name, equals(original.name));
      expect(retrieved.goal, equals(original.goal));
      expect(retrieved.totalDays, equals(original.totalDays));
      expect(retrieved.currentDay, equals(original.currentDay));
      expect(retrieved.isActive, equals(original.isActive));
      expect(retrieved.dayHistory, equals(original.dayHistory));
    });

    test('round-trips a campaign with empty dayHistory', () async {
      final box = Hive.box<Campaign>('campaigns');
      final c = Campaign(
        id: 'empty-history',
        name: 'Brand New',
        goal: 'Just started',
        totalDays: 7,
        currentDay: 0,
        isActive: true,
        dayHistory: [],
      );
      await box.put(c.id, c);
      expect(box.get(c.id)!.dayHistory, isEmpty);
    });

    test('round-trips a campaign with all-false dayHistory', () async {
      final box = Hive.box<Campaign>('campaigns');
      final c = Campaign(
        id: 'all-false',
        name: 'Struggling',
        goal: 'Not giving up',
        totalDays: 5,
        currentDay: 5,
        isActive: false,
        dayHistory: [false, false, false, false, false],
      );
      await box.put(c.id, c);
      expect(box.get(c.id)!.dayHistory, equals([false, false, false, false, false]));
    });

    test('round-trips isActive=false correctly', () async {
      final box = Hive.box<Campaign>('campaigns');
      final c = Campaign(
        id: 'done',
        name: 'Completed',
        goal: 'All done',
        totalDays: 10,
        currentDay: 10,
        isActive: false,
        dayHistory: List.generate(10, (_) => true),
      );
      await box.put(c.id, c);
      expect(box.get('done')!.isActive, isFalse);
    });

    test('multiple campaigns stored and retrieved independently', () async {
      final box = Hive.box<Campaign>('campaigns');
      final a = Campaign(
        id: 'alpha',
        name: 'Alpha',
        goal: 'First goal',
        totalDays: 10,
        currentDay: 3,
        isActive: true,
        dayHistory: [true, false, true],
      );
      final b = Campaign(
        id: 'beta',
        name: 'Beta',
        goal: 'Second goal',
        totalDays: 14,
        currentDay: 7,
        isActive: false,
        dayHistory: List.generate(7, (_) => true),
      );
      await box.put(a.id, a);
      await box.put(b.id, b);

      expect(box.get('alpha')!.name, equals('Alpha'));
      expect(box.get('beta')!.name, equals('Beta'));
      expect(box.length, equals(2));
    });
  });

  // ── CampaignsNotifier — persistence ──────────────────────────────────────

  group('CampaignsNotifier — persistence', () {
    test('build() seeds box with 4 campaigns when box is empty', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final campaigns = container.read(campaignsProvider);
      expect(campaigns.length, equals(4));
      expect(Hive.box<Campaign>('campaigns').length, equals(4));
    });

    test('build() seed contains the expected campaign names', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final names = container.read(campaignsProvider).map((c) => c.name).toList();
      expect(names, containsAll(['Morning Run', 'Daily Reading', 'No Sugar', 'Meditation']));
    });

    test('build() does not re-seed when box already has campaigns', () async {
      final box = Hive.box<Campaign>('campaigns');
      final existing = Campaign(
        id: 'pre-existing',
        name: 'My Campaign',
        goal: 'Custom',
        totalDays: 7,
        currentDay: 0,
        isActive: true,
        dayHistory: [],
      );
      await box.put(existing.id, existing);

      final container = ProviderContainer();
      addTearDown(container.dispose);
      final campaigns = container.read(campaignsProvider);

      expect(campaigns.length, equals(1));
      expect(campaigns.first.name, equals('My Campaign'));
    });

    test('add() persists campaign to the Hive box', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      container.read(campaignsProvider); // trigger seed

      final newCampaign = Campaign(
        id: 'persist-check',
        name: 'Persisted',
        goal: 'Stay in Hive',
        totalDays: 14,
        currentDay: 0,
        isActive: true,
        dayHistory: [],
      );
      container.read(campaignsProvider.notifier).add(newCampaign);

      final box = Hive.box<Campaign>('campaigns');
      expect(box.containsKey('persist-check'), isTrue);
      expect(box.get('persist-check')!.name, equals('Persisted'));
    });

    test('add() state reflects the updated box contents', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final initialCount = container.read(campaignsProvider).length;

      container.read(campaignsProvider.notifier).add(Campaign(
        id: 'state-check',
        name: 'New One',
        goal: 'Goal',
        totalDays: 21,
        currentDay: 0,
        isActive: true,
        dayHistory: [],
      ));

      final after = container.read(campaignsProvider);
      expect(after.length, equals(initialCount + 1));
      expect(after.any((c) => c.id == 'state-check'), isTrue);
    });

    test('add() persists all Campaign fields accurately', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      container.read(campaignsProvider); // trigger seed

      final campaign = Campaign(
        id: 'fields-check',
        name: 'Field Verify',
        goal: 'All fields stored',
        totalDays: 42,
        currentDay: 7,
        isActive: false,
        dayHistory: [true, false, true, true, false, true, true],
      );
      container.read(campaignsProvider.notifier).add(campaign);

      final stored = Hive.box<Campaign>('campaigns').get('fields-check')!;
      expect(stored.name, equals('Field Verify'));
      expect(stored.goal, equals('All fields stored'));
      expect(stored.totalDays, equals(42));
      expect(stored.currentDay, equals(7));
      expect(stored.isActive, isFalse);
      expect(stored.dayHistory, equals([true, false, true, true, false, true, true]));
    });
  });
}
