import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:mtbox/main.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('User Profile E2E', () {
    testWidgets('Full user profile flow', (WidgetTester tester) async {
      // Start the app
      await tester.runAsync(() => main());
      await tester.pumpAndSettle();

      // Navigate to profile screen (may require onboarding or sign-in first)
      // For now, test assumes user is already signed in and can access profile

      // Find and tap profile tab (bottom navigation)
      final profileTab = find.text('PROFILE');
      if (profileTab.evaluate().isNotEmpty) {
        await tester.tap(profileTab);
        await tester.pumpAndSettle();
      }

      // Verify profile screen renders
      expect(find.text('MY PROFILE'), findsOneWidget);
      expect(find.byType(CircleAvatar).exists() || find.text('U').exists(),
        isTrue);

      // Tap edit display name button
      final editButton = find.text('EDIT DISPLAY NAME');
      if (editButton.evaluate().isNotEmpty) {
        await tester.tap(editButton);
        await tester.pumpAndSettle();

        // Verify edit form appears
        expect(find.byType(TextField), findsOneWidget);

        // Type new name
        await tester.enterText(find.byType(TextField), 'Jane Doe');
        await tester.pumpAndSettle();

        // Tap save button
        final saveButton = find.text('SAVE');
        if (saveButton.evaluate().isNotEmpty) {
          await tester.tap(saveButton);
          await tester.pumpAndSettle();

          // Verify name updated
          expect(find.text('Jane Doe'), findsWidgets);
        }
      }
    });
  });
}
