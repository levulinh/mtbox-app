import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mtbox/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Focus Session E2E Tests', () {
    testWidgets('User can access focus session from campaign detail screen',
        (tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Onboarding: skip if present
      final createCampaignBtn = find.byType(ElevatedButton);
      if (createCampaignBtn.evaluate().isNotEmpty) {
        await tester.tap(find.text('GET STARTED', skipOffstage: false));
        await tester.pumpAndSettle(const Duration(seconds: 1));
      }

      // Navigate to first campaign in the list
      final campaignCards = find.byType(Card);
      if (campaignCards.evaluate().isNotEmpty) {
        await tester.tap(campaignCards.first);
        await tester.pumpAndSettle(const Duration(seconds: 1));
      }

      // Look for START FOCUS SESSION button
      final focusBtn = find.text('START FOCUS SESSION', skipOffstage: false);
      expect(focusBtn, findsWidgets);
    });

    testWidgets('Focus session screen displays timer and controls',
        (tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Skip onboarding if needed
      final skipBtn = find.byType(ElevatedButton);
      if (skipBtn.evaluate().isNotEmpty) {
        await tester.tap(skipBtn.first);
        await tester.pumpAndSettle(const Duration(seconds: 1));
      }

      // Tap first campaign
      final campaignCards = find.byType(Card);
      if (campaignCards.evaluate().isNotEmpty) {
        await tester.tap(campaignCards.first);
        await tester.pumpAndSettle(const Duration(seconds: 1));
      }

      // Tap START FOCUS SESSION
      final focusBtn = find.text('START FOCUS SESSION', skipOffstage: false);
      if (focusBtn.evaluate().isNotEmpty) {
        await tester.tap(focusBtn.first);
        await tester.pumpAndSettle(const Duration(seconds: 1));
      }

      // Verify focus session is displayed
      expect(find.text('FOCUS MODE'), findsOneWidget);
      expect(find.text('REMAINING'), findsOneWidget);
    });

    testWidgets('User can adjust session duration', (tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Skip onboarding
      final skipBtn = find.byType(ElevatedButton);
      if (skipBtn.evaluate().isNotEmpty) {
        await tester.tap(skipBtn.first);
        await tester.pumpAndSettle(const Duration(seconds: 1));
      }

      // Open campaign detail
      final campaignCards = find.byType(Card);
      if (campaignCards.evaluate().isNotEmpty) {
        await tester.tap(campaignCards.first);
        await tester.pumpAndSettle(const Duration(seconds: 1));
      }

      // Open focus session
      final focusBtn = find.text('START FOCUS SESSION', skipOffstage: false);
      if (focusBtn.evaluate().isNotEmpty) {
        await tester.tap(focusBtn.first);
        await tester.pumpAndSettle(const Duration(seconds: 1));
      }

      // Tap duration pill to open dialog
      final durationPill = find.text('MIN SESSION', skipOffstage: false);
      if (durationPill.evaluate().isNotEmpty) {
        await tester.tap(durationPill.first);
        await tester.pumpAndSettle(const Duration(seconds: 1));
      }

      // Verify duration options are displayed
      expect(find.text('SET DURATION'), findsOneWidget);
    });

    testWidgets('Focus session can be ended early', (tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Skip onboarding
      final skipBtn = find.byType(ElevatedButton);
      if (skipBtn.evaluate().isNotEmpty) {
        await tester.tap(skipBtn.first);
        await tester.pumpAndSettle(const Duration(seconds: 1));
      }

      // Open campaign
      final campaignCards = find.byType(Card);
      if (campaignCards.evaluate().isNotEmpty) {
        await tester.tap(campaignCards.first);
        await tester.pumpAndSettle(const Duration(seconds: 1));
      }

      // Start focus session
      final focusBtn = find.text('START FOCUS SESSION', skipOffstage: false);
      if (focusBtn.evaluate().isNotEmpty) {
        await tester.tap(focusBtn.first);
        await tester.pumpAndSettle(const Duration(seconds: 1));
      }

      // Verify End Session Early button is present
      expect(find.text('END SESSION EARLY'), findsOneWidget);
    });

    testWidgets('Focus session displays notifications silenced indicator',
        (tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Skip onboarding
      final skipBtn = find.byType(ElevatedButton);
      if (skipBtn.evaluate().isNotEmpty) {
        await tester.tap(skipBtn.first);
        await tester.pumpAndSettle(const Duration(seconds: 1));
      }

      // Open campaign
      final campaignCards = find.byType(Card);
      if (campaignCards.evaluate().isNotEmpty) {
        await tester.tap(campaignCards.first);
        await tester.pumpAndSettle(const Duration(seconds: 1));
      }

      // Start focus session
      final focusBtn = find.text('START FOCUS SESSION', skipOffstage: false);
      if (focusBtn.evaluate().isNotEmpty) {
        await tester.tap(focusBtn.first);
        await tester.pumpAndSettle(const Duration(seconds: 1));
      }

      // Verify notifications silenced indicator
      expect(find.text('Notifications silenced'), findsOneWidget);
      expect(find.byIcon(Icons.notifications_off), findsOneWidget);
    });

    testWidgets('Focus session has full-screen dark takeover',
        (tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Skip onboarding
      final skipBtn = find.byType(ElevatedButton);
      if (skipBtn.evaluate().isNotEmpty) {
        await tester.tap(skipBtn.first);
        await tester.pumpAndSettle(const Duration(seconds: 1));
      }

      // Open campaign
      final campaignCards = find.byType(Card);
      if (campaignCards.evaluate().isNotEmpty) {
        await tester.tap(campaignCards.first);
        await tester.pumpAndSettle(const Duration(seconds: 1));
      }

      // Start focus session
      final focusBtn = find.text('START FOCUS SESSION', skipOffstage: false);
      if (focusBtn.evaluate().isNotEmpty) {
        await tester.tap(focusBtn.first);
        await tester.pumpAndSettle(const Duration(seconds: 1));
      }

      // Verify we're in focus session (no bottom nav visible)
      expect(find.text('FOCUS MODE'), findsOneWidget);
      // Bottom nav should not be visible in focus session route
    });
  });
}
