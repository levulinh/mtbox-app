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
    tempDir = await Directory.systemTemp.createTemp('hive_edit_test');
    Hive.init(tempDir.path);
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(CampaignAdapter());
    }
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

  // Helper: seed one campaign and return a ProviderContainer watching it.
  ProviderContainer seedOne(Campaign campaign) {
    Hive.box<Campaign>('campaigns').put(campaign.id, campaign);
    final container = ProviderContainer();
    container.read(campaignsProvider); // trigger build()
    return container;
  }

  final base = Campaign(
    id: 'edit-1',
    name: 'Original Name',
    goal: 'Original goal',
    totalDays: 20,
    currentDay: 5,
    isActive: true,
    dayHistory: [true, false, true, true, false],
    lastCheckInDate: '2026-04-01',
  );

  // ── update() ─────────────────────────────────────────────────────────────

  group('CampaignsNotifier.update()', () {
    test('updates name in state', () {
      final container = seedOne(base);
      addTearDown(container.dispose);

      container.read(campaignsProvider.notifier).update(
            'edit-1',
            name: 'New Name',
            totalDays: 20,
          );

      final campaigns = container.read(campaignsProvider);
      expect(campaigns.firstWhere((c) => c.id == 'edit-1').name,
          equals('New Name'));
    });

    test('updates totalDays in state', () {
      final container = seedOne(base);
      addTearDown(container.dispose);

      container.read(campaignsProvider.notifier).update(
            'edit-1',
            name: 'Original Name',
            totalDays: 45,
          );

      final campaigns = container.read(campaignsProvider);
      expect(campaigns.firstWhere((c) => c.id == 'edit-1').totalDays,
          equals(45));
    });

    test('preserves currentDay', () {
      final container = seedOne(base);
      addTearDown(container.dispose);

      container.read(campaignsProvider.notifier).update(
            'edit-1',
            name: 'New Name',
            totalDays: 30,
          );

      final campaigns = container.read(campaignsProvider);
      expect(campaigns.firstWhere((c) => c.id == 'edit-1').currentDay,
          equals(base.currentDay));
    });

    test('preserves dayHistory', () {
      final container = seedOne(base);
      addTearDown(container.dispose);

      container.read(campaignsProvider.notifier).update(
            'edit-1',
            name: 'New Name',
            totalDays: 30,
          );

      final campaigns = container.read(campaignsProvider);
      expect(campaigns.firstWhere((c) => c.id == 'edit-1').dayHistory,
          equals(base.dayHistory));
    });

    test('preserves lastCheckInDate', () {
      final container = seedOne(base);
      addTearDown(container.dispose);

      container.read(campaignsProvider.notifier).update(
            'edit-1',
            name: 'New Name',
            totalDays: 30,
          );

      final campaigns = container.read(campaignsProvider);
      expect(
          campaigns.firstWhere((c) => c.id == 'edit-1').lastCheckInDate,
          equals('2026-04-01'));
    });

    test('persists updated name to Hive', () {
      final container = seedOne(base);
      addTearDown(container.dispose);

      container.read(campaignsProvider.notifier).update(
            'edit-1',
            name: 'Hive Persisted',
            totalDays: 20,
          );

      expect(Hive.box<Campaign>('campaigns').get('edit-1')!.name,
          equals('Hive Persisted'));
    });

    test('does nothing for unknown campaignId', () {
      final container = seedOne(base);
      addTearDown(container.dispose);

      final countBefore = container.read(campaignsProvider).length;

      container.read(campaignsProvider.notifier).update(
            'does-not-exist',
            name: 'Ghost',
            totalDays: 10,
          );

      expect(container.read(campaignsProvider).length, equals(countBefore));
      expect(
          container.read(campaignsProvider).firstWhere((c) => c.id == 'edit-1').name,
          equals('Original Name'));
    });
  });

  // ── delete() ─────────────────────────────────────────────────────────────

  group('CampaignsNotifier.delete()', () {
    test('removes campaign from state', () {
      final container = seedOne(base);
      addTearDown(container.dispose);

      final countBefore = container.read(campaignsProvider).length;
      container.read(campaignsProvider.notifier).delete('edit-1');

      expect(container.read(campaignsProvider).length,
          equals(countBefore - 1));
      expect(container.read(campaignsProvider).any((c) => c.id == 'edit-1'),
          isFalse);
    });

    test('removes campaign from Hive', () {
      final container = seedOne(base);
      addTearDown(container.dispose);

      container.read(campaignsProvider.notifier).delete('edit-1');

      expect(Hive.box<Campaign>('campaigns').containsKey('edit-1'), isFalse);
    });

    test('does not affect other campaigns when one is deleted', () {
      final other = Campaign(
        id: 'other-1',
        name: 'Keep Me',
        goal: 'Do not delete',
        totalDays: 7,
        currentDay: 0,
        isActive: true,
        dayHistory: [],
      );
      final box = Hive.box<Campaign>('campaigns');
      box.put(base.id, base);
      box.put(other.id, other);

      final container = ProviderContainer();
      addTearDown(container.dispose);
      container.read(campaignsProvider);

      container.read(campaignsProvider.notifier).delete('edit-1');

      final remaining = container.read(campaignsProvider);
      expect(remaining.any((c) => c.id == 'other-1'), isTrue);
      expect(remaining.any((c) => c.id == 'edit-1'), isFalse);
    });

    test('does nothing for unknown campaignId', () {
      final container = seedOne(base);
      addTearDown(container.dispose);

      final countBefore = container.read(campaignsProvider).length;
      container.read(campaignsProvider.notifier).delete('ghost');

      expect(container.read(campaignsProvider).length, equals(countBefore));
    });
  });
}
