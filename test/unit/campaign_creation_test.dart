import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:test/test.dart';
import 'package:mtbox_app/models/campaign.dart';
import 'package:mtbox_app/models/campaign_adapter.dart';
import 'package:mtbox_app/providers/mock_data_provider.dart';

Campaign makeNewCampaign({String id = 'new', String name = 'New Campaign', int totalDays = 30}) {
  return Campaign(
    id: id,
    name: name,
    goal: name,
    totalDays: totalDays,
    currentDay: 0,
    isActive: true,
    dayHistory: const [],
  );
}

void main() {
  late Directory tempDir;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('hive_creation_test');
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

  group('CampaignsNotifier', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('initial state has the 4 mock campaigns', () {
      final campaigns = container.read(campaignsProvider);
      expect(campaigns.length, equals(4));
    });

    test('initial campaign names match expected mock data', () {
      final campaigns = container.read(campaignsProvider);
      final names = campaigns.map((c) => c.name).toList();
      expect(names, containsAll(['Morning Run', 'Daily Reading', 'No Sugar', 'Meditation']));
    });

    test('add() increases list length by 1', () {
      final notifier = container.read(campaignsProvider.notifier);
      final before = container.read(campaignsProvider).length;
      notifier.add(makeNewCampaign());
      expect(container.read(campaignsProvider).length, equals(before + 1));
    });

    test('add() appends to the end of the list', () {
      final notifier = container.read(campaignsProvider.notifier);
      final campaign = makeNewCampaign(id: 'tail', name: 'Tail Campaign');
      notifier.add(campaign);
      expect(container.read(campaignsProvider).last.id, equals('tail'));
      expect(container.read(campaignsProvider).last.name, equals('Tail Campaign'));
    });

    test('add() preserves all pre-existing campaigns', () {
      final notifier = container.read(campaignsProvider.notifier);
      final beforeIds = container.read(campaignsProvider).map((c) => c.id).toSet();
      notifier.add(makeNewCampaign(id: 'extra'));
      final afterIds = container.read(campaignsProvider).map((c) => c.id).toSet();
      expect(afterIds, containsAll(beforeIds));
    });

    test('add() stores all campaign fields correctly', () {
      final notifier = container.read(campaignsProvider.notifier);
      final campaign = Campaign(
        id: 'precise',
        name: 'Precise Test',
        goal: 'Precise Test',
        totalDays: 14,
        currentDay: 0,
        isActive: true,
        dayHistory: const [],
      );
      notifier.add(campaign);
      final stored = container.read(campaignsProvider).last;
      expect(stored.id, equals('precise'));
      expect(stored.name, equals('Precise Test'));
      expect(stored.totalDays, equals(14));
      expect(stored.currentDay, equals(0));
      expect(stored.isActive, isTrue);
      expect(stored.dayHistory, isEmpty);
    });

    test('add() called multiple times accumulates all campaigns', () {
      final notifier = container.read(campaignsProvider.notifier);
      notifier.add(makeNewCampaign(id: 'a', name: 'Alpha'));
      notifier.add(makeNewCampaign(id: 'b', name: 'Beta'));
      notifier.add(makeNewCampaign(id: 'c', name: 'Gamma'));
      // 4 initial + 3 added
      expect(container.read(campaignsProvider).length, equals(7));
    });

    test('add() order is preserved across multiple calls', () {
      final notifier = container.read(campaignsProvider.notifier);
      notifier.add(makeNewCampaign(id: 'first', name: 'First'));
      notifier.add(makeNewCampaign(id: 'second', name: 'Second'));
      final campaigns = container.read(campaignsProvider);
      expect(campaigns[campaigns.length - 2].id, equals('first'));
      expect(campaigns[campaigns.length - 1].id, equals('second'));
    });
  });
}
