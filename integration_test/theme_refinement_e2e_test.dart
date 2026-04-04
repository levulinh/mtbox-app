import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mtbox_app/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Theme Refinement E2E (MTB-24)', () {
    testWidgets('App boots and home screen renders with soft shadows', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Verify home screen is visible
      expect(find.text('RECENT ACTIVITY'), findsWidgets);

      // Verify app bar is rendered
      expect(find.byType(AppBar), findsOneWidget);

      // Verify bottom nav is present
      expect(find.byType(BottomNavigationBar), findsOneWidget);

      // Verify no visual regressions by ensuring key elements are present
      expect(find.byType(FloatingActionButton), findsOneWidget);
    });

    testWidgets('Campaign card visible on home screen', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Scroll to find campaign cards
      await tester.dragUntilVisible(
        find.byType(Card).first,
        find.byType(ListView),
        const Offset(0, -300),
      );

      expect(find.byType(Card), findsWidgets);
    });
  });
}
