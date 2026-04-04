import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mtbox_app/main.dart';
import 'package:mtbox_app/models/campaign.dart';
import 'package:mtbox_app/models/activity_entry.dart';
import 'package:mtbox_app/providers/mock_data_provider.dart';
import 'package:mtbox_app/widgets/campaign_card.dart';
import 'package:mtbox_app/widgets/stat_card.dart';
import 'package:mtbox_app/widgets/activity_item.dart';

// Override that bypasses Hive so MTBoxApp boots cleanly in widget tests.
class _FixedCampaignsNotifier extends CampaignsNotifier {
  @override
  List<Campaign> build() => const [
        Campaign(id: '1', name: 'Morning Run', goal: 'Run 30 days', totalDays: 30, currentDay: 18, isActive: true, dayHistory: []),
        Campaign(id: '2', name: 'Daily Reading', goal: 'Read 21 days', totalDays: 21, currentDay: 21, isActive: false, dayHistory: []),
        Campaign(id: '3', name: 'No Sugar', goal: 'Avoid 14 days', totalDays: 14, currentDay: 7, isActive: true, dayHistory: []),
        Campaign(id: '4', name: 'Meditation', goal: 'Meditate 30 days', totalDays: 30, currentDay: 5, isActive: true, dayHistory: []),
      ];
}

Widget buildApp() {
  return ProviderScope(
    overrides: [
      campaignsProvider.overrideWith(() => _FixedCampaignsNotifier()),
    ],
    child: const MTBoxApp(initialLocation: '/'),
  );
}

void main() {
  group('CampaignCard', () {
    Widget buildCard(Campaign campaign) {
      return MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 400,
            child: CampaignCard(campaign: campaign),
          ),
        ),
      );
    }

    final activeCampaign = Campaign(
      id: '1',
      name: 'Morning Run',
      goal: 'Run every day for 30 days',
      totalDays: 30,
      currentDay: 18,
      isActive: true,
      dayHistory: List.generate(18, (i) => true),
    );

    final completedCampaign = Campaign(
      id: '2',
      name: 'Daily Reading',
      goal: 'Read 20 pages per day for 21 days',
      totalDays: 21,
      currentDay: 21,
      isActive: false,
      dayHistory: List.generate(21, (i) => true),
    );

    testWidgets('shows campaign name', (tester) async {
      await tester.pumpWidget(buildCard(activeCampaign));
      expect(find.text('Morning Run'), findsOneWidget);
    });

    testWidgets('shows campaign goal', (tester) async {
      await tester.pumpWidget(buildCard(activeCampaign));
      expect(find.text('Run every day for 30 days'), findsOneWidget);
    });

    testWidgets('shows day progress text', (tester) async {
      await tester.pumpWidget(buildCard(activeCampaign));
      expect(find.text('DAY 18 OF 30'), findsOneWidget);
    });

    testWidgets('shows percentage', (tester) async {
      await tester.pumpWidget(buildCard(activeCampaign));
      expect(find.text('60%'), findsOneWidget);
    });

    testWidgets('shows ACTIVE badge for active campaign', (tester) async {
      await tester.pumpWidget(buildCard(activeCampaign));
      expect(find.text('ACTIVE'), findsOneWidget);
    });

    testWidgets('shows DONE badge for completed campaign', (tester) async {
      await tester.pumpWidget(buildCard(completedCampaign));
      expect(find.text('DONE'), findsOneWidget);
    });

    testWidgets('shows 100% for completed campaign', (tester) async {
      await tester.pumpWidget(buildCard(completedCampaign));
      expect(find.text('100%'), findsOneWidget);
    });

    testWidgets('shows DAY 21 OF 21 for completed campaign', (tester) async {
      await tester.pumpWidget(buildCard(completedCampaign));
      expect(find.text('DAY 21 OF 21'), findsOneWidget);
    });
  });

  group('StatCard', () {
    Widget buildStatCard({
      required String label,
      required String value,
      required IconData icon,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: Row(
            children: [
              StatCard(label: label, value: value, icon: icon),
            ],
          ),
        ),
      );
    }

    testWidgets('shows value', (tester) async {
      await tester.pumpWidget(
        buildStatCard(label: 'Total', value: '4', icon: Icons.flag),
      );
      expect(find.text('4'), findsOneWidget);
    });

    testWidgets('shows label in uppercase', (tester) async {
      await tester.pumpWidget(
        buildStatCard(label: 'Total', value: '4', icon: Icons.flag),
      );
      expect(find.text('TOTAL'), findsOneWidget);
    });

    testWidgets('shows streak with d suffix', (tester) async {
      await tester.pumpWidget(
        buildStatCard(
          label: 'Best Streak',
          value: '7d',
          icon: Icons.local_fire_department,
        ),
      );
      expect(find.text('7d'), findsOneWidget);
      expect(find.text('BEST STREAK'), findsOneWidget);
    });
  });

  group('ActivityItem', () {
    Widget buildItem(ActivityEntry entry) {
      return MaterialApp(
        home: Scaffold(
          body: ActivityItem(entry: entry),
        ),
      );
    }

    testWidgets('shows campaign name for completed entry', (tester) async {
      final entry = ActivityEntry(
        campaignName: 'Morning Run',
        date: DateTime.now().subtract(const Duration(hours: 2)),
        completed: true,
      );
      await tester.pumpWidget(buildItem(entry));
      expect(find.text('Morning Run'), findsOneWidget);
    });

    testWidgets('shows DONE badge for completed entry', (tester) async {
      final entry = ActivityEntry(
        campaignName: 'Morning Run',
        date: DateTime.now().subtract(const Duration(hours: 2)),
        completed: true,
      );
      await tester.pumpWidget(buildItem(entry));
      expect(find.text('DONE'), findsOneWidget);
    });

    testWidgets('shows MISSED badge for incomplete entry', (tester) async {
      final entry = ActivityEntry(
        campaignName: 'Meditation',
        date: DateTime.now().subtract(const Duration(days: 1)),
        completed: false,
      );
      await tester.pumpWidget(buildItem(entry));
      expect(find.text('MISSED'), findsOneWidget);
    });

    testWidgets('shows relative time for recent entry', (tester) async {
      final entry = ActivityEntry(
        campaignName: 'No Sugar',
        date: DateTime.now().subtract(const Duration(hours: 3)),
        completed: true,
      );
      await tester.pumpWidget(buildItem(entry));
      expect(find.text('3h ago'), findsOneWidget);
    });

    testWidgets('shows Yesterday for 1-day-old entry', (tester) async {
      final entry = ActivityEntry(
        campaignName: 'Meditation',
        date: DateTime.now().subtract(const Duration(hours: 25)),
        completed: false,
      );
      await tester.pumpWidget(buildItem(entry));
      expect(find.text('Yesterday'), findsOneWidget);
    });
  });

  group('App shell navigation', () {
    testWidgets('home tab shows greeting and stats', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      // HEY DREW is in a RichText inside FlexibleSpaceBar — use findRichText: true
      expect(find.text('HEY DREW', findRichText: true), findsOneWidget);
      expect(find.text('RECENT ACTIVITY'), findsOneWidget);
    });

    testWidgets('bottom nav has HOME, CAMPAIGNS, PROFILE tabs', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      expect(find.text('HOME'), findsOneWidget);
      expect(find.text('CAMPAIGNS'), findsWidgets);
      expect(find.text('PROFILE'), findsWidgets);
    });

    testWidgets('tapping CAMPAIGNS tab shows campaigns screen', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      // Tap the CAMPAIGNS nav item (in the bottom nav bar)
      // Tap by text directly in nav
      await tester.tap(find.text('CAMPAIGNS').last);
      await tester.pumpAndSettle();

      expect(find.text('Morning Run'), findsOneWidget);
    });

    testWidgets('tapping PROFILE tab shows profile screen', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text('PROFILE').last);
      await tester.pumpAndSettle();

      expect(find.text('DREW'), findsWidgets);
      expect(find.text('Total Completed'), findsOneWidget);
    });

    testWidgets('tapping HOME tab returns to home screen', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text('CAMPAIGNS').last);
      await tester.pumpAndSettle();

      await tester.tap(find.text('HOME').last);
      await tester.pumpAndSettle();

      // HEY DREW is in RichText; confirm home via RECENT ACTIVITY section header
      expect(find.text('RECENT ACTIVITY'), findsOneWidget);
    });
  });
}
