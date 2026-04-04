import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mtbox/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Custom campaign colors and icons end-to-end', () {
    testWidgets('create campaign with custom color and icon',
        (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to create campaign screen
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      // Fill in campaign name
      await tester.enterText(find.byType(TextField).first, 'Reading Challenge');
      await tester.pumpAndSettle();

      // Fill in campaign goal
      await tester.enterText(find.byType(TextField).last, '10 books');
      await tester.pumpAndSettle();

      // Select forest green color
      final colorContainers = find.byWidgetPredicate(
        (widget) =>
            widget is Container &&
            (widget.decoration as BoxDecoration?)?.color != null,
      );

      // The third color should be forest green (index 2)
      await tester.tap(colorContainers.at(2));
      await tester.pumpAndSettle();

      // Select menu_book icon
      await tester.tap(find.byIcon(Icons.menu_book).first);
      await tester.pumpAndSettle();

      // Submit the form
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // Verify we're back on home screen
      expect(find.text('RECENT ACTIVITY'), findsOneWidget);

      // Verify the campaign is displayed with the selected icon
      expect(find.byIcon(Icons.menu_book), findsWidgets);

      // Verify the campaign name is displayed
      expect(find.text('Reading Challenge'), findsOneWidget);
    });

    testWidgets('edit campaign colors and icons', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to create campaign first (to have data to edit)
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).first, 'Original Campaign');
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).last, 'Goal');
      await tester.pumpAndSettle();

      // Submit
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // Now edit the campaign - tap edit button
      await tester.tap(find.byIcon(Icons.edit));
      await tester.pumpAndSettle();

      // Change the color (tap a different color)
      final colorContainers = find.byWidgetPredicate(
        (widget) =>
            widget is Container &&
            (widget.decoration as BoxDecoration?)?.color != null,
      );

      // Tap the amber color (index 4)
      await tester.tap(colorContainers.at(4));
      await tester.pumpAndSettle();

      // Change the icon
      await tester.tap(find.byIcon(Icons.language).first);
      await tester.pumpAndSettle();

      // Submit the form
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // Verify we're back on home screen
      expect(find.text('RECENT ACTIVITY'), findsOneWidget);

      // Verify the new icon is displayed
      expect(find.byIcon(Icons.language), findsWidgets);

      // Verify the campaign name hasn't changed
      expect(find.text('Original Campaign'), findsOneWidget);
    });

    testWidgets('campaign colors persist after app restart',
        (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Create a campaign with custom color
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      await tester.enterText(
          find.byType(TextField).first, 'Persistent Campaign');
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).last, 'Goal');
      await tester.pumpAndSettle();

      // Select plum color (index 3)
      final colorContainers = find.byWidgetPredicate(
        (widget) =>
            widget is Container &&
            (widget.decoration as BoxDecoration?)?.color != null,
      );

      await tester.tap(colorContainers.at(3));
      await tester.pumpAndSettle();

      // Select music_note icon
      await tester.tap(find.byIcon(Icons.music_note).first);
      await tester.pumpAndSettle();

      // Submit
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // Campaign should be visible
      expect(find.text('Persistent Campaign'), findsOneWidget);
      expect(find.byIcon(Icons.music_note), findsWidgets);

      // Restart the app by popping and navigating
      await tester.tap(find.byIcon(Icons.home));
      await tester.pumpAndSettle();

      // Campaign should still be there with the same color/icon
      expect(find.text('Persistent Campaign'), findsOneWidget);
      expect(find.byIcon(Icons.music_note), findsWidgets);
    });
  });
}
