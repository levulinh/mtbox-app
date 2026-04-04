import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mtbox_app/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Campaign Detail Screen', () {
    testWidgets('user can open a campaign and see its detail screen',
        (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to Campaigns tab
      await tester.tap(find.text('CAMPAIGNS').last);
      await tester.pumpAndSettle();

      // Tap the first campaign card
      final campaignCards = find.byType(GestureDetector);
      await tester.tap(campaignCards.first);
      await tester.pumpAndSettle();

      // Detail screen is open — stats row is visible
      expect(find.text('DAY STREAK'), findsOneWidget);
      expect(find.text('COMPLETED'), findsOneWidget);
      expect(find.text('GOAL DAYS'), findsOneWidget);

      // Progress section is visible
      expect(find.text('PROGRESS'), findsOneWidget);

      // Day grid is visible
      expect(find.text('CAMPAIGN DAYS'), findsOneWidget);

      // Recent activity is visible
      expect(find.text('RECENT ACTIVITY'), findsOneWidget);

      // Back arrow navigates back to campaigns list
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      expect(find.text('CAMPAIGNS'), findsOneWidget);
      expect(find.text('DAY STREAK'), findsNothing);
    });

    testWidgets('campaign detail shows correct progress text', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to Campaigns tab
      await tester.tap(find.text('CAMPAIGNS').last);
      await tester.pumpAndSettle();

      // Tap a campaign card
      await tester.tap(find.byType(GestureDetector).first);
      await tester.pumpAndSettle();

      // Progress text exists (exact value depends on seed data)
      expect(find.textContaining('days —'), findsOneWidget);
      expect(find.textContaining('days remaining'), findsOneWidget);
    });

    testWidgets('campaign detail activity list shows DONE and MISSED labels',
        (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to Campaigns tab
      await tester.tap(find.text('CAMPAIGNS').last);
      await tester.pumpAndSettle();

      // Open first campaign
      await tester.tap(find.byType(GestureDetector).first);
      await tester.pumpAndSettle();

      // At least one DONE or MISSED should be visible (seed data has history)
      final hasDone = find.text('DONE').evaluate().isNotEmpty;
      final hasMissed = find.text('MISSED').evaluate().isNotEmpty;
      expect(hasDone || hasMissed, isTrue);
    });
  });
}
