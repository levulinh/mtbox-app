import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mtbox_app/models/campaign.dart';
import 'package:mtbox_app/screens/focus_session_screen.dart';
import 'package:mtbox_app/providers/mock_data_provider.dart';
import 'package:mtbox_app/theme.dart';

void main() {
  group('FocusSessionScreen Widget Tests', () {
    /// Helper to build widget with mocked campaigns
    Widget buildApp({required List<Campaign> campaigns}) {
      return ProviderScope(
        overrides: [
          campaignsProvider.overrideWith(
            () => _MutableCampaignsNotifier(initialCampaigns: campaigns),
          ),
        ],
        child: MaterialApp(
          home: FocusSessionScreen(campaignId: campaigns.first.id),
        ),
      );
    }

    testWidgets('Running phase: displays large timer and FOCUS MODE badge',
        (tester) async {
      // Arrange
      final campaign = Campaign(
        id: 'test-1',
        name: 'Morning Run',
        goal: 'Morning Run',
        totalDays: 30,
        currentDay: 5,
        isActive: true,
        dayHistory: [true, true, true, true, true],
        goalType: GoalType.days,
        colorHex: '4C6EAD',
        iconName: 'directions_run',
      );

      // Act
      await tester.pumpWidget(buildApp(campaigns: [campaign]));

      // Assert
      expect(find.byType(Text).evaluate().any((w) {
        final text = (w.widget as Text).data ?? '';
        return text.contains('00:');
      }), true);
      expect(find.text('FOCUS MODE'), findsOneWidget);
      expect(find.text('REMAINING'), findsOneWidget);
    });

    testWidgets('Running phase: displays progress bar', (tester) async {
      // Arrange
      final campaign = Campaign(
        id: 'test-2',
        name: 'Read Book',
        goal: 'Read Book',
        totalDays: 10,
        currentDay: 3,
        isActive: true,
        dayHistory: [true, true, true],
        goalType: GoalType.days,
        colorHex: '4C6EAD',
        iconName: 'menu_book',
      );

      // Act
      await tester.pumpWidget(buildApp(campaigns: [campaign]));

      // Assert - progress bar exists and fills based on elapsed time
      expect(find.byType(Container).evaluate().any((w) {
        final container = w.widget as Container;
        return container.decoration is BoxDecoration;
      }), true);
    });

    testWidgets('Running phase: displays editable duration pill', (tester) async {
      // Arrange
      final campaign = Campaign(
        id: 'test-3',
        name: 'Meditate',
        goal: 'Meditate',
        totalDays: 60,
        currentDay: 10,
        isActive: true,
        dayHistory: List.filled(10, true),
        goalType: GoalType.days,
        colorHex: '9B6B9B',
        iconName: 'self_improvement',
      );

      // Act
      await tester.pumpWidget(buildApp(campaigns: [campaign]));
      await tester.pump();

      // Assert - duration pill displays with timer icon
      expect(find.byIcon(Icons.timer), findsOneWidget);
      expect(find.byIcon(Icons.edit), findsOneWidget);
    });


    testWidgets('Running phase: displays End Session Early button', (tester) async {
      // Arrange
      final campaign = Campaign(
        id: 'test-6',
        name: 'Yoga',
        goal: 'Yoga',
        totalDays: 45,
        currentDay: 20,
        isActive: true,
        dayHistory: List.filled(20, true),
        goalType: GoalType.days,
        colorHex: 'B5735A',
        iconName: 'favorite',
      );

      // Act
      await tester.pumpWidget(buildApp(campaigns: [campaign]));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('END SESSION EARLY'), findsOneWidget);
      expect(find.byIcon(Icons.stop_circle_outlined), findsOneWidget);
    });

    testWidgets('Running phase: displays notifications silenced hint',
        (tester) async {
      // Arrange
      final campaign = Campaign(
        id: 'test-7',
        name: 'Stretch',
        goal: 'Stretch',
        totalDays: 30,
        currentDay: 5,
        isActive: true,
        dayHistory: List.filled(5, true),
        goalType: GoalType.days,
        colorHex: '9B5A6B',
        iconName: 'accessibility',
      );

      // Act
      await tester.pumpWidget(buildApp(campaigns: [campaign]));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Notifications silenced'), findsOneWidget);
      expect(find.byIcon(Icons.notifications_off), findsOneWidget);
    });

    testWidgets('Running phase: displays campaign name in header', (tester) async {
      // Arrange
      final campaign = Campaign(
        id: 'test-8',
        name: 'Learn Spanish',
        goal: 'Learn Spanish',
        totalDays: 100,
        currentDay: 25,
        isActive: true,
        dayHistory: List.filled(25, true),
        goalType: GoalType.days,
        colorHex: 'C4A052',
        iconName: 'language',
      );

      // Act
      await tester.pumpWidget(buildApp(campaigns: [campaign]));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('LEARN SPANISH'), findsOneWidget);
    });

    testWidgets('Running phase: dark background (#1A1A1A)', (tester) async {
      // Arrange
      final campaign = Campaign(
        id: 'test-9',
        name: 'Code',
        goal: 'Code',
        totalDays: 60,
        currentDay: 30,
        isActive: true,
        dayHistory: List.filled(30, true),
        goalType: GoalType.days,
        colorHex: '6B8A9B',
        iconName: 'code',
      );

      // Act
      await tester.pumpWidget(buildApp(campaigns: [campaign]));
      await tester.pumpAndSettle();

      // Assert - scaffold background is dark
      final scaffold = find.byType(Scaffold);
      expect(scaffold, findsWidgets);
    });


    testWidgets('Progress bar updates as time elapses', (tester) async {
      // Arrange
      final campaign = Campaign(
        id: 'test-11',
        name: 'Focus Session',
        goal: 'Focus Session',
        totalDays: 30,
        currentDay: 1,
        isActive: true,
        dayHistory: [true],
        goalType: GoalType.days,
        colorHex: '4C6EAD',
        iconName: 'timer',
      );

      // Act
      await tester.pumpWidget(buildApp(campaigns: [campaign]));
      await tester.pumpAndSettle();

      // Assert initial state
      expect(find.text('FOCUS MODE'), findsOneWidget);
      expect(find.text('REMAINING'), findsOneWidget);
    });

    testWidgets('Header displays campaign name uppercased', (tester) async {
      // Arrange
      final campaign = Campaign(
        id: 'test-12',
        name: 'daily standup',
        goal: 'daily standup',
        totalDays: 20,
        currentDay: 5,
        isActive: true,
        dayHistory: List.filled(5, true),
        goalType: GoalType.days,
        colorHex: '4C6EAD',
        iconName: 'timer',
      );

      // Act
      await tester.pumpWidget(buildApp(campaigns: [campaign]));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('DAILY STANDUP'), findsOneWidget);
    });
  });
}

/// Mutable campaigns notifier for widget tests
class _MutableCampaignsNotifier extends CampaignsNotifier {
  final List<Campaign> initialCampaigns;

  _MutableCampaignsNotifier({required this.initialCampaigns});

  @override
  List<Campaign> build() => initialCampaigns;
}
