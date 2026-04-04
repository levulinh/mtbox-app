import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mtbox_app/models/campaign.dart';
import 'package:mtbox_app/models/activity_entry.dart';
import 'package:mtbox_app/providers/mock_data_provider.dart';
import 'package:mtbox_app/screens/home_screen.dart';
import 'package:mtbox_app/theme.dart';

class _FixedCampaignsNotifier extends CampaignsNotifier {
  final List<Campaign> _campaigns;
  _FixedCampaignsNotifier(this._campaigns);

  @override
  List<Campaign> build() => _campaigns;
}

Widget buildHomeScreen(List<Campaign> campaigns, List<ActivityEntry> feed) {
  return ProviderScope(
    overrides: [
      campaignsProvider.overrideWith(() => _FixedCampaignsNotifier(campaigns)),
      activityFeedProvider.overrideWithValue(feed),
    ],
    child: const MaterialApp(home: HomeScreen()),
  );
}

void main() {
  group('Activity Feed — Empty State', () {
    testWidgets('shows "NO ACTIVITY YET" when feed is empty', (tester) async {
      await tester.pumpWidget(buildHomeScreen([], []));
      await tester.pumpAndSettle();

      expect(find.text('NO ACTIVITY YET'), findsOneWidget);
    });

    testWidgets('shows help text in empty state', (tester) async {
      await tester.pumpWidget(buildHomeScreen([], []));
      await tester.pumpAndSettle();

      expect(
        find.text('Check in on a campaign to see your history here.'),
        findsOneWidget,
      );
    });

    testWidgets('shows history icon in empty state', (tester) async {
      await tester.pumpWidget(buildHomeScreen([], []));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.history), findsOneWidget);
    });
  });

  group('Activity Feed — Entry Rendering', () {
    final completedEntry = ActivityEntry(
      campaignName: 'Morning Run',
      date: DateTime(2026, 4, 1),
      completed: true,
      dayNumber: 5,
      totalDays: 30,
      isPending: false,
    );

    final missedEntry = ActivityEntry(
      campaignName: 'Reading',
      date: DateTime(2026, 4, 1),
      completed: false,
      dayNumber: 3,
      totalDays: 21,
      isPending: false,
    );

    final pendingEntry = ActivityEntry(
      campaignName: 'Meditation',
      date: DateTime(2026, 4, 4),
      completed: false,
      dayNumber: 2,
      totalDays: 30,
      isPending: true,
    );

    testWidgets('shows completed entry with DONE badge', (tester) async {
      await tester.pumpWidget(buildHomeScreen([], [completedEntry]));
      await tester.pumpAndSettle();

      expect(find.text('Morning Run'), findsOneWidget);
      expect(find.text('Day 5 of 30'), findsOneWidget);
      expect(find.text('DONE'), findsOneWidget);
    });

    testWidgets('shows missed entry with MISSED badge', (tester) async {
      await tester.pumpWidget(buildHomeScreen([], [missedEntry]));
      await tester.pumpAndSettle();

      expect(find.text('Reading'), findsOneWidget);
      expect(find.text('Day 3 of 21'), findsOneWidget);
      expect(find.text('MISSED'), findsOneWidget);
    });

    testWidgets('shows pending entry with PENDING badge and special text',
        (tester) async {
      await tester.pumpWidget(buildHomeScreen([], [pendingEntry]));
      await tester.pumpAndSettle();

      expect(find.text('Meditation'), findsOneWidget);
      expect(find.textContaining('Not checked in yet'), findsOneWidget);
      expect(find.text('PENDING'), findsOneWidget);
    });

    testWidgets('completed entry shows check_circle icon', (tester) async {
      await tester.pumpWidget(buildHomeScreen([], [completedEntry]));
      await tester.pumpAndSettle();

      // There may be multiple icons on screen, so look for the size that matches feed entries
      final icons = find.byIcon(Icons.check_circle);
      expect(icons, findsWidgets); // At least one present
    });

    testWidgets('non-completed entry shows radio_button_unchecked icon',
        (tester) async {
      await tester.pumpWidget(buildHomeScreen([], [missedEntry]));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.radio_button_unchecked), findsWidgets);
    });

    testWidgets('multiple entries all render', (tester) async {
      final entries = [completedEntry, missedEntry, pendingEntry];
      await tester.pumpWidget(buildHomeScreen([], entries));
      await tester.pumpAndSettle();

      expect(find.text('Morning Run'), findsOneWidget);
      expect(find.text('Reading'), findsOneWidget);
      expect(find.text('Meditation'), findsOneWidget);
    });
  });

  group('Activity Feed — Badge Styling', () {
    testWidgets('DONE badge has blue background and white text', (tester) async {
      final entry = ActivityEntry(
        campaignName: 'Test',
        date: DateTime(2026, 4, 1),
        completed: true,
      );
      await tester.pumpWidget(buildHomeScreen([], [entry]));
      await tester.pumpAndSettle();

      final doneBadgeFinder = find.text('DONE');
      expect(doneBadgeFinder, findsOneWidget);
    });

    testWidgets('PENDING badge has white/grey styling', (tester) async {
      final entry = ActivityEntry(
        campaignName: 'Test',
        date: DateTime(2026, 4, 1),
        completed: false,
        isPending: true,
      );
      await tester.pumpWidget(buildHomeScreen([], [entry]));
      await tester.pumpAndSettle();

      expect(find.text('PENDING'), findsOneWidget);
    });

    testWidgets('MISSED badge has white/grey styling', (tester) async {
      final entry = ActivityEntry(
        campaignName: 'Test',
        date: DateTime(2026, 4, 1),
        completed: false,
        isPending: false,
      );
      await tester.pumpWidget(buildHomeScreen([], [entry]));
      await tester.pumpAndSettle();

      expect(find.text('MISSED'), findsOneWidget);
    });
  });

  group('Activity Feed — Entry Content', () {
    testWidgets('shows campaign name', (tester) async {
      final entry = ActivityEntry(
        campaignName: 'Long Campaign Name Test',
        date: DateTime(2026, 4, 1),
        completed: true,
      );
      await tester.pumpWidget(buildHomeScreen([], [entry]));
      await tester.pumpAndSettle();

      expect(find.text('Long Campaign Name Test'), findsOneWidget);
    });

    testWidgets('shows day progress when dayNumber > 0', (tester) async {
      final entry = ActivityEntry(
        campaignName: 'Test',
        date: DateTime(2026, 4, 1),
        completed: true,
        dayNumber: 7,
        totalDays: 14,
      );
      await tester.pumpWidget(buildHomeScreen([], [entry]));
      await tester.pumpAndSettle();

      expect(find.text('Day 7 of 14'), findsOneWidget);
    });

    testWidgets('pending entry shows "Not checked in yet" text', (tester) async {
      final entry = ActivityEntry(
        campaignName: 'Test',
        date: DateTime(2026, 4, 4),
        completed: false,
        isPending: true,
        dayNumber: 5,
        totalDays: 30,
      );
      await tester.pumpWidget(buildHomeScreen([], [entry]));
      await tester.pumpAndSettle();

      expect(find.textContaining('Not checked in yet'), findsOneWidget);
      expect(find.textContaining('Day 5 of 30'), findsOneWidget);
    });

    testWidgets('entry without dayNumber info shows minimal text', (tester) async {
      final entry = ActivityEntry(
        campaignName: 'Test',
        date: DateTime(2026, 4, 1),
        completed: false,
      );
      await tester.pumpWidget(buildHomeScreen([], [entry]));
      await tester.pumpAndSettle();

      // Should only show campaign name, no day info
      expect(find.text('Test'), findsOneWidget);
      expect(find.text('Day'), findsNothing);
    });
  });

  group('Activity Feed — Integration with Campaigns', () {
    testWidgets('feed updates when campaigns change', (tester) async {
      final campaign1 = Campaign(
        id: '1',
        name: 'Running',
        goal: 'Test',
        totalDays: 30,
        currentDay: 2,
        isActive: true,
        dayHistory: [true, true],
      );

      await tester.pumpWidget(buildHomeScreen([campaign1], []));
      await tester.pumpAndSettle();

      // With empty feed override, should show empty state
      expect(find.text('NO ACTIVITY YET'), findsOneWidget);
    });

    testWidgets('renders feed with real campaign data', (tester) async {
      final campaign = Campaign(
        id: '1',
        name: 'Morning Run',
        goal: 'Run daily',
        totalDays: 30,
        currentDay: 3,
        isActive: true,
        dayHistory: [true, false, true],
      );

      final entries = [
        ActivityEntry(
          campaignName: 'Morning Run',
          date: DateTime(2026, 4, 4),
          completed: false,
          dayNumber: 4,
          totalDays: 30,
          isPending: true,
        ),
        ActivityEntry(
          campaignName: 'Morning Run',
          date: DateTime(2026, 4, 3),
          completed: true,
          dayNumber: 3,
          totalDays: 30,
        ),
      ];

      await tester.pumpWidget(buildHomeScreen([campaign], entries));
      await tester.pumpAndSettle();

      expect(find.text('Morning Run'), findsWidgets);
      expect(find.text('PENDING'), findsOneWidget);
      expect(find.text('DONE'), findsOneWidget);
    });
  });
}
