import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mtbox_app/models/campaign.dart';
import 'package:mtbox_app/models/activity_entry.dart';
import 'package:mtbox_app/providers/mock_data_provider.dart';

void main() {
  group('Campaign.progressPercent', () {
    test('returns correct fraction mid-way', () {
      final c = Campaign(
        id: '1',
        name: 'Test',
        goal: 'Goal',
        totalDays: 30,
        currentDay: 18,
        isActive: true,
        dayHistory: [],
      );
      expect(c.progressPercent, closeTo(0.6, 0.0001));
    });

    test('returns 0.0 at day 0', () {
      final c = Campaign(
        id: '2',
        name: 'Test',
        goal: 'Goal',
        totalDays: 30,
        currentDay: 0,
        isActive: true,
        dayHistory: [],
      );
      expect(c.progressPercent, 0.0);
    });

    test('returns 1.0 when fully completed', () {
      final c = Campaign(
        id: '3',
        name: 'Test',
        goal: 'Goal',
        totalDays: 21,
        currentDay: 21,
        isActive: false,
        dayHistory: [],
      );
      expect(c.progressPercent, 1.0);
    });

    test('returns correct fraction for small campaign', () {
      final c = Campaign(
        id: '4',
        name: 'Test',
        goal: 'Goal',
        totalDays: 14,
        currentDay: 7,
        isActive: true,
        dayHistory: [],
      );
      expect(c.progressPercent, closeTo(0.5, 0.0001));
    });
  });

  group('ActivityEntry', () {
    test('stores completed status correctly', () {
      final now = DateTime.now();
      final done = ActivityEntry(
        campaignName: 'Run',
        date: now,
        completed: true,
      );
      final missed = ActivityEntry(
        campaignName: 'Meditation',
        date: now,
        completed: false,
      );
      expect(done.completed, isTrue);
      expect(missed.completed, isFalse);
    });

    test('stores campaign name', () {
      final entry = ActivityEntry(
        campaignName: 'Morning Run',
        date: DateTime.now(),
        completed: true,
      );
      expect(entry.campaignName, 'Morning Run');
    });
  });

  group('statsProvider', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('total campaigns count is 4', () {
      final stats = container.read(statsProvider);
      expect(stats['total'], 4);
    });

    test('active campaigns count is 3', () {
      final stats = container.read(statsProvider);
      expect(stats['active'], 3);
    });

    test('completed campaigns count is 1', () {
      final stats = container.read(statsProvider);
      expect(stats['completed'], 1);
    });

    test('longestStreak is 7 (No Sugar campaign, all true)', () {
      final stats = container.read(statsProvider);
      expect(stats['longestStreak'], 7);
    });
  });

  group('campaignsProvider', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('provides 4 campaigns', () {
      final campaigns = container.read(campaignsProvider);
      expect(campaigns.length, 4);
    });

    test('first campaign is Morning Run and is active', () {
      final campaigns = container.read(campaignsProvider);
      expect(campaigns.first.name, 'Morning Run');
      expect(campaigns.first.isActive, isTrue);
    });

    test('Daily Reading campaign is inactive (completed)', () {
      final campaigns = container.read(campaignsProvider);
      final reading = campaigns.firstWhere((c) => c.name == 'Daily Reading');
      expect(reading.isActive, isFalse);
      expect(reading.currentDay, reading.totalDays);
    });
  });

  group('activityFeedProvider', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('provides 5 activity entries', () {
      final feed = container.read(activityFeedProvider);
      expect(feed.length, 5);
    });

    test('first entry is completed', () {
      final feed = container.read(activityFeedProvider);
      expect(feed.first.completed, isTrue);
    });

    test('at least one entry is missed', () {
      final feed = container.read(activityFeedProvider);
      expect(feed.any((e) => !e.completed), isTrue);
    });
  });
}
