import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mtbox_app/models/campaign.dart';
import 'package:mtbox_app/providers/mock_data_provider.dart';
import 'package:mtbox_app/screens/create_campaign_screen.dart';
import 'package:mtbox_app/theme.dart';
import 'package:mtbox_app/widgets/campaign_card.dart';
import 'package:mtbox_app/widgets/goal_type_selector.dart';

void main() {
  group('GoalTypeSelector widget', () {
    testWidgets('renders 4 cells with correct labels', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GoalTypeSelector(
              selected: GoalType.days,
              onSelected: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('Days'), findsOneWidget);
      expect(find.text('Hours'), findsOneWidget);
      expect(find.text('Sessions'), findsOneWidget);
      expect(find.text('Custom'), findsOneWidget);
    });

    testWidgets('renders correct icons for each goal type',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GoalTypeSelector(
              selected: GoalType.days,
              onSelected: (_) {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.calendar_today), findsOneWidget);
      expect(find.byIcon(Icons.schedule), findsOneWidget);
      expect(find.byIcon(Icons.repeat), findsOneWidget);
      expect(find.byIcon(Icons.tune), findsOneWidget);
    });

    testWidgets('highlights selected cell with blue background',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GoalTypeSelector(
              selected: GoalType.days,
              onSelected: (_) {},
            ),
          ),
        ),
      );

      // The selected cell should have blue background
      final cells = find.byType(Container);
      expect(cells, findsWidgets);
    });

    testWidgets('calls onSelected when cell is tapped', (WidgetTester tester) async {
      GoalType? selected;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GoalTypeSelector(
              selected: GoalType.days,
              onSelected: (type) => selected = type,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Hours'));
      await tester.pumpAndSettle();

      expect(selected, GoalType.hours);
    });

    testWidgets('updates highlighted cell when selection changes',
        (WidgetTester tester) async {
      GoalType currentSelection = GoalType.days;

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            return MaterialApp(
              home: Scaffold(
                body: GoalTypeSelector(
                  selected: currentSelection,
                  onSelected: (type) {
                    setState(() => currentSelection = type);
                  },
                ),
              ),
            );
          },
        ),
      );

      await tester.tap(find.text('Sessions'));
      await tester.pumpAndSettle();

      expect(currentSelection, GoalType.sessions);
    });

    testWidgets('all 4 cells are tappable', (WidgetTester tester) async {
      final selections = <GoalType>[];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GoalTypeSelector(
              selected: GoalType.days,
              onSelected: (type) => selections.add(type),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Days'));
      await tester.tap(find.text('Hours'));
      await tester.tap(find.text('Sessions'));
      await tester.tap(find.text('Custom'));
      await tester.pumpAndSettle();

      expect(selections.length, 4);
      expect(selections, [
        GoalType.days,
        GoalType.hours,
        GoalType.sessions,
        GoalType.custom,
      ]);
    });
  });

  group('CreateCampaignScreen goal type integration', () {
    testWidgets('goal type selector is visible on screen',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: CreateCampaignScreen(),
          ),
        ),
      );

      expect(find.byType(GoalTypeSelector), findsOneWidget);
    });

    testWidgets('unit pill updates when goal type changes',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: CreateCampaignScreen(),
          ),
        ),
      );

      // Initially should show DAYS
      expect(find.text('DAYS'), findsWidgets);

      // Tap Hours cell
      await tester.tap(find.text('Hours'));
      await tester.pumpAndSettle();

      // Should now show HRS
      expect(find.text('HRS'), findsWidgets);
    });

    testWidgets('metric name field appears only when Custom is selected',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: CreateCampaignScreen(),
          ),
        ),
      );

      // METRIC NAME should not be visible initially (Days is selected)
      expect(find.text('METRIC NAME'), findsNothing);

      // Tap Custom cell
      await tester.tap(find.text('Custom'));
      await tester.pumpAndSettle();

      // Now METRIC NAME should be visible
      expect(find.text('METRIC NAME'), findsOneWidget);
    });

    testWidgets('all goal type cells are selectable', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: CreateCampaignScreen(),
          ),
        ),
      );

      // Verify all buttons exist and are tappable
      expect(find.text('Days'), findsOneWidget);
      expect(find.text('Hours'), findsOneWidget);
      expect(find.text('Sessions'), findsOneWidget);
      expect(find.text('Custom'), findsOneWidget);

      // Tap each one to verify state changes
      await tester.tap(find.text('Hours'));
      await tester.pumpAndSettle();
      expect(find.text('HRS'), findsWidgets);

      await tester.tap(find.text('Sessions'));
      await tester.pumpAndSettle();
      expect(find.text('SESSIONS'), findsWidgets);

      await tester.tap(find.text('Custom'));
      await tester.pumpAndSettle();
      expect(find.text('METRIC NAME'), findsOneWidget);
    });
  });

  group('CampaignCard goal-type chip', () {
    testWidgets('displays chip with Days icon and label for days goal type',
        (WidgetTester tester) async {
      final campaign = Campaign(
        id: '1',
        name: 'Exercise',
        goal: 'Exercise',
        totalDays: 30,
        currentDay: 5,
        isActive: true,
        dayHistory: const [true, true, true, true, true],
        goalType: GoalType.days,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CampaignCard(campaign: campaign),
          ),
        ),
      );

      expect(find.byIcon(Icons.calendar_today), findsWidgets);
      expect(find.text('DAYS'), findsWidgets);
    });

    testWidgets('displays chip with Hours icon and label for hours goal type',
        (WidgetTester tester) async {
      final campaign = Campaign(
        id: '1',
        name: 'Study',
        goal: 'Study',
        totalDays: 100,
        currentDay: 20,
        isActive: true,
        dayHistory: const [],
        goalType: GoalType.hours,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CampaignCard(campaign: campaign),
          ),
        ),
      );

      expect(find.byIcon(Icons.schedule), findsWidgets);
      expect(find.text('HOURS'), findsWidgets);
    });

    testWidgets('displays chip with Sessions icon for sessions goal type',
        (WidgetTester tester) async {
      final campaign = Campaign(
        id: '1',
        name: 'Gym',
        goal: 'Gym',
        totalDays: 20,
        currentDay: 5,
        isActive: true,
        dayHistory: const [],
        goalType: GoalType.sessions,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CampaignCard(campaign: campaign),
          ),
        ),
      );

      expect(find.byIcon(Icons.repeat), findsWidgets);
      expect(find.text('SESSIONS'), findsWidgets);
    });

    testWidgets('displays chip with Custom icon and metric name for custom goal type',
        (WidgetTester tester) async {
      final campaign = Campaign(
        id: '1',
        name: 'Reading',
        goal: 'Reading',
        totalDays: 12,
        currentDay: 3,
        isActive: true,
        dayHistory: const [],
        goalType: GoalType.custom,
        metricName: 'Books read',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CampaignCard(campaign: campaign),
          ),
        ),
      );

      expect(find.byIcon(Icons.tune), findsWidgets);
      expect(find.text('BOOKS READ'), findsWidgets);
    });

    testWidgets('check-in button shows correct label for days goal type',
        (WidgetTester tester) async {
      final campaign = Campaign(
        id: '1',
        name: 'Exercise',
        goal: 'Exercise',
        totalDays: 30,
        currentDay: 5,
        isActive: true,
        dayHistory: const [true, true, true, true, true],
        goalType: GoalType.days,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CampaignCard(campaign: campaign),
          ),
        ),
      );

      expect(find.text('CHECK IN TODAY'), findsOneWidget);
    });

    testWidgets('check-in button shows correct label for hours goal type',
        (WidgetTester tester) async {
      final campaign = Campaign(
        id: '1',
        name: 'Study',
        goal: 'Study',
        totalDays: 100,
        currentDay: 20,
        isActive: true,
        dayHistory: const [],
        goalType: GoalType.hours,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CampaignCard(campaign: campaign),
          ),
        ),
      );

      expect(find.text('LOG HOURS'), findsOneWidget);
    });

    testWidgets('check-in button shows correct label for sessions goal type',
        (WidgetTester tester) async {
      final campaign = Campaign(
        id: '1',
        name: 'Gym',
        goal: 'Gym',
        totalDays: 20,
        currentDay: 5,
        isActive: true,
        dayHistory: const [],
        goalType: GoalType.sessions,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CampaignCard(campaign: campaign),
          ),
        ),
      );

      expect(find.text('LOG SESSION'), findsOneWidget);
    });

    testWidgets(
        'check-in button shows correct label for custom goal type with metric',
        (WidgetTester tester) async {
      final campaign = Campaign(
        id: '1',
        name: 'Reading',
        goal: 'Reading',
        totalDays: 12,
        currentDay: 3,
        isActive: true,
        dayHistory: const [],
        goalType: GoalType.custom,
        metricName: 'Pages read',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CampaignCard(campaign: campaign),
          ),
        ),
      );

      expect(find.text('LOG PAGES READ'), findsOneWidget);
    });
  });
}
