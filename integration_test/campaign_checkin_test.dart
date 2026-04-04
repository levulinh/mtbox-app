import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mtbox_app/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Daily check-in flow', () {
    testWidgets('user can check in on an active campaign and see confirmation',
        (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to Campaigns tab
      await tester.tap(find.text('CAMPAIGNS').last);
      await tester.pumpAndSettle();

      // At least one active campaign should show a check-in button
      expect(find.text('CHECK IN TODAY'), findsWidgets);

      // Tap the first check-in button
      await tester.tap(find.text('CHECK IN TODAY').first);
      await tester.pumpAndSettle();

      // Toast confirmation should appear (check_circle icon in toast bar)
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
      expect(find.textContaining('CHECKED IN'), findsWidgets);

      // The tapped campaign should now show CHECKED IN TODAY
      expect(find.text('CHECKED IN TODAY'), findsOneWidget);
    });

    testWidgets('check-in button is absent after checking in (no double check-in)',
        (tester) async {
      app.main();
      await tester.pumpAndSettle();

      await tester.tap(find.text('CAMPAIGNS').last);
      await tester.pumpAndSettle();

      final initialCount = find.text('CHECK IN TODAY').evaluate().length;

      await tester.tap(find.text('CHECK IN TODAY').first);
      await tester.pumpAndSettle();

      // One fewer CHECK IN TODAY button is now visible
      expect(find.text('CHECK IN TODAY').evaluate().length,
          equals(initialCount - 1));
    });
  });
}
