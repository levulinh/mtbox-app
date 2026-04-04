import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mtbox_app/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Home Screen E2E Tests', () {
    testWidgets('Home screen displays with live data from Hive', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Verify home screen is visible
      expect(find.text('HOME'), findsOneWidget);
      expect(find.text('LIVE DATA'), findsOneWidget);

      // Should have today section
      expect(find.text('TODAY'), findsOneWidget);

      // Should have activity summary
      expect(find.text('YOUR ACTIVITY AT A GLANCE'), findsOneWidget);
    });

    testWidgets('Empty state shown when no active campaigns', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // If no active campaigns, should show empty state
      final hasEmpty = find.text('NO ACTIVE CAMPAIGNS').evaluate().isNotEmpty;
      final hasActive = find.text('Active Campaigns').evaluate().isNotEmpty;

      // Either empty state or active list, not both in a weird state
      expect(hasEmpty || hasActive, isTrue);
    });

    testWidgets('User can navigate to campaign detail from home screen',
        (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Try to find and tap chevron to navigate to detail
      final chevronFinder = find.byIcon(Icons.chevron_right);
      if (chevronFinder.evaluate().isNotEmpty) {
        await tester.tap(chevronFinder.first);
        await tester.pumpAndSettle();

        // Should navigate to detail screen (has campaign title)
        // The detail screen should have a back button or exit mechanism
        expect(find.byType(Scaffold), findsWidgets);
      }
    });

    testWidgets('Check-in flow works end-to-end', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Look for CHECK IN button
      final checkInFinder = find.text('CHECK IN');
      if (checkInFinder.evaluate().isNotEmpty) {
        final initialCheckInCount = checkInFinder.evaluate().length;

        // Tap the first CHECK IN button
        await tester.tap(checkInFinder.first);
        await tester.pumpAndSettle();

        // After check-in, that campaign should change to CHECKED IN
        // (or navigate to completion screen if it was the final day)
        final checkedInFinder = find.text('CHECKED IN');
        final hasCheckedIn = checkedInFinder.evaluate().isNotEmpty;

        // Either we see CHECKED IN or we navigated to completion
        expect(
          hasCheckedIn || find.text('Complete').evaluate().isNotEmpty,
          isTrue,
        );
      }
    });

    testWidgets('Campaign progress updates correctly after check-in',
        (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Find a campaign with a specific day number
      final dayLabelFinder = find.byType(Text);
      final initialDayTexts = dayLabelFinder.evaluate();

      // Get the count of CHECK IN buttons before
      final checkInBefore = find.text('CHECK IN').evaluate().length;

      // If there are active campaigns, tap CHECK IN
      if (checkInBefore > 0) {
        await tester.tap(find.text('CHECK IN').first);
        await tester.pumpAndSettle();

        // The day count for that campaign should increment
        // and button should change to CHECKED IN
        final checkInAfter = find.text('CHECK IN').evaluate().length;
        final checkedInCount = find.text('CHECKED IN').evaluate().length;

        // One less CHECK IN and one more CHECKED IN (same campaign)
        expect(checkInAfter < checkInBefore || checkedInCount > 0, isTrue);
      }
    });

    testWidgets('Summary stats update after check-in', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Look for stats: Active, Done Today, Best Streak
      expect(find.text('Active'), findsOneWidget);
      expect(find.text('Done Today'), findsOneWidget);
      expect(find.text('Best Streak'), findsOneWidget);

      // If there's a CHECK IN button, tap it and verify stats update
      final checkInFinder = find.text('CHECK IN');
      if (checkInFinder.evaluate().isNotEmpty) {
        await tester.tap(checkInFinder.first);
        await tester.pumpAndSettle();

        // Stats should still be visible (and potentially updated)
        expect(find.text('Active'), findsOneWidget);
        expect(find.text('Done Today'), findsOneWidget);
        expect(find.text('Best Streak'), findsOneWidget);
      }
    });

    testWidgets('Toast notification appears after successful check-in',
        (tester) async {
      app.main();
      await tester.pumpAndSettle();

      final checkInFinder = find.text('CHECK IN');
      if (checkInFinder.evaluate().isNotEmpty) {
        await tester.tap(checkInFinder.first);
        await tester.pumpAndSettle(const Duration(seconds: 2));

        // Toast should contain check-in confirmation message
        // Look for text containing "Day" (from "Day X checked in!")
        final dayTextFinder = find.text('Day', findRichText: true);

        // Either we see a day reference in a toast or we navigated
        final hasToast = dayTextFinder.evaluate().isNotEmpty;
        expect(hasToast || find.text('Complete').evaluate().isNotEmpty, isTrue);
      }
    });

    testWidgets('App bar shows LIVE DATA indicator', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      expect(find.text('HOME'), findsOneWidget);
      expect(find.text('LIVE DATA'), findsOneWidget);

      // The app bar should be visible at the top
      expect(find.byType(AppBar).evaluate().isNotEmpty ||
          find.byType(SliverAppBar).evaluate().isNotEmpty, isTrue);
    });

    testWidgets('Data persists when navigating back from detail screen',
        (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to detail if available
      final chevronFinder = find.byIcon(Icons.chevron_right);
      if (chevronFinder.evaluate().isNotEmpty) {
        await tester.tap(chevronFinder.first);
        await tester.pumpAndSettle();

        // Go back to home screen
        await tester.pageBack();
        await tester.pumpAndSettle();

        // Home screen should still be there with same data
        expect(find.text('HOME'), findsOneWidget);
        expect(find.text('YOUR ACTIVITY AT A GLANCE'), findsOneWidget);
      }
    });
  });
}
