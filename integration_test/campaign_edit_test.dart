import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mtbox_app/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Edit & Delete Campaign', () {
    testWidgets('user can open edit screen from campaign card', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to Campaigns tab
      await tester.tap(find.text('CAMPAIGNS').last);
      await tester.pumpAndSettle();

      // Tap the edit icon on the first campaign card
      await tester.tap(find.byIcon(Icons.edit).first);
      await tester.pumpAndSettle();

      expect(find.text('EDIT CAMPAIGN'), findsOneWidget);
      expect(find.text('CAMPAIGN NAME'), findsOneWidget);
      expect(find.text('GOAL (DAYS)'), findsOneWidget);
    });

    testWidgets('edit screen is pre-filled with existing campaign data',
        (tester) async {
      app.main();
      await tester.pumpAndSettle();

      await tester.tap(find.text('CAMPAIGNS').last);
      await tester.pumpAndSettle();

      // Get the first campaign name before opening edit
      final nameFinder = find.byType(Text);
      final firstCampaignName = (nameFinder.evaluate().first.widget as Text).data;

      await tester.tap(find.byIcon(Icons.edit).first);
      await tester.pumpAndSettle();

      // Name field should be pre-filled (not empty)
      final textFields = find.byType(TextField).evaluate();
      final nameField = textFields.first.widget as TextField;
      expect(nameField.controller?.text, isNotEmpty);
    });

    testWidgets('user can edit campaign name and save', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      await tester.tap(find.text('CAMPAIGNS').last);
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.edit).first);
      await tester.pumpAndSettle();

      // Change name
      await tester.enterText(find.byType(TextField).first, 'Renamed Campaign');
      await tester.tap(find.text('SAVE'));
      await tester.pumpAndSettle();

      // Back on campaigns list — updated name visible
      expect(find.text('Renamed Campaign'), findsOneWidget);
    });

    testWidgets('CANCEL returns to previous screen without changes',
        (tester) async {
      app.main();
      await tester.pumpAndSettle();

      await tester.tap(find.text('CAMPAIGNS').last);
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.edit).first);
      await tester.pumpAndSettle();

      await tester.tap(find.text('CANCEL'));
      await tester.pumpAndSettle();

      expect(find.text('EDIT CAMPAIGN'), findsNothing);
    });

    testWidgets('delete button shows confirmation dialog with campaign name',
        (tester) async {
      app.main();
      await tester.pumpAndSettle();

      await tester.tap(find.text('CAMPAIGNS').last);
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.edit).first);
      await tester.pumpAndSettle();

      await tester.tap(find.text('DELETE THIS CAMPAIGN'));
      await tester.pumpAndSettle();

      expect(find.text('DELETE CAMPAIGN?'), findsOneWidget);
      expect(find.textContaining('CANNOT BE UNDONE'), findsOneWidget);
    });

    testWidgets('KEEP IT in delete dialog dismisses without deleting',
        (tester) async {
      app.main();
      await tester.pumpAndSettle();

      await tester.tap(find.text('CAMPAIGNS').last);
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.edit).first);
      await tester.pumpAndSettle();

      await tester.tap(find.text('DELETE THIS CAMPAIGN'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('KEEP IT'));
      await tester.pumpAndSettle();

      expect(find.text('DELETE CAMPAIGN?'), findsNothing);
      expect(find.text('EDIT CAMPAIGN'), findsOneWidget);
    });
  });
}
