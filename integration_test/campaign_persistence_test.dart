import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mtbox_app/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Campaign Persistence — E2E', () {
    testWidgets('seed campaigns are visible on first launch', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      await tester.tap(find.text('CAMPAIGNS').last);
      await tester.pumpAndSettle();

      expect(find.text('Morning Run'), findsOneWidget);
      expect(find.text('Daily Reading'), findsOneWidget);
      expect(find.text('No Sugar'), findsOneWidget);
      expect(find.text('Meditation'), findsOneWidget);
    });

    testWidgets('newly created campaign persists after re-initializing app', (tester) async {
      // First launch: create a campaign
      app.main();
      await tester.pumpAndSettle();

      await tester.tap(find.text('CAMPAIGNS').last);
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).first, 'Persistence Test Run');
      await tester.enterText(find.byType(TextField).last, '7');
      await tester.tap(find.text('CREATE'));
      await tester.pumpAndSettle();

      expect(find.text('Persistence Test Run'), findsOneWidget);

      // Second launch: re-run app (Hive box is still open with same data)
      app.main();
      await tester.pumpAndSettle();

      await tester.tap(find.text('CAMPAIGNS').last);
      await tester.pumpAndSettle();

      // Campaign created in the first session is still visible
      expect(find.text('Persistence Test Run'), findsOneWidget);
    });

    testWidgets('seed campaigns are still present after adding a new one', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      await tester.tap(find.text('CAMPAIGNS').last);
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).first, 'Extra Campaign');
      await tester.enterText(find.byType(TextField).last, '14');
      await tester.tap(find.text('CREATE'));
      await tester.pumpAndSettle();

      // Original seed campaigns still present alongside the new one
      expect(find.text('Morning Run'), findsOneWidget);
      expect(find.text('Extra Campaign'), findsOneWidget);
    });
  });
}
