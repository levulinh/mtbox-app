import 'package:test/test.dart';
import 'package:mtbox_app/models/campaign.dart';
import 'package:mtbox_app/models/activity_entry.dart';

/// Test helper: compute activity entries from campaigns.
/// This mirrors the logic in activityFeedProvider.
List<ActivityEntry> computeFeed(
  List<Campaign> campaigns, {
  DateTime? todayOverride,
}) {
  final today = todayOverride ?? DateTime.now();
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
      entries.add(ActivityEntry(
        campaignName: campaign.name,
        date: anchor.subtract(Duration(days: daysBack)),
        completed: campaign.dayHistory[i],
        dayNumber: i + 1,
        totalDays: campaign.totalDays,
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
}

Campaign _makeCampaign({
  required String id,
  required String name,
  required List<bool> history,
  required int totalDays,
  bool isActive = true,
  String? lastCheckInDate,
}) {
  return Campaign(
    id: id,
    name: name,
    goal: 'Test goal',
    totalDays: totalDays,
    currentDay: history.length,
    isActive: isActive,
    dayHistory: history,
    lastCheckInDate: lastCheckInDate,
  );
}

void main() {
  group('ActivityEntry', () {
    test('creates entry with all fields', () {
      final entry = ActivityEntry(
        campaignName: 'Running',
        date: DateTime(2026, 4, 1),
        completed: true,
        dayNumber: 5,
        totalDays: 30,
        isPending: false,
      );

      expect(entry.campaignName, equals('Running'));
      expect(entry.date, equals(DateTime(2026, 4, 1)));
      expect(entry.completed, isTrue);
      expect(entry.dayNumber, equals(5));
      expect(entry.totalDays, equals(30));
      expect(entry.isPending, isFalse);
    });

    test('pending defaults to false', () {
      final entry = ActivityEntry(
        campaignName: 'Reading',
        date: DateTime(2026, 4, 1),
        completed: false,
      );

      expect(entry.isPending, isFalse);
    });
  });

  group('Activity Feed Generation', () {
    test('empty campaigns list → empty feed', () {
      final feed = computeFeed([]);
      expect(feed, isEmpty);
    });

    test('inactive campaign with no history → not in feed', () {
      final campaign = _makeCampaign(
        id: '1',
        name: 'Done Campaign',
        history: [],
        totalDays: 30,
        isActive: false,
      );

      final feed = computeFeed([campaign]);
      expect(feed, isEmpty);
    });

    test('active campaign with no history → shows pending entry', () {
      final campaign = _makeCampaign(
        id: '1',
        name: 'New Campaign',
        history: [],
        totalDays: 30,
        isActive: true,
      );
      final today = DateTime(2026, 4, 4);

      final feed = computeFeed([campaign], todayOverride: today);
      expect(feed.length, equals(1));
      expect(feed[0].campaignName, equals('New Campaign'));
      expect(feed[0].date, equals(DateTime(2026, 4, 4)));
      expect(feed[0].completed, isFalse);
      expect(feed[0].isPending, isTrue);
      expect(feed[0].dayNumber, equals(1)); // 0 + 1
      expect(feed[0].totalDays, equals(30));
    });

    test('campaign with 3-day history → generates 3 entries + pending', () {
      final campaign = _makeCampaign(
        id: '1',
        name: 'Running',
        history: [true, false, true],
        totalDays: 30,
        isActive: true,
      );
      final today = DateTime(2026, 4, 4);

      final feed = computeFeed([campaign], todayOverride: today);
      // 3 history entries + 1 pending
      expect(feed.length, equals(4));

      // Most recent is pending (today)
      expect(feed[0].isPending, isTrue);
      expect(feed[0].date, equals(DateTime(2026, 4, 4)));

      // Then history in reverse chronological order
      // anchor = 2026-04-04 - 2 = 2026-04-02 (day 1 date)
      // Day 3 (most recent history): 2026-04-02 (anchor - 0 days back)
      expect(feed[1].completed, isTrue);
      expect(feed[1].dayNumber, equals(3));
      expect(feed[1].date, equals(DateTime(2026, 4, 2)));

      // Day 2: 2026-04-01 (anchor - 1 day back)
      expect(feed[2].completed, isFalse);
      expect(feed[2].dayNumber, equals(2));
      expect(feed[2].date, equals(DateTime(2026, 4, 1)));

      // Day 1: 2026-03-31 (anchor - 2 days back)
      expect(feed[3].completed, isTrue);
      expect(feed[3].dayNumber, equals(1));
      expect(feed[3].date, equals(DateTime(2026, 3, 31)));
    });

    test('inactive campaign with history → no pending entry', () {
      final campaign = _makeCampaign(
        id: '1',
        name: 'Completed Campaign',
        history: [true, true, true],
        totalDays: 3,
        isActive: false,
      );
      final today = DateTime(2026, 4, 4);

      final feed = computeFeed([campaign], todayOverride: today);
      // Only 3 history entries, no pending
      expect(feed.length, equals(3));
      expect(feed.every((e) => !e.isPending), isTrue);
    });

    test('checked in today → no pending entry', () {
      final campaign = _makeCampaign(
        id: '1',
        name: 'Done Today',
        history: [true, true, true],
        totalDays: 30,
        isActive: true,
        lastCheckInDate: '2026-04-04',
      );
      final today = DateTime(2026, 4, 4);

      final feed = computeFeed([campaign], todayOverride: today);
      // Only 3 history entries, no pending (checked in today)
      expect(feed.length, equals(3));
      expect(feed.every((e) => !e.isPending), isTrue);
    });

    test('multiple campaigns → all entries in feed', () {
      final camp1 = _makeCampaign(
        id: '1',
        name: 'Running',
        history: [true, false],
        totalDays: 30,
        isActive: false,
      );
      final camp2 = _makeCampaign(
        id: '2',
        name: 'Reading',
        history: [true],
        totalDays: 21,
        isActive: true,
      );
      final today = DateTime(2026, 4, 4);

      final feed = computeFeed([camp1, camp2], todayOverride: today);
      // Camp1: 2 entries, Camp2: 1 + 1 pending = 4 total
      expect(feed.length, equals(4));

      // Check campaign names are present
      expect(
        feed.map((e) => e.campaignName).toSet(),
        equals({'Running', 'Reading'}),
      );
    });

    test('feed is sorted by date (newest first)', () {
      final camp1 = _makeCampaign(
        id: '1',
        name: 'Camp1',
        history: [true], // day 1
        totalDays: 30,
        isActive: false,
      );
      final camp2 = _makeCampaign(
        id: '2',
        name: 'Camp2',
        history: [true, true], // days 1-2
        totalDays: 30,
        isActive: false,
      );
      final today = DateTime(2026, 4, 4);

      final feed = computeFeed([camp1, camp2], todayOverride: today);

      // Verify sorted by date descending
      for (int i = 0; i < feed.length - 1; i++) {
        expect(
          feed[i].date.isAfter(feed[i + 1].date) ||
              feed[i].date.isAtSameMomentAs(feed[i + 1].date),
          isTrue,
        );
      }
    });

    test('date calculation with lastCheckInDate', () {
      final campaign = _makeCampaign(
        id: '1',
        name: 'Anchored',
        history: [true, true, true],
        totalDays: 30,
        isActive: false,
        lastCheckInDate: '2026-04-10',
      );

      final feed = computeFeed([campaign]);

      // Entries should be anchored to 2026-04-10
      // Day 3 (most recent): 2026-04-10
      expect(feed[0].date, equals(DateTime(2026, 4, 10)));
      // Day 2: 2026-04-09
      expect(feed[1].date, equals(DateTime(2026, 4, 9)));
      // Day 1: 2026-04-08
      expect(feed[2].date, equals(DateTime(2026, 4, 8)));
    });

    test('date calculation without lastCheckInDate (estimated)', () {
      final campaign = _makeCampaign(
        id: '1',
        name: 'Estimated',
        history: [true, true, true],
        totalDays: 30,
        isActive: false,
      );
      final today = DateTime(2026, 4, 10);

      final feed = computeFeed([campaign], todayOverride: today);

      // Should estimate backwards from today
      // anchor = 2026-04-10 - 2 = 2026-04-08 (day 1 date)
      // Day 3: 2026-04-08 (anchor - 0)
      // Day 2: 2026-04-07 (anchor - 1)
      // Day 1: 2026-04-06 (anchor - 2)
      expect(feed[0].date, equals(DateTime(2026, 4, 8)));
      expect(feed[1].date, equals(DateTime(2026, 4, 7)));
      expect(feed[2].date, equals(DateTime(2026, 4, 6)));
    });
  });
}
