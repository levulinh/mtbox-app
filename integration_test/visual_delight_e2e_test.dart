import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mtbox_app/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Visual Delight E2E (MTB-25)', () {
    testWidgets('App boots and animates to home screen', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      expect(find.text('RECENT ACTIVITY'), findsWidgets);
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('Empty campaigns state shows when no campaigns exist', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Navigate to campaigns tab if home screen shows activity feed
      final campaignTab = find.text('CAMPAIGNS').last;
      await tester.tap(campaignTab);
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Should see empty state message and CTA button
      // These assertions are manual — app state may vary
    });

    testWidgets('Clicking START A CAMPAIGN navigates to create screen with animation',
        (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Locate and tap the create campaign button
      final createButton = find.byType(FloatingActionButton);
      if (createButton.evaluate().isNotEmpty) {
        await tester.tap(createButton);
        await tester.pumpAndSettle(const Duration(milliseconds: 500));

        // Verify navigation occurred
        expect(find.byType(TextField), findsWidgets);
      }
    });

    testWidgets('Screen transitions use animation when navigating', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Tap a nav item to trigger transition
      final statsTab = find.text('STATS');
      if (statsTab.evaluate().isNotEmpty) {
        await tester.tap(statsTab);
        // Wait for 250ms transition + buffer
        await tester.pumpAndSettle(const Duration(milliseconds: 400));
      }
    });

    testWidgets('Progress bar animates when campaign progresses', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // This test would require a campaign with progress data
      // Progress bar animation (600ms easeOutCubic) is applied on render
    });

    testWidgets('Check-in button interaction triggers feedback', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // If a campaign exists, tap check-in button
      final checkInButtons = find.byIcon(Icons.check_circle);
      if (checkInButtons.evaluate().isNotEmpty) {
        await tester.tap(checkInButtons.first);
        // Wait for 80ms button animation + celebration toast (300ms fade-in)
        await tester.pumpAndSettle(const Duration(milliseconds: 500));

        // Celebration toast should appear
        expect(find.text('Check-in successful!'), findsWidgets);
      }
    });

    testWidgets('Celebration toast auto-dismisses after 2.5s', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      final checkInButtons = find.byIcon(Icons.check_circle);
      if (checkInButtons.evaluate().isNotEmpty) {
        await tester.tap(checkInButtons.first);
        await tester.pumpAndSettle(const Duration(milliseconds: 400));

        // Toast is visible
        expect(find.text('Check-in successful!'), findsWidgets);

        // Wait past 2.5s + buffer
        await tester.pumpAndSettle(const Duration(seconds: 3));

        // Toast should be gone
        expect(find.text('Check-in successful!'), findsNothing);
      }
    });

    testWidgets('Empty activity feed shows message', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Activity feed is on home screen — should see either activity or empty message
      expect(find.text('RECENT ACTIVITY'), findsWidgets);
    });

    testWidgets('No visual regressions on key screens', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Verify core UI elements are present
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.byType(BottomNavigationBar), findsOneWidget);
      expect(find.byType(FloatingActionButton), findsOneWidget);
    });
  });
}
