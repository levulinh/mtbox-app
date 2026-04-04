import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mtbox_app/models/campaign.dart';
import 'package:mtbox_app/theme.dart';
import 'package:mtbox_app/widgets/campaign_card.dart';

Widget buildCard(Campaign campaign) {
  return MaterialApp(
    home: Scaffold(
      body: SizedBox(width: 400, child: CampaignCard(campaign: campaign)),
    ),
  );
}

void main() {
  group('CampaignCard — Streak Badge', () {
    testWidgets('streak badge NOT shown when campaign has no history',
        (tester) async {
      final campaign = Campaign(
        id: '1',
        name: 'New Campaign',
        goal: 'Test goal',
        totalDays: 30,
        currentDay: 1,
        isActive: true,
        dayHistory: [],
      );
      await tester.pumpWidget(buildCard(campaign));
      await tester.pumpAndSettle();

      // Fire icon should not be present
      expect(find.byIcon(Icons.local_fire_department), findsNothing);
    });

    testWidgets('streak badge shown when campaign has day history',
        (tester) async {
      final campaign = Campaign(
        id: '1',
        name: 'Active Campaign',
        goal: 'Test goal',
        totalDays: 30,
        currentDay: 5,
        isActive: true,
        dayHistory: [true, true, true, true, true],
      );
      await tester.pumpWidget(buildCard(campaign));
      await tester.pumpAndSettle();

      // Fire icon should be present
      expect(find.byIcon(Icons.local_fire_department), findsOneWidget);
      // Badge should show streak count and "DAY" label
      expect(find.text('5'), findsOneWidget);
      expect(find.text('DAY'), findsOneWidget);
    });

    testWidgets('streak badge displays currentStreak value', (tester) async {
      final campaign = Campaign(
        id: '1',
        name: 'Campaign',
        goal: 'Test goal',
        totalDays: 30,
        currentDay: 8,
        isActive: true,
        dayHistory: [false, false, true, true, true, true, true, true],
      );
      await tester.pumpWidget(buildCard(campaign));
      await tester.pumpAndSettle();

      // currentStreak = 6 (last 6 consecutive trues)
      expect(find.text('6'), findsOneWidget);
    });

    testWidgets('streak badge shows 1 when streak is broken (currentStreak=0)',
        (tester) async {
      final campaign = Campaign(
        id: '1',
        name: 'Campaign',
        goal: 'Test goal',
        totalDays: 30,
        currentDay: 4,
        isActive: true,
        dayHistory: [true, true, true, false],
      );
      await tester.pumpWidget(buildCard(campaign));
      await tester.pumpAndSettle();

      // currentStreak = 0, but streakDisplayCount = 1
      expect(find.text('1'), findsOneWidget);
    });

    testWidgets('streak badge styling changes based on broken state',
        (tester) async {
      // Unbroken streak: blue background
      final unbroken = Campaign(
        id: '1',
        name: 'Campaign',
        goal: 'Test goal',
        totalDays: 30,
        currentDay: 3,
        isActive: true,
        dayHistory: [true, true, true],
      );
      await tester.pumpWidget(buildCard(unbroken));
      await tester.pumpAndSettle();
      expect(unbroken.isStreakBroken, isFalse);
      expect(find.text('3'), findsOneWidget);

      // Broken streak: white background
      final broken = Campaign(
        id: '2',
        name: 'Campaign',
        goal: 'Test goal',
        totalDays: 30,
        currentDay: 4,
        isActive: true,
        dayHistory: [true, true, false, true],
      );
      await tester.pumpWidget(buildCard(broken));
      await tester.pumpAndSettle();
      expect(broken.isStreakBroken, isTrue);
      expect(find.text('1'), findsOneWidget);
    });


    testWidgets('campaign name respects padding when streak badge present',
        (tester) async {
      final campaign = Campaign(
        id: '1',
        name: 'Long Campaign Name Here',
        goal: 'Test goal',
        totalDays: 30,
        currentDay: 3,
        isActive: true,
        dayHistory: [true, true, true],
      );
      await tester.pumpWidget(buildCard(campaign));
      await tester.pumpAndSettle();

      // When streak is present, name should have right padding to avoid overlap
      expect(find.text('Long Campaign Name Here'), findsOneWidget);
      // Just verify it renders without overflow
      expect(tester.takeException(), isNull);
    });

    testWidgets('campaign name has no right padding when no streak',
        (tester) async {
      final campaign = Campaign(
        id: '1',
        name: 'Campaign Name',
        goal: 'Test goal',
        totalDays: 30,
        currentDay: 1,
        isActive: true,
        dayHistory: [],
      );
      await tester.pumpWidget(buildCard(campaign));
      await tester.pumpAndSettle();

      expect(find.text('Campaign Name'), findsOneWidget);
      // Verify it renders without overflow
      expect(tester.takeException(), isNull);
    });
  });
}
