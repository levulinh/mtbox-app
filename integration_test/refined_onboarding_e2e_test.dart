import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mtbox_app/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Refined Onboarding E2E — Sample Data Flow', () {
    testWidgets(
      'first launch shows sample data with dismiss option, user can dismiss and start fresh',
      (WidgetTester tester) async {
        skip('E2E requires physical Android device via USB');

        app.main();
        await tester.pumpAndSettle();

        expect(find.text('SAMPLE DATA'), findsOneWidget);
        expect(find.text('HEY DREW', findRichText: true), findsOneWidget);
        expect(find.text("You're all set! Explore these sample campaigns or dismiss them to start fresh."), findsOneWidget);

        expect(find.text('Read Daily'), findsWidgets);
        expect(find.text('Exercise 5x/Week'), findsWidgets);

        await tester.tap(find.text('Dismiss Samples →'));
        await tester.pumpAndSettle();

        expect(find.text('REMOVE SAMPLE DATA?'), findsOneWidget);
        expect(find.text('KEEP SAMPLES'), findsOneWidget);
        expect(find.text('START FRESH'), findsOneWidget);

        await tester.tap(find.text('START FRESH'));
        await tester.pumpAndSettle();

        expect(find.text('SAMPLE DATA'), findsNothing);
        expect(find.text('LIVE DATA'), findsOneWidget);
        expect(find.text('Dismiss Samples →'), findsNothing);
        expect(find.text('NO ACTIVITY YET'), findsOneWidget);
      },
    );

    testWidgets(
      'user can dismiss dialog and keep samples by tapping KEEP SAMPLES',
      (WidgetTester tester) async {
        skip('E2E requires physical Android device via USB');

        app.main();
        await tester.pumpAndSettle();

        expect(find.text('SAMPLE DATA'), findsOneWidget);
        expect(find.text('Dismiss Samples →'), findsOneWidget);

        await tester.tap(find.text('Dismiss Samples →'));
        await tester.pumpAndSettle();

        expect(find.text('REMOVE SAMPLE DATA?'), findsOneWidget);

        await tester.tap(find.text('KEEP SAMPLES'));
        await tester.pumpAndSettle();

        expect(find.text('SAMPLE DATA'), findsOneWidget);
        expect(find.text('Dismiss Samples →'), findsOneWidget);
        expect(find.text('Read Daily'), findsWidgets);
        expect(find.text('Exercise 5x/Week'), findsWidgets);
      },
    );
  });
}
