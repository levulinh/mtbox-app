import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mtbox_app/models/campaign.dart';
import 'package:mtbox_app/widgets/campaign_card.dart';

void main() {
  group('CampaignCard with custom colors and icons', () {
    testWidgets('renders accent stripe in campaign color',
        (WidgetTester tester) async {
      final campaign = Campaign(
        id: '1',
        name: 'Exercise',
        goal: 'Do 30 workouts',
        totalDays: 30,
        currentDay: 10,
        isActive: true,
        dayHistory: List.filled(10, true),
        colorHex: 'B5735A', // Terracotta
        iconName: 'fitness_center',
      );

      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: GoRouter(routes: [
            GoRoute(
              path: '/',
              builder: (context, state) => Scaffold(
                body: CampaignCard(campaign: campaign),
              ),
            ),
          ]),
        ),
      );

      // Accent stripe is a Container with the campaign color
      final accentStripe = find.byWidgetPredicate(
        (widget) =>
            widget is Container &&
            (widget.decoration as BoxDecoration?)?.color ==
                Color(0xFFB5735A),
      );

      expect(accentStripe, findsWidgets);
    });

    testWidgets('renders 40x40 icon box in campaign color',
        (WidgetTester tester) async {
      final campaign = Campaign(
        id: '1',
        name: 'Exercise',
        goal: 'Do 30 workouts',
        totalDays: 30,
        currentDay: 10,
        isActive: true,
        dayHistory: List.filled(10, true),
        colorHex: '5A8A6E', // Forest
        iconName: 'directions_run',
      );

      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: GoRouter(routes: [
            GoRoute(
              path: '/',
              builder: (context, state) => Scaffold(
                body: CampaignCard(campaign: campaign),
              ),
            ),
          ]),
        ),
      );

      // Icon should be displayed with the specified icon name
      expect(find.byIcon(Icons.directions_run), findsWidgets);

      // Icon should be white
      final whiteIcon = find.byWidgetPredicate(
        (widget) =>
            widget is Icon &&
            widget.icon == Icons.directions_run &&
            widget.color == Colors.white,
      );
      expect(whiteIcon, findsWidgets);
    });

    testWidgets('displays correct icon based on campaign iconName',
        (WidgetTester tester) async {
      final campaign = Campaign(
        id: '1',
        name: 'Reading',
        goal: 'Read 10 books',
        totalDays: 30,
        currentDay: 5,
        isActive: true,
        dayHistory: List.filled(5, true),
        colorHex: '4C6EAD', // Blue
        iconName: 'menu_book',
      );

      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: GoRouter(routes: [
            GoRoute(
              path: '/',
              builder: (context, state) => Scaffold(
                body: CampaignCard(campaign: campaign),
              ),
            ),
          ]),
        ),
      );

      expect(find.byIcon(Icons.menu_book), findsWidgets);
    });

    testWidgets('progress bar uses campaign color', (WidgetTester tester) async {
      final campaign = Campaign(
        id: '1',
        name: 'Exercise',
        goal: 'Do 30 workouts',
        totalDays: 30,
        currentDay: 15,
        isActive: true,
        dayHistory: List.filled(15, true),
        colorHex: '9B6B9B', // Plum
        iconName: 'fitness_center',
      );

      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: GoRouter(routes: [
            GoRoute(
              path: '/',
              builder: (context, state) => Scaffold(
                body: CampaignCard(campaign: campaign),
              ),
            ),
          ]),
        ),
      );

      // Progress bar fill should use campaign color
      final progressFill = find.byWidgetPredicate(
        (widget) =>
            widget is Container &&
            (widget.decoration as BoxDecoration?)?.color ==
                Color(0xFF9B6B9B),
      );

      expect(progressFill, findsWidgets);
    });

    testWidgets('day ticks use campaign color for completed days',
        (WidgetTester tester) async {
      final campaign = Campaign(
        id: '1',
        name: 'Exercise',
        goal: 'Do 30 workouts',
        totalDays: 10,
        currentDay: 5,
        isActive: true,
        dayHistory: [true, true, true, true, true],
        colorHex: 'C4A052', // Amber
        iconName: 'fitness_center',
      );

      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: GoRouter(routes: [
            GoRoute(
              path: '/',
              builder: (context, state) => Scaffold(
                body: CampaignCard(campaign: campaign),
              ),
            ),
          ]),
        ),
      );

      // Completed day ticks should be in campaign color
      // The day tick strip has containers for each day with specific colors
      final campaignColorTicks = find.byWidgetPredicate(
        (widget) =>
            widget is Container &&
            (widget.decoration as BoxDecoration?)?.color ==
                Color(0xFFC4A052),
      );

      expect(campaignColorTicks, findsWidgets);
    });

    testWidgets('default blue campaign renders correctly',
        (WidgetTester tester) async {
      final campaign = Campaign(
        id: '1',
        name: 'Meditation',
        goal: 'Meditate 30 days',
        totalDays: 30,
        currentDay: 1,
        isActive: true,
        dayHistory: [],
        // No colorHex or iconName specified, should use defaults
      );

      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: GoRouter(routes: [
            GoRoute(
              path: '/',
              builder: (context, state) => Scaffold(
                body: CampaignCard(campaign: campaign),
              ),
            ),
          ]),
        ),
      );

      // Default blue color and fitness_center icon
      expect(find.byIcon(Icons.fitness_center), findsWidgets);

      // Blue accent stripe
      final blueStripe = find.byWidgetPredicate(
        (widget) =>
            widget is Container &&
            (widget.decoration as BoxDecoration?)?.color ==
                Color(0xFF4C6EAD),
      );
      expect(blueStripe, findsWidgets);
    });

  });
}
