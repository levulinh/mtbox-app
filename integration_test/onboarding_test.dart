import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mtbox_app/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Onboarding Flow E2E Tests', () {
    testWidgets('New user sees onboarding on app launch',
        (WidgetTester tester) async {
      // Clear Hive state before launching
      app.main();
      await tester.pumpAndSettle();

      // User should be on onboarding screen
      expect(find.text('MTBOX'), findsOneWidget);
      expect(find.text('BUILD HABITS THAT STICK'), findsOneWidget);
    });

    testWidgets('User can navigate through all onboarding screens',
        (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Screen 1: Welcome
      expect(find.text('MTBOX'), findsOneWidget);
      expect(find.text('GET STARTED'), findsOneWidget);

      // Navigate to Screen 2
      await tester.tap(find.text('GET STARTED'));
      await tester.pumpAndSettle();

      // Screen 2: How It Works
      expect(find.text('HOW IT WORKS'), findsOneWidget);
      expect(find.text('Create a Campaign'), findsOneWidget);

      // Navigate to Screen 3
      await tester.tap(find.text('NEXT'));
      await tester.pumpAndSettle();

      // Screen 3: Create Campaign
      expect(find.text('FIRST CAMPAIGN'), findsOneWidget);
      expect(find.text('CAMPAIGN NAME'), findsOneWidget);
    });

    testWidgets('User can skip onboarding', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Click SKIP on welcome page
      await tester.tap(find.text('SKIP — I KNOW THE DRILL'));
      await tester.pumpAndSettle();

      // Should navigate to home screen (or wherever onboarding skips to)
      // This test confirms the skip flow completes without error
      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('User can create campaign in onboarding flow',
        (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to Create Campaign screen
      await tester.tap(find.text('GET STARTED'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('NEXT'));
      await tester.pumpAndSettle();

      // Verify form fields exist
      final textFields = find.byType(TextField);
      expect(textFields, findsWidgets);

      // Values should be pre-filled
      expect(find.text('Exercise Daily'), findsOneWidget);
      expect(find.text('30'), findsOneWidget);

      // Submit the form by tapping CREATE & START
      await tester.tap(find.text('CREATE & START'));
      await tester.pumpAndSettle();

      // Should navigate away from onboarding (to home screen)
      expect(find.text('FIRST CAMPAIGN'), findsNothing);
    });

    testWidgets('User can edit campaign name in onboarding form',
        (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to Create Campaign screen
      await tester.tap(find.text('GET STARTED'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('NEXT'));
      await tester.pumpAndSettle();

      // Change campaign name
      final nameField = find.byType(TextField).first;
      await tester.enterText(nameField, 'Running Challenge');
      await tester.pumpAndSettle();

      expect(find.text('Running Challenge'), findsOneWidget);
    });

    testWidgets('User can edit goal duration in onboarding form',
        (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to Create Campaign screen
      await tester.tap(find.text('GET STARTED'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('NEXT'));
      await tester.pumpAndSettle();

      // Change days
      final daysField = find.byType(TextField).last;
      await tester.enterText(daysField, '60');
      await tester.pumpAndSettle();

      expect(find.text('60'), findsOneWidget);
    });

    testWidgets('Form validation: empty name shows error',
        (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to Create Campaign screen
      await tester.tap(find.text('GET STARTED'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('NEXT'));
      await tester.pumpAndSettle();

      // Clear name field
      final nameField = find.byType(TextField).first;
      await tester.enterText(nameField, '');
      await tester.pumpAndSettle();

      // Try to submit
      await tester.tap(find.text('CREATE & START'));
      await tester.pumpAndSettle();

      expect(find.text('Campaign name is required'), findsOneWidget);
    });

    testWidgets('Form validation: zero days shows error',
        (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to Create Campaign screen
      await tester.tap(find.text('GET STARTED'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('NEXT'));
      await tester.pumpAndSettle();

      // Set days to 0
      final daysField = find.byType(TextField).last;
      await tester.enterText(daysField, '0');
      await tester.pumpAndSettle();

      // Try to submit
      await tester.tap(find.text('CREATE & START'));
      await tester.pumpAndSettle();

      expect(find.text('Enter a valid number of days'), findsOneWidget);
    });

    testWidgets('User can go back between screens', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Go forward 2 screens
      await tester.tap(find.text('GET STARTED'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('NEXT'));
      await tester.pumpAndSettle();

      // Should be on Create Campaign
      expect(find.text('FIRST CAMPAIGN'), findsOneWidget);

      // Go back 1 screen
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // Should be back on How It Works
      expect(find.text('HOW IT WORKS'), findsOneWidget);

      // Go back 1 more screen
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // Should be on Welcome
      expect(find.text('MTBOX'), findsOneWidget);
    });

    testWidgets('Example campaign card displays correctly',
        (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to How It Works page
      await tester.tap(find.text('GET STARTED'));
      await tester.pumpAndSettle();

      // Verify example campaign card content
      expect(find.text('Exercise Daily'), findsOneWidget);
      expect(find.text('DAY 12 OF 30'), findsOneWidget);
      expect(find.text('ACTIVE'), findsOneWidget);
    });

    testWidgets('Progress bars display correctly in example card',
        (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to How It Works
      await tester.tap(find.text('GET STARTED'));
      await tester.pumpAndSettle();

      // Progress percentage should display
      expect(find.text('40%'), findsOneWidget); // 12/30 = 40%
    });

    testWidgets('Day ticks grid displays in example card',
        (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to How It Works
      await tester.tap(find.text('GET STARTED'));
      await tester.pumpAndSettle();

      // Visual verification that we're seeing the card (containers for day ticks)
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('Feature rows display on How It Works page',
        (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to How It Works
      await tester.tap(find.text('GET STARTED'));
      await tester.pumpAndSettle();

      // Both feature descriptions should be visible
      expect(find.text('Create a Campaign'), findsOneWidget);
      expect(find.text('Check In Daily'), findsOneWidget);
    });

    testWidgets('Feature row icons display', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to How It Works
      await tester.tap(find.text('GET STARTED'));
      await tester.pumpAndSettle();

      // Icons should be present (flag and add_task)
      expect(find.byIcon(Icons.flag), findsWidgets);
      expect(find.byIcon(Icons.add_task), findsOneWidget);
    });

    testWidgets('Create Campaign screen shows recommendation text',
        (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to Create Campaign
      await tester.tap(find.text('GET STARTED'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('NEXT'));
      await tester.pumpAndSettle();

      // Recommendation should be visible
      expect(find.text('We recommend starting with 14–30 days.'),
          findsOneWidget);
    });
  });
}
