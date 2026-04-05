import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mtbox_app/main.dart';
import 'package:mtbox_app/models/campaign.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Flexible Goal Types E2E', () {
    testWidgets('Create and display campaign with Days goal type',
        (WidgetTester tester) async {
      await tester.binding.window.physicalSizeTestValue =
          const Size(1080, 1920);
      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);

      await tester.pumpApp(const MTBoxApp());
      await tester.pumpAndSettle();

      // Tap create campaign button
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      // Verify goal type selector is visible
      expect(find.text('Days'), findsOneWidget);
      expect(find.text('Hours'), findsOneWidget);
      expect(find.text('Sessions'), findsOneWidget);
      expect(find.text('Custom'), findsOneWidget);

      // Fill form with Days goal type (default)
      await tester.enterText(find.byType(TextField).first, 'Morning Run');
      await tester.enterText(find.byType(TextField).at(1), '30');
      await tester.tap(find.text('CREATE'));
      await tester.pumpAndSettle();

      // Verify campaign appears in list with Days chip
      expect(find.text('Morning Run'), findsOneWidget);
      expect(find.text('DAYS'), findsWidgets);
    });

    testWidgets('Create and display campaign with Hours goal type',
        (WidgetTester tester) async {
      await tester.binding.window.physicalSizeTestValue =
          const Size(1080, 1920);
      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);

      await tester.pumpApp(const MTBoxApp());
      await tester.pumpAndSettle();

      // Tap create campaign button
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      // Select Hours goal type
      await tester.tap(find.text('Hours'));
      await tester.pumpAndSettle();

      // Verify unit pill changed to HRS
      expect(find.text('HRS'), findsWidgets);

      // Fill form
      await tester.enterText(find.byType(TextField).first, 'Piano Practice');
      await tester.enterText(find.byType(TextField).at(1), '100');
      await tester.tap(find.text('CREATE'));
      await tester.pumpAndSettle();

      // Verify campaign appears with Hours chip
      expect(find.text('Piano Practice'), findsOneWidget);
      expect(find.text('HOURS'), findsWidgets);
    });

    testWidgets('Create and display campaign with Sessions goal type',
        (WidgetTester tester) async {
      await tester.binding.window.physicalSizeTestValue =
          const Size(1080, 1920);
      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);

      await tester.pumpApp(const MTBoxApp());
      await tester.pumpAndSettle();

      // Tap create campaign button
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      // Select Sessions goal type
      await tester.tap(find.text('Sessions'));
      await tester.pumpAndSettle();

      // Verify unit pill changed to SESSIONS
      expect(find.text('SESSIONS'), findsWidgets);

      // Fill form
      await tester.enterText(find.byType(TextField).first, 'Gym Sessions');
      await tester.enterText(find.byType(TextField).at(1), '20');
      await tester.tap(find.text('CREATE'));
      await tester.pumpAndSettle();

      // Verify campaign appears with Sessions chip
      expect(find.text('Gym Sessions'), findsOneWidget);
      expect(find.text('SESSIONS'), findsWidgets);
    });

    testWidgets('Create and display campaign with Custom goal type',
        (WidgetTester tester) async {
      await tester.binding.window.physicalSizeTestValue =
          const Size(1080, 1920);
      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);

      await tester.pumpApp(const MTBoxApp());
      await tester.pumpAndSettle();

      // Tap create campaign button
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      // Select Custom goal type
      await tester.tap(find.text('Custom'));
      await tester.pumpAndSettle();

      // Verify metric name field appears
      expect(find.text('METRIC NAME'), findsOneWidget);

      // Fill form
      await tester.enterText(find.byType(TextField).first, 'Reading');
      await tester.enterText(find.byType(TextField).at(1), '12');
      await tester.enterText(find.byType(TextField).at(2), 'Books read');
      await tester.tap(find.text('CREATE'));
      await tester.pumpAndSettle();

      // Verify campaign appears with custom metric chip
      expect(find.text('Reading'), findsOneWidget);
      expect(find.text('BOOKS READ'), findsWidgets);
    });

    testWidgets('Check-in button label changes based on goal type',
        (WidgetTester tester) async {
      await tester.binding.window.physicalSizeTestValue =
          const Size(1080, 1920);
      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);

      await tester.pumpApp(const MTBoxApp());
      await tester.pumpAndSettle();

      // Create Days campaign
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).first, 'Days Campaign');
      await tester.enterText(find.byType(TextField).at(1), '30');
      await tester.tap(find.text('CREATE'));
      await tester.pumpAndSettle();

      // Verify check-in button shows "CHECK IN TODAY"
      expect(find.text('CHECK IN TODAY'), findsOneWidget);

      // Go back and create Hours campaign
      await tester.tap(find.byIcon(Icons.arrow_back), skipOffstage: false);
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      // Select Hours
      await tester.tap(find.text('Hours'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).first, 'Hours Campaign');
      await tester.enterText(find.byType(TextField).at(1), '100');
      await tester.tap(find.text('CREATE'));
      await tester.pumpAndSettle();

      // Verify check-in button shows "LOG HOURS"
      expect(find.text('LOG HOURS'), findsOneWidget);
    });

    testWidgets('Custom metric name is required when Custom goal type selected',
        (WidgetTester tester) async {
      await tester.binding.window.physicalSizeTestValue =
          const Size(1080, 1920);
      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);

      await tester.pumpApp(const MTBoxApp());
      await tester.pumpAndSettle();

      // Tap create campaign button
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      // Select Custom goal type
      await tester.tap(find.text('Custom'));
      await tester.pumpAndSettle();

      // Fill form but leave metric name empty
      await tester.enterText(find.byType(TextField).first, 'Test Campaign');
      await tester.enterText(find.byType(TextField).at(1), '50');

      // Try to create
      await tester.tap(find.text('CREATE'));
      await tester.pumpAndSettle();

      // Verify error message appears
      expect(find.text('METRIC NAME IS REQUIRED'), findsOneWidget);
    });
  });
}

extension on WidgetTester {
  Future<void> pumpApp(Widget app) async {
    await pumpWidget(app);
  }
}
