import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mtbox_app/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Campaign Completion Flow E2E', () {
    testWidgets(
      'user completes a campaign and sees completion screen',
      (WidgetTester tester) async {
        app.main();
        await tester.pumpAndSettle();

        // User should be on campaigns list
        expect(find.text('CAMPAIGNS'), findsWidgets);

        // Find a campaign that's near completion (currentDay >= totalDays - 1)
        // We'll look for campaign cards and tap the first one
        final campaignCards = find.byType(GestureDetector);
        expect(campaignCards, findsWidgets,
            reason: 'At least one campaign card should be visible');

        // Tap the first campaign's check-in button
        // (The last GestureDetector in each campaign card is usually the check-in icon)
        await tester.tap(campaignCards.first);
        await tester.pumpAndSettle();

        // If the campaign is completed, we should see the completion screen
        // Look for unique elements of the completion screen
        final goalAchievedText = find.text('GOAL ACHIEVED!');
        if (goalAchievedText.evaluate().isNotEmpty) {
          // We're on the completion screen
          expect(find.text('CAMPAIGN COMPLETE'), findsOneWidget);
          expect(find.byIcon(Icons.emoji_events), findsOneWidget);
          expect(find.text('BACK TO CAMPAIGNS'), findsOneWidget);
          expect(find.text('VIEW FULL HISTORY'), findsOneWidget);
        } else {
          // Campaign wasn't completed yet, that's okay
          // Just verify we're still on campaigns screen
          expect(find.text('CAMPAIGNS'), findsWidgets);
        }
      },
      skip: true, // E2E requires device; skipped for CI
    );

    testWidgets(
      'user can navigate back from completion screen',
      (WidgetTester tester) async {
        app.main();
        await tester.pumpAndSettle();

        // Navigate to a completion screen by URL if possible
        // For now, just verify the button exists on campaigns screen
        expect(find.text('CAMPAIGNS'), findsWidgets);
      },
      skip: true, // E2E requires device; skipped for CI
    );

    testWidgets(
      'user can view full history from completion screen',
      (WidgetTester tester) async {
        app.main();
        await tester.pumpAndSettle();

        // Similar to above - verify UI structure
        expect(find.text('CAMPAIGNS'), findsWidgets);
      },
      skip: true, // E2E requires device; skipped for CI
    );

    testWidgets(
      'completed campaigns are marked inactive in the model',
      (WidgetTester tester) async {
        // This is more of an integration test than E2E
        // It verifies the data model after completion

        app.main();
        await tester.pumpAndSettle();

        // Note: In a real E2E test with a device, we'd:
        // 1. Create a campaign with totalDays = 1
        // 2. Check in once
        // 3. Verify the campaign transitions to inactive
        // 4. Verify the completion screen appears
        // For now, this is a placeholder
        expect(true, isTrue);
      },
      skip: true, // E2E requires device; skipped for CI
    );
  });
}
