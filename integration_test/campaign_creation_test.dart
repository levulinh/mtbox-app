import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mtbox_app/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Campaign Creation — E2E', () {
    testWidgets('user can open create screen from Campaigns FAB',
        (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to Campaigns tab
      await tester.tap(find.text('CAMPAIGNS').last);
      await tester.pumpAndSettle();

      // Tap the FAB (+) to open creation screen
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      expect(find.text('NEW CAMPAIGN'), findsOneWidget);
    });

    testWidgets('submitting empty form shows validation errors', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      await tester.tap(find.text('CAMPAIGNS').last);
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      await tester.tap(find.text('CREATE'));
      await tester.pumpAndSettle();

      expect(find.text('PLEASE FIX THE ERRORS BELOW'), findsOneWidget);
    });

    testWidgets('creating a valid campaign adds it to the list and returns to campaigns',
        (tester) async {
      app.main();
      await tester.pumpAndSettle();

      await tester.tap(find.text('CAMPAIGNS').last);
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).first, 'E2E Run Campaign');
      await tester.enterText(find.byType(TextField).last, '14');
      await tester.tap(find.text('CREATE'));
      await tester.pumpAndSettle();

      // Back on Campaigns screen
      expect(find.text('NEW CAMPAIGN'), findsNothing);
      // New campaign is visible in the list
      expect(find.text('E2E Run Campaign'), findsOneWidget);
    });

    testWidgets('cancel from create screen returns to campaigns without adding',
        (tester) async {
      app.main();
      await tester.pumpAndSettle();

      await tester.tap(find.text('CAMPAIGNS').last);
      await tester.pumpAndSettle();

      // Count campaigns before
      final beforeCount = find.byType(Card).evaluate().length;

      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).first, 'Cancelled Campaign');
      await tester.tap(find.text('CANCEL'));
      await tester.pumpAndSettle();

      expect(find.text('NEW CAMPAIGN'), findsNothing);
      expect(find.text('Cancelled Campaign'), findsNothing);
      expect(find.byType(Card).evaluate().length, equals(beforeCount));
    });
  });
}
