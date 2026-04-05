import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mtbox_app/models/user_account.dart';
import 'package:mtbox_app/models/user_account_adapter.dart';
import 'package:mtbox_app/providers/auth_provider.dart';
import 'package:mtbox_app/screens/sign_in_screen.dart';

class _MockAuthNotifier extends AuthNotifier {
  @override
  AuthState build() {
    return const AuthState();
  }
}

void main() {
  group('SignInScreen', () {

    Future<void> pumpSignInScreen(WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authProvider.overrideWith(() => _MockAuthNotifier()),
          ],
          child: MaterialApp.router(
            routerConfig: GoRouter(
              routes: [
                GoRoute(
                  path: '/',
                  builder: (context, state) => const Scaffold(body: Text('Home')),
                ),
                GoRoute(
                  path: '/sign-in',
                  builder: (context, state) => const SignInScreen(),
                ),
                GoRoute(
                  path: '/register',
                  builder: (context, state) => const Scaffold(body: Text('Register')),
                ),
              ],
              initialLocation: '/sign-in',
            ),
          ),
        ),
      );
    }

    testWidgets('renders logo and heading', (WidgetTester tester) async {
      await pumpSignInScreen(tester);
      await tester.pumpAndSettle();

      expect(find.text('MTBOX'), findsWidgets);
      expect(find.text('CAMPAIGN TRACKER'), findsWidgets);
      expect(find.text('Welcome Back'), findsOneWidget);
      expect(find.text('Sign in to continue your campaigns'), findsOneWidget);
    });

    testWidgets('renders email and password fields', (WidgetTester tester) async {
      await pumpSignInScreen(tester);
      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsNWidgets(2));
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
    });

    testWidgets('renders Sign In and Create Account buttons', (WidgetTester tester) async {
      await pumpSignInScreen(tester);
      await tester.pumpAndSettle();

      expect(find.text('SIGN IN'), findsOneWidget);
      expect(find.text('CREATE ACCOUNT'), findsOneWidget);
    });

    testWidgets('shows password visibility toggle', (WidgetTester tester) async {
      await pumpSignInScreen(tester);
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.visibility_off), findsOneWidget);

      // Tap to toggle
      await tester.tap(find.byIcon(Icons.visibility_off));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.visibility), findsOneWidget);
    });

    testWidgets('shows forgot password link', (WidgetTester tester) async {
      await pumpSignInScreen(tester);
      await tester.pumpAndSettle();

      expect(find.text('FORGOT PASSWORD?'), findsOneWidget);
    });

    testWidgets('shows security note at bottom', (WidgetTester tester) async {
      await pumpSignInScreen(tester);
      await tester.pumpAndSettle();

      expect(
        find.text('Your data is encrypted and synced securely. Your campaigns are backed up to the cloud.'),
        findsOneWidget,
      );
    });

    testWidgets('empty form shows validation errors on submit', (WidgetTester tester) async {
      await pumpSignInScreen(tester);
      await tester.pumpAndSettle();

      // Submit without filling fields
      await tester.tap(find.text('SIGN IN'));
      await tester.pumpAndSettle();

      expect(find.text('Email is required'), findsOneWidget);
    });

    testWidgets('renders form fields that accept input', (WidgetTester tester) async {
      await pumpSignInScreen(tester);
      await tester.pumpAndSettle();

      // Enter credentials
      await tester.enterText(find.byType(TextField).first, 'user@example.com');
      await tester.enterText(find.byType(TextField).last, 'password123');
      await tester.pumpAndSettle();

      // Verify fields contain the entered text
      expect(find.widgetWithText(TextField, 'user@example.com'), findsOneWidget);
      expect(find.widgetWithText(TextField, 'password123'), findsOneWidget);
    });


    testWidgets('error clears when user modifies field', (WidgetTester tester) async {
      await pumpSignInScreen(tester);
      await tester.pumpAndSettle();

      // Submit with wrong credentials
      await tester.enterText(find.byType(TextField).first, 'user@example.com');
      await tester.enterText(find.byType(TextField).last, 'wrongpass');
      await tester.pumpAndSettle();
      await tester.tap(find.text('SIGN IN'));
      await tester.pumpAndSettle();

      expect(find.text('Invalid email or password. Please try again.'), findsOneWidget);

      // Modify email field
      await tester.tap(find.byType(TextField).first);
      await tester.enterText(find.byType(TextField).first, 'user@example.comx');
      await tester.pumpAndSettle();

      // Error should clear
      expect(find.text('Invalid email or password. Please try again.'), findsNothing);
    });

  });
}
