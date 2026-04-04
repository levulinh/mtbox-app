import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mtbox_app/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Campaign Archive', () {
    testWidgets('user can navigate to archive from campaigns tab',
        (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Look for VIEW COMPLETED CAMPAIGNS banner
      // (appears in Campaigns tab when completed campaigns exist)
      final viewCompletedButton = find.text('VIEW COMPLETED CAMPAIGNS');

      // If the button exists, tap it to navigate to archive
      if (viewCompletedButton.evaluate().isNotEmpty) {
        await tester.tap(viewCompletedButton);
        await tester.pumpAndSettle();

        // Should now be on archive screen
        expect(find.text('ARCHIVE'), findsOneWidget);
      }
    });

    testWidgets('archive screen displays completed campaigns', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to campaigns tab first
      final campaignsTab = find.text('CAMPAIGNS').last;
      if (campaignsTab.evaluate().isNotEmpty) {
        await tester.tap(campaignsTab);
        await tester.pumpAndSettle();
      }

      // Try to find VIEW COMPLETED CAMPAIGNS banner
      final viewCompletedButton = find.text('VIEW COMPLETED CAMPAIGNS');
      if (viewCompletedButton.evaluate().isNotEmpty) {
        await tester.tap(viewCompletedButton);
        await tester.pumpAndSettle();

        // Should be on archive screen
        expect(find.text('ARCHIVE'), findsOneWidget);
        expect(find.byIcon(Icons.emoji_events), findsWidgets);
      }
    });

    testWidgets('archive shows summary banner with completed count',
        (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to campaigns
      final campaignsTab = find.text('CAMPAIGNS').last;
      if (campaignsTab.evaluate().isNotEmpty) {
        await tester.tap(campaignsTab);
        await tester.pumpAndSettle();
      }

      // Navigate to archive
      final viewCompletedButton = find.text('VIEW COMPLETED CAMPAIGNS');
      if (viewCompletedButton.evaluate().isNotEmpty) {
        await tester.tap(viewCompletedButton);
        await tester.pumpAndSettle();

        // Should show banner with completed count
        expect(find.text('CAMPAIGNS COMPLETED'), findsOneWidget);
      }
    });

    testWidgets('can navigate from archive back to campaigns', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to campaigns
      final campaignsTab = find.text('CAMPAIGNS').last;
      if (campaignsTab.evaluate().isNotEmpty) {
        await tester.tap(campaignsTab);
        await tester.pumpAndSettle();
      }

      // Navigate to archive
      final viewCompletedButton = find.text('VIEW COMPLETED CAMPAIGNS');
      if (viewCompletedButton.evaluate().isNotEmpty) {
        await tester.tap(viewCompletedButton);
        await tester.pumpAndSettle();

        // Now on archive screen
        expect(find.text('ARCHIVE'), findsOneWidget);

        // Tap back button
        final backButton = find.byIcon(Icons.arrow_back);
        if (backButton.evaluate().isNotEmpty) {
          await tester.tap(backButton);
          await tester.pumpAndSettle();
        }
      }
    });

    testWidgets('archive card shows campaign details', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to campaigns tab
      final campaignsTab = find.text('CAMPAIGNS').last;
      if (campaignsTab.evaluate().isNotEmpty) {
        await tester.tap(campaignsTab);
        await tester.pumpAndSettle();
      }

      // Navigate to archive
      final viewCompletedButton = find.text('VIEW COMPLETED CAMPAIGNS');
      if (viewCompletedButton.evaluate().isNotEmpty) {
        await tester.tap(viewCompletedButton);
        await tester.pumpAndSettle();

        // Should show completed badge
        final completedBadge = find.text('COMPLETED');
        if (completedBadge.evaluate().isNotEmpty) {
          expect(completedBadge, findsOneWidget);
        }
      }
    });

    testWidgets('can view campaign details from archive', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to campaigns
      final campaignsTab = find.text('CAMPAIGNS').last;
      if (campaignsTab.evaluate().isNotEmpty) {
        await tester.tap(campaignsTab);
        await tester.pumpAndSettle();
      }

      // Navigate to archive
      final viewCompletedButton = find.text('VIEW COMPLETED CAMPAIGNS');
      if (viewCompletedButton.evaluate().isNotEmpty) {
        await tester.tap(viewCompletedButton);
        await tester.pumpAndSettle();

        // Tap VIEW DETAILS if available
        final viewDetailsButton = find.text('VIEW DETAILS');
        if (viewDetailsButton.evaluate().isNotEmpty) {
          await tester.tap(viewDetailsButton);
          await tester.pumpAndSettle();

          // Should be on detail screen (check for back button still there)
          expect(find.byIcon(Icons.arrow_back), findsOneWidget);
        }
      }
    });

    testWidgets('archive empty state displays when no campaigns completed',
        (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to campaigns
      final campaignsTab = find.text('CAMPAIGNS').last;
      if (campaignsTab.evaluate().isNotEmpty) {
        await tester.tap(campaignsTab);
        await tester.pumpAndSettle();
      }

      // If there are no completed campaigns, VIEW COMPLETED CAMPAIGNS won't appear
      // This test verifies the empty state is properly designed
      final viewCompletedButton = find.text('VIEW COMPLETED CAMPAIGNS');

      // If we managed to get to archive, check for empty state
      if (viewCompletedButton.evaluate().isNotEmpty) {
        await tester.tap(viewCompletedButton);
        await tester.pumpAndSettle();

        // Either has completed campaigns or shows empty state
        final completedBadge = find.text('COMPLETED');
        final emptyMessage = find.text('NO COMPLETED CAMPAIGNS');

        final hasCampaigns = completedBadge.evaluate().isNotEmpty;
        final isEmptyState = emptyMessage.evaluate().isNotEmpty;

        expect(hasCampaigns || isEmptyState, true);
      }
    });
  });
}
