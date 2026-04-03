import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mtbox_app/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('App Shell E2E', () {
    testWidgets('home tab loads with greeting and activity feed', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      expect(find.text('HEY DREW'), findsOneWidget);
      expect(find.text('RECENT ACTIVITY'), findsOneWidget);
    });

    testWidgets('bottom nav renders all three tabs', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      expect(find.text('HOME'), findsOneWidget);
      expect(find.text('CAMPAIGNS'), findsWidgets);
      expect(find.text('PROFILE'), findsWidgets);
    });

    testWidgets('navigating to Campaigns shows campaign cards', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      await tester.tap(find.text('CAMPAIGNS').last);
      await tester.pumpAndSettle();

      expect(find.text('Morning Run'), findsOneWidget);
      expect(find.text('No Sugar'), findsOneWidget);
      expect(find.text('START NEW CAMPAIGN'), findsOneWidget);
    });

    testWidgets('navigating to Profile shows user name and stats', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      await tester.tap(find.text('PROFILE').last);
      await tester.pumpAndSettle();

      expect(find.text('DREW'), findsWidgets);
      expect(find.text('Total Completed'), findsOneWidget);
      expect(find.text('Best Streak'), findsOneWidget);
    });

    testWidgets('tapping HOME tab from Campaigns returns to home', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      await tester.tap(find.text('CAMPAIGNS').last);
      await tester.pumpAndSettle();

      await tester.tap(find.text('HOME'));
      await tester.pumpAndSettle();

      expect(find.text('HEY DREW'), findsOneWidget);
    });
  });
}
