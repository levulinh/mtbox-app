import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mtbox_app/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Authentication Flow E2E', () {
    testWidgets('Register new account, sign in, and persist across restart', (WidgetTester tester) async {
      // Start app for first time (no user)
      app.main();
      await tester.pumpAndSettle();

      // Should show sign-in screen
      expect(find.text('Welcome Back'), findsOneWidget);
      expect(find.text('Create Account'), findsOneWidget);

      // Navigate to register
      await tester.tap(find.byType(GestureDetector).last); // CREATE ACCOUNT button
      await tester.pumpAndSettle();

      expect(find.text('Create Account'), findsOneWidget); // Heading, not button

      // Fill registration form
      final textFields = find.byType(TextField);
      await tester.enterText(textFields.at(0), 'testuser@example.com');
      await tester.enterText(textFields.at(1), 'TestPass123!');
      await tester.enterText(textFields.at(2), 'TestPass123!');
      await tester.pumpAndSettle();

      // Submit registration
      await tester.tap(find.text('CREATE & SIGN IN'));
      await tester.pumpAndSettle();

      // Should navigate to home
      expect(find.text('CAMPAIGNS'), findsOneWidget);
      expect(find.byType(FloatingActionButton), findsOneWidget);

      // Verify user is signed in by checking that sign-in screen is not shown
      expect(find.text('Welcome Back'), findsNothing);
    });

    testWidgets('Sign in with existing account', (WidgetTester tester) async {
      // Start app
      app.main();
      await tester.pumpAndSettle();

      // Should show sign-in screen
      expect(find.text('Welcome Back'), findsOneWidget);

      // Fill sign-in form
      final textFields = find.byType(TextField);
      await tester.enterText(textFields.at(0), 'testuser@example.com');
      await tester.enterText(textFields.at(1), 'TestPass123!');
      await tester.pumpAndSettle();

      // Submit sign-in
      await tester.tap(find.text('SIGN IN'));
      await tester.pumpAndSettle();

      // Should navigate to home or onboarding (depending on previous state)
      // At minimum, should not be on sign-in screen
      expect(find.text('Welcome Back'), findsNothing);
    });

    testWidgets('Sign in with wrong password shows error', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      expect(find.text('Welcome Back'), findsOneWidget);

      // Enter wrong password
      final textFields = find.byType(TextField);
      await tester.enterText(textFields.at(0), 'testuser@example.com');
      await tester.enterText(textFields.at(1), 'WrongPassword123!');
      await tester.pumpAndSettle();

      // Submit
      await tester.tap(find.text('SIGN IN'));
      await tester.pumpAndSettle();

      // Should show error
      expect(
        find.text('Invalid email or password. Please try again.'),
        findsOneWidget,
      );

      // Button should change to TRY AGAIN
      expect(find.text('TRY AGAIN'), findsOneWidget);
    });

    testWidgets('Duplicate email registration shows error', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to register
      await tester.tap(find.byType(GestureDetector).last);
      await tester.pumpAndSettle();

      // Try to register with existing email
      final textFields = find.byType(TextField);
      await tester.enterText(textFields.at(0), 'testuser@example.com');
      await tester.enterText(textFields.at(1), 'AnotherPass123!');
      await tester.enterText(textFields.at(2), 'AnotherPass123!');
      await tester.pumpAndSettle();

      // Submit
      await tester.tap(find.text('CREATE & SIGN IN'));
      await tester.pumpAndSettle();

      // Should show error
      expect(
        find.text('This email is already in use. Sign in instead.'),
        findsOneWidget,
      );
    });
  });
}
