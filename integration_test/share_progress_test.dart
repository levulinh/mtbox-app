import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mtbox_app/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Progress sharing end-to-end', () {
    testWidgets('navigate to share screen and display progress card',
        (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Create a campaign first
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).first, 'Test Campaign');
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).last, 'Test goal');
      await tester.pumpAndSettle();

      // Submit
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // Open campaign detail
      await tester.tap(find.byIcon(Icons.edit));
      await tester.pumpAndSettle();

      // Scroll down to find SHARE MY PROGRESS button
      await tester.scroll(find.byType(ListView), const Offset(0, -300));
      await tester.pumpAndSettle();

      // Tap SHARE MY PROGRESS button
      await tester.tap(find.byType(ElevatedButton).last);
      await tester.pumpAndSettle();

      // Verify we're on share screen
      expect(find.text('SHARE PROGRESS'), findsOneWidget);

      // Verify campaign name is displayed
      expect(find.text('TEST CAMPAIGN'), findsOneWidget);

      // Verify MTBox branding is visible
      expect(find.text('MTBOX'), findsOneWidget);
    });

    testWidgets('verify save and share buttons are functional',
        (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Create and navigate to share screen (same as above)
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).first, 'Shareable Campaign');
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).last, 'Goal');
      await tester.pumpAndSettle();

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // Open detail and navigate to share
      await tester.tap(find.byIcon(Icons.edit));
      await tester.pumpAndSettle();

      await tester.scroll(find.byType(ListView), const Offset(0, -300));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(ElevatedButton).last);
      await tester.pumpAndSettle();

      // Verify both action buttons are present
      expect(find.text('SAVE'), findsOneWidget);
      expect(find.text('SHARE NOW'), findsOneWidget);

      // Both buttons should be tappable
      expect(find.byIcon(Icons.download), findsOneWidget);
      expect(find.byIcon(Icons.ios_share), findsOneWidget);
    });

    testWidgets('progress bar displays correctly on share card',
        (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Create campaign
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).first, 'Progress Test');
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).last, 'Goal');
      await tester.pumpAndSettle();

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // Open and navigate to share
      await tester.tap(find.byIcon(Icons.edit));
      await tester.pumpAndSettle();

      await tester.scroll(find.byType(ListView), const Offset(0, -300));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(ElevatedButton).last);
      await tester.pumpAndSettle();

      // Verify progress percentage is displayed
      // Day 1 of 30 = 3% (rounded)
      expect(find.text('3'), findsOneWidget);
    });

    testWidgets('can close share screen with close button',
        (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Create campaign
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).first, 'Close Test');
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).last, 'Goal');
      await tester.pumpAndSettle();

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // Open detail and share
      await tester.tap(find.byIcon(Icons.edit));
      await tester.pumpAndSettle();

      await tester.scroll(find.byType(ListView), const Offset(0, -300));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(ElevatedButton).last);
      await tester.pumpAndSettle();

      // Verify share screen is displayed
      expect(find.text('SHARE PROGRESS'), findsOneWidget);

      // Tap close button
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      // Should be back on detail screen
      expect(find.text('SHARE PROGRESS'), findsNothing);
    });
  });
}
