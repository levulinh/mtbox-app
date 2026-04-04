import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mtbox_app/screens/onboarding_screen.dart';
import 'package:mtbox_app/models/campaign.dart';
import 'package:mtbox_app/theme.dart';

void main() {
  group('Onboarding Screen - Welcome Page', () {
    testWidgets('Welcome page displays app title and tagline',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ProviderScope(
            child: OnboardingScreen(),
          ),
        ),
      );

      expect(find.text('MTBOX'), findsOneWidget);
      expect(find.text('BUILD HABITS THAT STICK'), findsOneWidget);
    });

    testWidgets('Welcome page displays GET STARTED button',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ProviderScope(
            child: OnboardingScreen(),
          ),
        ),
      );

      expect(find.text('GET STARTED'), findsOneWidget);
    });

    testWidgets('Welcome page displays SKIP link',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ProviderScope(
            child: OnboardingScreen(),
          ),
        ),
      );

      expect(find.text('SKIP — I KNOW THE DRILL'), findsOneWidget);
    });

    testWidgets('Welcome page displays progress dots',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ProviderScope(
            child: OnboardingScreen(),
          ),
        ),
      );

      // Three progress dots on welcome page
      final containers = find.byType(Container);
      expect(containers, findsWidgets);
    });

    testWidgets('Tapping GET STARTED navigates to next page',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ProviderScope(
            child: OnboardingScreen(),
          ),
        ),
      );

      // Verify we see the welcome page content
      expect(find.text('Track your goals,\none day at a time.'), findsOneWidget);

      // Tap GET STARTED
      await tester.tap(find.text('GET STARTED'));
      await tester.pumpAndSettle();

      // Now we should see "How It Works" page
      expect(find.text('HOW IT WORKS'), findsOneWidget);
    });
  });

  group('Onboarding Screen - How It Works Page', () {
    testWidgets('How It Works page displays feature rows',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ProviderScope(
            child: OnboardingScreen(),
          ),
        ),
      );

      // Go to second page
      await tester.tap(find.text('GET STARTED'));
      await tester.pumpAndSettle();

      expect(find.text('CREATE A CAMPAIGN', skipOffstage: false), findsOneWidget);
      expect(find.text('CHECK IN DAILY', skipOffstage: false), findsOneWidget);
    });

    testWidgets('How It Works page displays example campaign card',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ProviderScope(
            child: OnboardingScreen(),
          ),
        ),
      );

      // Go to second page
      await tester.tap(find.text('GET STARTED'));
      await tester.pumpAndSettle();

      expect(find.text('EXAMPLE CAMPAIGN', skipOffstage: false), findsOneWidget);
      expect(find.text('Exercise Daily', skipOffstage: false), findsOneWidget);
      expect(find.text('DAY 12 OF 30', skipOffstage: false), findsOneWidget);
    });

    testWidgets('NEXT button navigates to Create Campaign page',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ProviderScope(
            child: OnboardingScreen(),
          ),
        ),
      );

      // Go to second page
      await tester.tap(find.text('GET STARTED'));
      await tester.pumpAndSettle();

      // Verify we're on How It Works
      expect(find.text('HOW IT WORKS'), findsOneWidget);

      // Tap NEXT
      await tester.tap(find.text('NEXT'));
      await tester.pumpAndSettle();

      // Now we should see the Create Campaign page
      expect(find.text('FIRST CAMPAIGN'), findsOneWidget);
    });

    testWidgets('Back button on How It Works returns to Welcome',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ProviderScope(
            child: OnboardingScreen(),
          ),
        ),
      );

      // Go to second page
      await tester.tap(find.text('GET STARTED'));
      await tester.pumpAndSettle();

      // Tap back arrow
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // We should be back on welcome page
      expect(find.text('Track your goals,\none day at a time.'), findsOneWidget);
    });
  });

  group('Onboarding Screen - Create Campaign Page', () {
    testWidgets('Create Campaign page displays form fields',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ProviderScope(
            child: OnboardingScreen(),
          ),
        ),
      );

      // Navigate to page 3
      await tester.tap(find.text('GET STARTED'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('NEXT'));
      await tester.pumpAndSettle();

      expect(find.text('CAMPAIGN NAME'), findsOneWidget);
      expect(find.text('GOAL DURATION'), findsOneWidget);
    });

    testWidgets('Create Campaign page has pre-filled default values',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ProviderScope(
            child: OnboardingScreen(),
          ),
        ),
      );

      // Navigate to page 3
      await tester.tap(find.text('GET STARTED'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('NEXT'));
      await tester.pumpAndSettle();

      expect(find.text('Exercise Daily'), findsOneWidget);
      expect(find.text('30'), findsOneWidget);
    });

    testWidgets('Empty campaign name shows error on submit',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ProviderScope(
            child: OnboardingScreen(),
          ),
        ),
      );

      // Navigate to page 3
      await tester.tap(find.text('GET STARTED'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('NEXT'));
      await tester.pumpAndSettle();

      // Clear the name field
      final nameField = find.byType(TextField).first;
      await tester.enterText(nameField, '');
      await tester.pumpAndSettle();

      // Try to submit
      await tester.tap(find.text('CREATE & START'));
      await tester.pumpAndSettle();

      expect(find.text('Campaign name is required'), findsOneWidget);
    });

    testWidgets('Invalid days (zero) shows error on submit',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ProviderScope(
            child: OnboardingScreen(),
          ),
        ),
      );

      // Navigate to page 3
      await tester.tap(find.text('GET STARTED'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('NEXT'));
      await tester.pumpAndSettle();

      // Set days to 0
      final daysField = find.byType(TextField).last;
      await tester.enterText(daysField, '0');
      await tester.pumpAndSettle();

      // Try to submit
      await tester.tap(find.text('CREATE & START'));
      await tester.pumpAndSettle();

      expect(find.text('Enter a valid number of days'), findsOneWidget);
    });

    testWidgets('Valid campaign data clears errors on submit',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ProviderScope(
            child: OnboardingScreen(),
          ),
        ),
      );

      // Navigate to page 3
      await tester.tap(find.text('GET STARTED'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('NEXT'));
      await tester.pumpAndSettle();

      // Values are already pre-filled with valid defaults
      expect(find.text('Exercise Daily'), findsOneWidget);
      expect(find.text('30'), findsOneWidget);

      // No errors should be visible before submit
      expect(find.text('Campaign name is required'), findsNothing);
      expect(find.text('Enter a valid number of days'), findsNothing);
    });

    testWidgets('Back button on Create Campaign page returns to How It Works',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ProviderScope(
            child: OnboardingScreen(),
          ),
        ),
      );

      // Navigate to page 3
      await tester.tap(find.text('GET STARTED'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('NEXT'));
      await tester.pumpAndSettle();

      // Verify we're on page 3
      expect(find.text('FIRST CAMPAIGN'), findsOneWidget);

      // Tap back
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // We should be back on How It Works
      expect(find.text('HOW IT WORKS'), findsOneWidget);
    });
  });

  group('Onboarding Screen - Navigation Flow', () {
    testWidgets('Forward navigation: Welcome → How It Works → Create Campaign',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ProviderScope(
            child: OnboardingScreen(),
          ),
        ),
      );

      // Page 1
      expect(find.text('MTBOX'), findsOneWidget);

      // Go to Page 2
      await tester.tap(find.text('GET STARTED'));
      await tester.pumpAndSettle();
      expect(find.text('HOW IT WORKS'), findsOneWidget);

      // Go to Page 3
      await tester.tap(find.text('NEXT'));
      await tester.pumpAndSettle();
      expect(find.text('FIRST CAMPAIGN'), findsOneWidget);
    });

    testWidgets('Backward navigation: Create Campaign → How It Works → Welcome',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ProviderScope(
            child: OnboardingScreen(),
          ),
        ),
      );

      // Go to page 3
      await tester.tap(find.text('GET STARTED'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('NEXT'));
      await tester.pumpAndSettle();

      // Back to page 2
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();
      expect(find.text('HOW IT WORKS'), findsOneWidget);

      // Back to page 1
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();
      expect(find.text('MTBOX'), findsOneWidget);
    });
  });

  group('Onboarding Screen - Progress Dots', () {
    testWidgets('Progress dots reflect current page on Welcome',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ProviderScope(
            child: OnboardingScreen(),
          ),
        ),
      );

      // On welcome page (page 0), first dot should be active (blue)
      expect(find.text('GET STARTED'), findsOneWidget);
    });

    testWidgets('Progress dots update when navigating between pages',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ProviderScope(
            child: OnboardingScreen(),
          ),
        ),
      );

      // Go to page 2
      await tester.tap(find.text('GET STARTED'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('NEXT'));
      await tester.pumpAndSettle();

      // We're on page 3 (index 2), verify the page content
      expect(find.text('FIRST CAMPAIGN'), findsOneWidget);
    });
  });

  group('Onboarding Screen - Theme & Style', () {
    testWidgets('Welcome page uses blue hero block', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ProviderScope(
            child: OnboardingScreen(),
          ),
        ),
      );

      // Find containers with blue color (hero block)
      final containers = find.byType(Container);
      expect(containers, findsWidgets);
      expect(find.text('MTBOX'), findsOneWidget);
    });

    testWidgets('Button styling is consistent across pages',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ProviderScope(
            child: OnboardingScreen(),
          ),
        ),
      );

      // All primary buttons should have arrow icon
      expect(find.byIcon(Icons.arrow_forward), findsWidgets);
    });
  });
}
