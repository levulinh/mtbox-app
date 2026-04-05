import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:riverpod/riverpod.dart';
import 'package:mtbox_app/models/campaign.dart';
import 'package:mtbox_app/models/campaign_adapter.dart';
import 'package:mtbox_app/providers/mock_data_provider.dart';
import 'dart:io';

void main() {
  late Directory tempDir;

  setUpAll(() async {
    tempDir = Directory.systemTemp.createTempSync();
    Hive.init(tempDir.path);
    Hive.registerAdapter(CampaignAdapter());
  });

  setUp(() async {
    await Hive.openBox<Campaign>('campaigns');
    await Hive.openBox('settings');
  });

  tearDown(() async {
    if (Hive.isBoxOpen('campaigns')) {
      await Hive.box<Campaign>('campaigns').clear();
      await Hive.box<Campaign>('campaigns').close();
    }
    if (Hive.isBoxOpen('settings')) {
      await Hive.box('settings').clear();
      await Hive.box('settings').close();
    }
  });

  tearDownAll(() async {
    try {
      await Hive.close();
    } catch (e) {
      // Already closed
    }
    tempDir.deleteSync(recursive: true);
  });

  group('Sample data initialization', () {
    test('sample campaigns have correct IDs on first init', () {
      final container = ProviderContainer();
      final campaigns = container.read(campaignsProvider);
      expect(campaigns.any((c) => c.id == 'sample-read-daily'), true);
      expect(campaigns.any((c) => c.id == 'sample-exercise'), true);
    });

    test('Read Daily campaign has correct properties', () {
      final container = ProviderContainer();
      final campaigns = container.read(campaignsProvider);
      final readDaily = campaigns.firstWhere((c) => c.id == 'sample-read-daily');

      expect(readDaily.name, 'Read Daily');
      expect(readDaily.colorHex, '4C6EAD');
      expect(readDaily.iconName, 'menu_book');
      expect(readDaily.totalDays, 30);
      expect(readDaily.currentDay, 10);
    });

    test('Exercise campaign has correct properties', () {
      final container = ProviderContainer();
      final campaigns = container.read(campaignsProvider);
      final exercise = campaigns.firstWhere((c) => c.id == 'sample-exercise');

      expect(exercise.name, 'Exercise 5x/Week');
      expect(exercise.colorHex, 'B5735A');
      expect(exercise.iconName, 'fitness_center');
      expect(exercise.totalDays, 20);
      expect(exercise.currentDay, 5);
    });

    test('sample campaigns have realistic streaks', () {
      final container = ProviderContainer();
      final campaigns = container.read(campaignsProvider);
      final readDaily = campaigns.firstWhere((c) => c.id == 'sample-read-daily');
      final exercise = campaigns.firstWhere((c) => c.id == 'sample-exercise');

      expect(readDaily.currentStreak, 7);
      expect(exercise.currentStreak, 3);
    });

    test('only 2 sample campaigns created', () {
      final container = ProviderContainer();
      final campaigns = container.read(campaignsProvider);
      expect(campaigns.length, 2);
    });
  });

  group('Sample data dismissal', () {
    test('dismissSamples removes campaigns from state', () {
      final container = ProviderContainer();
      expect(container.read(campaignsProvider).length, 2);
      container.read(campaignsProvider.notifier).dismissSamples();
      expect(container.read(campaignsProvider).length, 0);
    });

    test('dismissSamples sets flag to false in Hive', () {
      final container = ProviderContainer();
      container.read(campaignsProvider.notifier).dismissSamples();
      expect(Hive.box('settings').get('hasSampleData'), false);
    });

    test('SampleDataNotifier.dismiss() sets state to false', () {
      Hive.box('settings').put('hasSampleData', true);
      final container = ProviderContainer();
      final initial = container.read(hasSampleDataProvider);
      expect(initial, true);
      container.read(hasSampleDataProvider.notifier).dismiss();
      expect(container.read(hasSampleDataProvider), false);
    });
  });

  group('Empty state after dismiss', () {
    test('after dismissSamples, new campaigns can be added', () {
      final container = ProviderContainer();
      container.read(campaignsProvider.notifier).dismissSamples();
      
      var campaigns = container.read(campaignsProvider);
      expect(campaigns.length, 0);

      final newCampaign = Campaign(
        id: 'test',
        name: 'Test',
        goal: 'Test',
        totalDays: 30,
        currentDay: 0,
        isActive: true,
        dayHistory: [],
        colorHex: '000000',
        iconName: 'flag',
      );
      container.read(campaignsProvider.notifier).add(newCampaign);

      campaigns = container.read(campaignsProvider);
      expect(campaigns.length, 1);
      expect(campaigns.first.name, 'Test');
    });
  });
}
