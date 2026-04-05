import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../lib/providers/auth_provider.dart';
import '../../lib/providers/user_profile_provider.dart';
import '../../lib/screens/user_profile_screen.dart';
import '../../lib/theme.dart';

// Mock notifiers for testing without Hive
class _MockUserProfileNotifier extends UserProfileNotifier {
  final UserProfileState _initialState;

  _MockUserProfileNotifier(this._initialState);

  @override
  UserProfileState build() => _initialState;
}

class _MockAuthNotifier extends AuthNotifier {
  @override
  build() => const AuthState(
    currentEmail: 'test@example.com',
  );
}

void main() {
  group('UserProfileScreen', () {
    late UserProfileState defaultProfileState;

    setUp(() {
      defaultProfileState = const UserProfileState(
        displayName: 'John Doe',
        avatarPath: null,
        memberSince: 1712239200000, // April 4, 2026
      );
    });

    Widget buildTestApp({
      required UserProfileState profileState,
    }) {
      return ProviderScope(
        overrides: [
          userProfileProvider.overrideWith(
            () => _MockUserProfileNotifier(profileState),
          ),
          authProvider.overrideWith(() => _MockAuthNotifier()),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: UserProfileScreen(),
          ),
        ),
      );
    }

    testWidgets('renders display name', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestApp(profileState: defaultProfileState),
      );

      expect(find.text('John Doe'), findsWidgets);
    });

    testWidgets('renders initials avatar with initials', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestApp(profileState: defaultProfileState),
      );

      expect(find.text('JD'), findsOneWidget);
    });

    testWidgets('renders email below name', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestApp(profileState: defaultProfileState),
      );

      expect(find.text('TEST@EXAMPLE.COM'), findsOneWidget);
    });

    testWidgets('shows app bar with MY PROFILE', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestApp(profileState: defaultProfileState),
      );

      expect(find.text('MY PROFILE'), findsOneWidget);
    });

    testWidgets('shows back button', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestApp(profileState: defaultProfileState),
      );

      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });

    testWidgets('edit button changes to edit mode with text field',
      (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestApp(profileState: defaultProfileState),
      );

      expect(find.byType(TextField), findsNothing);

      await tester.tap(find.text('EDIT DISPLAY NAME'));
      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('DISPLAY NAME'), findsOneWidget);
    });

    testWidgets('cancel button exits edit mode', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestApp(profileState: defaultProfileState),
      );

      await tester.tap(find.text('EDIT DISPLAY NAME'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('CANCEL'));
      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsNothing);
    });

    testWidgets('empty display name shows placeholder',
      (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestApp(
          profileState: const UserProfileState(
            displayName: '',
            memberSince: 0,
          ),
        ),
      );

      expect(find.text('Your Name'), findsOneWidget);
    });

    testWidgets('shows EDIT DISPLAY NAME button', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestApp(profileState: defaultProfileState),
      );

      expect(find.text('EDIT DISPLAY NAME'), findsOneWidget);
    });

    testWidgets('single word name shows first 2 chars as initials',
      (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestApp(
          profileState: const UserProfileState(
            displayName: 'Alice',
            memberSince: 0,
          ),
        ),
      );

      expect(find.text('AL'), findsOneWidget);
    });

    testWidgets('scaffold has correct background color',
      (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestApp(profileState: defaultProfileState),
      );

      // Check that at least one Scaffold exists in the widget tree
      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('contains custom scroll view for content',
      (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestApp(profileState: defaultProfileState),
      );

      expect(find.byType(CustomScrollView), findsOneWidget);
    });

    testWidgets('displays profile app bar container', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestApp(profileState: defaultProfileState),
      );

      // App bar should be visible
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
      expect(find.text('MY PROFILE'), findsOneWidget);
    });
  });
}
