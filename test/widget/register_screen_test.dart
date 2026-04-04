import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mtbox_app/models/user_account.dart';
import 'package:mtbox_app/models/user_account_adapter.dart';
import 'package:mtbox_app/providers/auth_provider.dart';
import 'package:mtbox_app/screens/register_screen.dart';

class _MockAuthNotifier extends AuthNotifier {
  @override
  AuthState build() {
    return const AuthState();
  }
}

void main() {
  group('RegisterScreen', () {

    Future<void> pumpRegisterScreen(WidgetTester tester) async {
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
                  builder: (context, state) => const Scaffold(body: Text('Sign In')),
                ),
                GoRoute(
                  path: '/register',
                  builder: (context, state) => const RegisterScreen(),
                ),
              ],
              initialLocation: '/register',
            ),
          ),
        ),
      );
    }

    testWidgets('renders compact logo and heading', (WidgetTester tester) async {
      await pumpRegisterScreen(tester);
      await tester.pumpAndSettle();

      expect(find.text('MTBOX'), findsWidgets);
      expect(find.text('CAMPAIGN TRACKER'), findsWidgets);
      expect(find.text('Create Account'), findsOneWidget);
      expect(find.text('Start tracking your campaigns today'), findsOneWidget);
    });

    testWidgets('renders email, password, and confirm password fields', (WidgetTester tester) async {
      await pumpRegisterScreen(tester);
      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsNWidgets(3));
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Confirm Password'), findsOneWidget);
    });

    testWidgets('renders Create & Sign In and Sign In Instead buttons', (WidgetTester tester) async {
      await pumpRegisterScreen(tester);
      await tester.pumpAndSettle();

      expect(find.text('CREATE & SIGN IN'), findsOneWidget);
      expect(find.text('SIGN IN INSTEAD'), findsOneWidget);
    });

    testWidgets('toggles password visibility', (WidgetTester tester) async {
      await pumpRegisterScreen(tester);
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.visibility_off), findsNWidgets(2));

      // Tap first password field visibility toggle
      await tester.tap(find.byIcon(Icons.visibility_off).first);
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.visibility), findsNWidgets(1));
    });

    testWidgets('empty form shows validation errors on submit', (WidgetTester tester) async {
      await pumpRegisterScreen(tester);
      await tester.pumpAndSettle();

      // Submit without filling fields
      await tester.tap(find.text('CREATE & SIGN IN'));
      await tester.pumpAndSettle();

      expect(find.text('Email is required'), findsOneWidget);
      expect(find.text('Password must be at least 6 characters'), findsOneWidget);
    });

    testWidgets('password confirmation mismatch shows error', (WidgetTester tester) async {
      await pumpRegisterScreen(tester);
      await tester.pumpAndSettle();

      // Fill fields with mismatched passwords
      await tester.enterText(find.byType(TextField).at(0), 'user@example.com');
      await tester.enterText(find.byType(TextField).at(1), 'password123');
      await tester.enterText(find.byType(TextField).at(2), 'differentpass');
      await tester.pumpAndSettle();

      // Submit
      await tester.tap(find.text('CREATE & SIGN IN'));
      await tester.pumpAndSettle();

      expect(find.text("Passwords don't match"), findsOneWidget);
    });

    testWidgets('shows password strength bar when typing password', (WidgetTester tester) async {
      await pumpRegisterScreen(tester);
      await tester.pumpAndSettle();

      // Type weak password
      await tester.enterText(find.byType(TextField).at(1), 'weak');
      await tester.pumpAndSettle();

      // Just verify the strength bar renders
      expect(find.byType(LinearProgressIndicator), findsWidgets);
    });

    testWidgets('accepts form input', (WidgetTester tester) async {
      await pumpRegisterScreen(tester);
      await tester.pumpAndSettle();

      // Enter credentials
      await tester.enterText(find.byType(TextField).at(0), 'newuser@example.com');
      await tester.enterText(find.byType(TextField).at(1), 'TestPass123');
      await tester.enterText(find.byType(TextField).at(2), 'TestPass123');
      await tester.pumpAndSettle();

      // Verify fields contain the entered text
      expect(find.widgetWithText(TextField, 'newuser@example.com'), findsOneWidget);
    });

  });
}
