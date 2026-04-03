import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mtbox_app/screens/create_campaign_screen.dart';
import 'package:mtbox_app/providers/mock_data_provider.dart';

/// Wraps CreateCampaignScreen in the minimal router context it needs.
/// The /home route acts as the parent so context.pop() has somewhere to land.
Widget buildScreen() {
  final router = GoRouter(
    initialLocation: '/home/create',
    routes: [
      GoRoute(
        path: '/home',
        builder: (_, __) => const Scaffold(body: Text('CAMPAIGNS')),
        routes: [
          GoRoute(
            path: 'create',
            builder: (_, __) => const CreateCampaignScreen(),
          ),
        ],
      ),
    ],
  );
  return ProviderScope(
    child: MaterialApp.router(routerConfig: router),
  );
}

void main() {
  // ─── Static rendering ────────────────────────────────────────────────────────

  group('CreateCampaignScreen — initial render', () {
    testWidgets('shows NEW CAMPAIGN as the app bar title', (tester) async {
      await tester.pumpWidget(buildScreen());
      await tester.pumpAndSettle();
      expect(find.text('NEW CAMPAIGN'), findsOneWidget);
    });

    testWidgets('shows CAMPAIGN NAME field label', (tester) async {
      await tester.pumpWidget(buildScreen());
      await tester.pumpAndSettle();
      expect(find.text('CAMPAIGN NAME'), findsOneWidget);
    });

    testWidgets('shows GOAL (DAYS) field label', (tester) async {
      await tester.pumpWidget(buildScreen());
      await tester.pumpAndSettle();
      expect(find.text('GOAL (DAYS)'), findsOneWidget);
    });

    testWidgets('shows DAYS unit pill next to goal field', (tester) async {
      await tester.pumpWidget(buildScreen());
      await tester.pumpAndSettle();
      expect(find.text('DAYS'), findsOneWidget);
    });

    testWidgets('shows CANCEL button', (tester) async {
      await tester.pumpWidget(buildScreen());
      await tester.pumpAndSettle();
      expect(find.text('CANCEL'), findsOneWidget);
    });

    testWidgets('shows CREATE button', (tester) async {
      await tester.pumpWidget(buildScreen());
      await tester.pumpAndSettle();
      expect(find.text('CREATE'), findsOneWidget);
    });

    testWidgets('no validation banner shown before any submission', (tester) async {
      await tester.pumpWidget(buildScreen());
      await tester.pumpAndSettle();
      expect(find.text('PLEASE FIX THE ERRORS BELOW'), findsNothing);
    });

    testWidgets('no field error shown before any submission', (tester) async {
      await tester.pumpWidget(buildScreen());
      await tester.pumpAndSettle();
      expect(find.text('NAME IS REQUIRED'), findsNothing);
      expect(find.text('ENTER A VALID NUMBER OF DAYS'), findsNothing);
    });

    testWidgets('back arrow icon is present in app bar', (tester) async {
      await tester.pumpWidget(buildScreen());
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });
  });

  // ─── Validation ──────────────────────────────────────────────────────────────

  group('CreateCampaignScreen — validation', () {
    testWidgets('tapping CREATE with empty fields shows error banner', (tester) async {
      await tester.pumpWidget(buildScreen());
      await tester.pumpAndSettle();

      await tester.tap(find.text('CREATE'));
      await tester.pumpAndSettle();

      expect(find.text('PLEASE FIX THE ERRORS BELOW'), findsOneWidget);
    });

    testWidgets('tapping CREATE with empty name shows name error', (tester) async {
      await tester.pumpWidget(buildScreen());
      await tester.pumpAndSettle();

      // Only fill goal
      await tester.enterText(find.byType(TextField).last, '30');
      await tester.tap(find.text('CREATE'));
      await tester.pumpAndSettle();

      expect(find.text('NAME IS REQUIRED'), findsOneWidget);
    });

    testWidgets('tapping CREATE with empty goal shows goal error', (tester) async {
      await tester.pumpWidget(buildScreen());
      await tester.pumpAndSettle();

      // Only fill name
      await tester.enterText(find.byType(TextField).first, 'My Campaign');
      await tester.tap(find.text('CREATE'));
      await tester.pumpAndSettle();

      expect(find.text('ENTER A VALID NUMBER OF DAYS'), findsOneWidget);
    });

    testWidgets('tapping CREATE with goal of 0 shows goal error', (tester) async {
      await tester.pumpWidget(buildScreen());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).first, 'My Campaign');
      await tester.enterText(find.byType(TextField).last, '0');
      await tester.tap(find.text('CREATE'));
      await tester.pumpAndSettle();

      expect(find.text('ENTER A VALID NUMBER OF DAYS'), findsOneWidget);
    });

    testWidgets('name error disappears when user types a valid name', (tester) async {
      await tester.pumpWidget(buildScreen());
      await tester.pumpAndSettle();

      // Trigger validation
      await tester.tap(find.text('CREATE'));
      await tester.pumpAndSettle();
      expect(find.text('NAME IS REQUIRED'), findsOneWidget);

      // Fix the name
      await tester.enterText(find.byType(TextField).first, 'Fixed Name');
      await tester.pumpAndSettle();

      expect(find.text('NAME IS REQUIRED'), findsNothing);
    });

    testWidgets('no error banner when both fields are valid before submit',
        (tester) async {
      await tester.pumpWidget(buildScreen());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).first, 'My Campaign');
      await tester.enterText(find.byType(TextField).last, '30');
      await tester.pumpAndSettle();

      expect(find.text('PLEASE FIX THE ERRORS BELOW'), findsNothing);
    });
  });

  // ─── Successful creation ─────────────────────────────────────────────────────

  group('CreateCampaignScreen — successful creation', () {
    testWidgets('valid submission adds campaign to provider and pops screen',
        (tester) async {
      late ProviderContainer container;

      final router = GoRouter(
        initialLocation: '/home/create',
        routes: [
          GoRoute(
            path: '/home',
            builder: (_, __) => const Scaffold(body: Text('CAMPAIGNS')),
            routes: [
              GoRoute(
                path: 'create',
                builder: (_, __) => const CreateCampaignScreen(),
              ),
            ],
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          child: Builder(builder: (context) {
            container = ProviderScope.containerOf(context);
            return MaterialApp.router(routerConfig: router);
          }),
        ),
      );
      await tester.pumpAndSettle();

      final countBefore = container.read(campaignsProvider).length;

      await tester.enterText(find.byType(TextField).first, 'New Habit');
      await tester.enterText(find.byType(TextField).last, '21');
      await tester.tap(find.text('CREATE'));
      await tester.pumpAndSettle();

      // Campaign added
      expect(container.read(campaignsProvider).length, equals(countBefore + 1));

      // Popped back to parent
      expect(find.text('CAMPAIGNS'), findsOneWidget);
      expect(find.text('NEW CAMPAIGN'), findsNothing);
    });

    testWidgets('created campaign has the entered name', (tester) async {
      late ProviderContainer container;

      final router = GoRouter(
        initialLocation: '/home/create',
        routes: [
          GoRoute(
            path: '/home',
            builder: (_, __) => const Scaffold(body: Text('CAMPAIGNS')),
            routes: [
              GoRoute(
                path: 'create',
                builder: (_, __) => const CreateCampaignScreen(),
              ),
            ],
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          child: Builder(builder: (context) {
            container = ProviderScope.containerOf(context);
            return MaterialApp.router(routerConfig: router);
          }),
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).first, 'Daily Yoga');
      await tester.enterText(find.byType(TextField).last, '10');
      await tester.tap(find.text('CREATE'));
      await tester.pumpAndSettle();

      final added = container.read(campaignsProvider).last;
      expect(added.name, equals('Daily Yoga'));
      expect(added.totalDays, equals(10));
      expect(added.currentDay, equals(0));
      expect(added.isActive, isTrue);
    });
  });

  // ─── Cancel ──────────────────────────────────────────────────────────────────

  group('CreateCampaignScreen — cancel', () {
    testWidgets('tapping CANCEL pops back without adding a campaign',
        (tester) async {
      late ProviderContainer container;

      final router = GoRouter(
        initialLocation: '/home/create',
        routes: [
          GoRoute(
            path: '/home',
            builder: (_, __) => const Scaffold(body: Text('CAMPAIGNS')),
            routes: [
              GoRoute(
                path: 'create',
                builder: (_, __) => const CreateCampaignScreen(),
              ),
            ],
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          child: Builder(builder: (context) {
            container = ProviderScope.containerOf(context);
            return MaterialApp.router(routerConfig: router);
          }),
        ),
      );
      await tester.pumpAndSettle();

      final countBefore = container.read(campaignsProvider).length;

      await tester.tap(find.text('CANCEL'));
      await tester.pumpAndSettle();

      expect(container.read(campaignsProvider).length, equals(countBefore));
      expect(find.text('CAMPAIGNS'), findsOneWidget);
    });

    testWidgets('tapping back arrow pops the screen', (tester) async {
      await tester.pumpWidget(buildScreen());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      expect(find.text('CAMPAIGNS'), findsOneWidget);
    });
  });
}
