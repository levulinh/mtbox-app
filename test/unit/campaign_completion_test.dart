import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:test/test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mtbox_app/models/campaign.dart';
import 'package:mtbox_app/models/campaign_adapter.dart';
import 'package:mtbox_app/providers/mock_data_provider.dart';

void main() {
  group('CampaignsNotifier.checkIn() - campaign completion', () {
    late Box<Campaign> box;
    late Campaign testCampaign;
    late Directory tempDir;

    setUpAll(() {
      tempDir = Directory.systemTemp.createTempSync();
      Hive.init(tempDir.path);
      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(CampaignAdapter());
      }
    });

    setUp(() async {
      if (Hive.isBoxOpen('campaigns')) {
        await Hive.box<Campaign>('campaigns').clear();
        await Hive.box<Campaign>('campaigns').close();
      }
      box = await Hive.openBox<Campaign>('campaigns');

      // Campaign with 3-day goal on day 2 (one check-in left)
      testCampaign = Campaign(
        id: 'test-campaign',
        name: 'Test Campaign',
        goal: 'Complete a test campaign',
        totalDays: 3,
        currentDay: 2,
        isActive: true,
        dayHistory: [true, true],
        lastCheckInDate: '2026-04-03',
      );
      await box.put('test-campaign', testCampaign);
    });

    tearDown(() async {
      await box.clear();
      await box.close();
    });

    tearDownAll(() async {
      await Hive.close();
      await tempDir.delete(recursive: true);
    });

    ProviderContainer _container() {
      final c = ProviderContainer();
      addTearDown(c.dispose);
      return c;
    }

    test(
      'checkIn() returns false when campaign does not exist',
      () {
        box.put('test-campaign', testCampaign);
        final container = _container();
        container.read(campaignsProvider); // Initialize notifier

        final result =
            container.read(campaignsProvider.notifier).checkIn('nonexistent-id');

        expect(result, isFalse);
      },
    );

    test(
      'checkIn() returns false when campaign is not active (already completed)',
      () {
        final completedCampaign = Campaign(
          id: 'completed',
          name: 'Completed Campaign',
          goal: 'This is done',
          totalDays: 3,
          currentDay: 3,
          isActive: false,
          dayHistory: [true, true, true],
          lastCheckInDate: '2026-04-04',
        );
        box.put('completed', completedCampaign);

        final container = _container();
        container.read(campaignsProvider); // Initialize notifier

        final result = container.read(campaignsProvider.notifier).checkIn('completed');

        expect(result, isFalse);
      },
    );

    test(
      'checkIn() returns false when already checked in today',
      () {
        final today = DateTime.now();
        final dateStr =
            '${today.year}-${_pad(today.month)}-${_pad(today.day)}';

        final campaignCheckedInToday = Campaign(
          id: 'checked-in',
          name: 'Checked In Today',
          goal: 'Already checked in',
          totalDays: 5,
          currentDay: 2,
          isActive: true,
          dayHistory: [true, true],
          lastCheckInDate: dateStr,
        );
        box.put('checked-in', campaignCheckedInToday);

        final container = _container();
        container.read(campaignsProvider); // Initialize notifier

        final result =
            container.read(campaignsProvider.notifier).checkIn('checked-in');

        expect(result, isFalse);
      },
    );

    test(
      'checkIn() returns false when goal is not reached',
      () {
        // Campaign with 10-day goal, on day 2 (won't be completed by next check-in)
        final longCampaign = Campaign(
          id: 'long-campaign',
          name: 'Long Campaign',
          goal: 'Take a long time',
          totalDays: 10,
          currentDay: 2,
          isActive: true,
          dayHistory: [true, true],
          lastCheckInDate: '2026-04-03',
        );
        box.put('long-campaign', longCampaign);
        final container = _container();
        container.read(campaignsProvider); // Initialize notifier

        final result =
            container.read(campaignsProvider.notifier).checkIn('long-campaign');

        expect(result, isFalse);
      },
    );

    test(
      'checkIn() returns true when check-in completes the campaign',
      () {
        box.put('test-campaign', testCampaign);
        final container = _container();
        container.read(campaignsProvider); // Initialize notifier

        final result =
            container.read(campaignsProvider.notifier).checkIn('test-campaign');

        expect(result, isTrue);
      },
    );

    test(
      'checkIn() sets isActive to false when campaign is completed',
      () {
        box.put('test-campaign', testCampaign);
        final container = _container();
        container.read(campaignsProvider); // Initialize notifier

        container.read(campaignsProvider.notifier).checkIn('test-campaign');

        final updated = box.get('test-campaign')!;
        expect(updated.isActive, isFalse);
      },
    );

    test(
      'checkIn() increments currentDay and adds to dayHistory when completing',
      () {
        box.put('test-campaign', testCampaign);
        final container = _container();
        container.read(campaignsProvider); // Initialize notifier

        container.read(campaignsProvider.notifier).checkIn('test-campaign');

        final updated = box.get('test-campaign')!;
        expect(updated.currentDay, equals(3));
        expect(updated.dayHistory.length, equals(3));
        expect(updated.dayHistory.last, isTrue);
      },
    );

    test(
      'checkIn() still increments currentDay but does not complete if goal is not reached',
      () {
        // Campaign with 10-day goal, on day 2
        final longCampaign = Campaign(
          id: 'long-campaign',
          name: 'Long Campaign',
          goal: 'Take a long time',
          totalDays: 10,
          currentDay: 2,
          isActive: true,
          dayHistory: [true, true],
          lastCheckInDate: '2026-04-03',
        );
        box.put('long-campaign', longCampaign);

        final container = _container();
        container.read(campaignsProvider); // Initialize notifier

        container.read(campaignsProvider.notifier).checkIn('long-campaign');

        final updated = box.get('long-campaign')!;
        expect(updated.currentDay, equals(3));
        expect(updated.isActive, isTrue); // Still active
      },
    );

    test(
      'checkIn() returns false and does nothing if goal is not reached after check-in',
      () {
        // Campaign with 10-day goal, on day 2
        final longCampaign = Campaign(
          id: 'long-campaign',
          name: 'Long Campaign',
          goal: 'Take a long time',
          totalDays: 10,
          currentDay: 2,
          isActive: true,
          dayHistory: [true, true],
          lastCheckInDate: '2026-04-03',
        );
        box.put('long-campaign', longCampaign);

        final container = _container();
        container.read(campaignsProvider); // Initialize notifier

        final result =
            container.read(campaignsProvider.notifier).checkIn('long-campaign');

        expect(result, isFalse);
      },
    );
  });
}

String _pad(int n) => n.toString().padLeft(2, '0');
