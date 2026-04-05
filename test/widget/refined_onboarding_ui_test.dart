import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mtbox_app/models/campaign.dart';
import 'package:mtbox_app/providers/mock_data_provider.dart';
import 'package:mtbox_app/screens/home_screen.dart';
import 'package:mtbox_app/theme.dart';

class _FixedCampaignsNotifier extends CampaignsNotifier {
  final List<Campaign> _campaigns;
  _FixedCampaignsNotifier(this._campaigns);

  @override
  List<Campaign> build() => List<Campaign>.from(_campaigns);

  @override
  void dismissSamples() {
    state = [];
  }
}

class _MutableSampleDataNotifier extends SampleDataNotifier {
  final bool initialValue;
  _MutableSampleDataNotifier(this.initialValue);

  @override
  bool build() => initialValue;

  @override
  void dismiss() {
    state = false;
  }
}

final _testCampaignSamples = [
  Campaign(
    id: 'sample-read-daily',
    name: 'Read Daily',
    goal: 'Read Daily',
    totalDays: 30,
    currentDay: 10,
    isActive: true,
    dayHistory: [false, false, false, true, true, true, true, true, true, true],
    colorHex: '4C6EAD',
    iconName: 'menu_book',
  ),
  Campaign(
    id: 'sample-exercise',
    name: 'Exercise 5x/Week',
    goal: 'Exercise 5x/Week',
    totalDays: 20,
    currentDay: 5,
    isActive: true,
    dayHistory: [false, false, true, true, true],
    colorHex: 'B5735A',
    iconName: 'fitness_center',
  ),
];

void main() {
  group('HomeScreen — Sample Data Badge and Welcome Card', () {
    testWidgets('shows SAMPLE DATA badge when hasSampleData is true', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            campaignsProvider.overrideWith(
              () => _FixedCampaignsNotifier(_testCampaignSamples),
            ),
            hasSampleDataProvider.overrideWith(
              () => _MutableSampleDataNotifier(true),
            ),
          ],
          child: const MaterialApp(home: HomeScreen()),
        ),
      );

      expect(find.text('SAMPLE DATA'), findsOneWidget);
    });

    testWidgets('shows LIVE DATA indicator when hasSampleData is false', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            campaignsProvider.overrideWith(
              () => _FixedCampaignsNotifier([]),
            ),
            hasSampleDataProvider.overrideWith(
              () => _MutableSampleDataNotifier(false),
            ),
          ],
          child: const MaterialApp(home: HomeScreen()),
        ),
      );

      expect(find.text('LIVE DATA'), findsOneWidget);
    });

    testWidgets('shows welcome card when hasSampleData is true', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            campaignsProvider.overrideWith(
              () => _FixedCampaignsNotifier(_testCampaignSamples),
            ),
            hasSampleDataProvider.overrideWith(
              () => _MutableSampleDataNotifier(true),
            ),
          ],
          child: const MaterialApp(home: HomeScreen()),
        ),
      );

      expect(find.text("You're all set! Explore these sample campaigns or dismiss them to start fresh."), findsOneWidget);
      expect(find.text('Dismiss Samples →'), findsOneWidget);
    });

    testWidgets('hides welcome card when hasSampleData is false', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            campaignsProvider.overrideWith(
              () => _FixedCampaignsNotifier([]),
            ),
            hasSampleDataProvider.overrideWith(
              () => _MutableSampleDataNotifier(false),
            ),
          ],
          child: const MaterialApp(home: HomeScreen()),
        ),
      );

      expect(find.text('Dismiss Samples →'), findsNothing);
    });

    testWidgets('shows HEY DREW greeting', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            campaignsProvider.overrideWith(
              () => _FixedCampaignsNotifier(_testCampaignSamples),
            ),
            hasSampleDataProvider.overrideWith(
              () => _MutableSampleDataNotifier(true),
            ),
          ],
          child: const MaterialApp(home: HomeScreen()),
        ),
      );

      expect(find.text('HEY DREW', findRichText: true), findsOneWidget);
    });
  });

  group('HomeScreen — Dismiss Dialog', () {
    testWidgets('shows dismiss dialog when Dismiss Samples is tapped', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            campaignsProvider.overrideWith(
              () => _FixedCampaignsNotifier(_testCampaignSamples),
            ),
            hasSampleDataProvider.overrideWith(
              () => _MutableSampleDataNotifier(true),
            ),
          ],
          child: const MaterialApp(home: HomeScreen()),
        ),
      );

      await tester.tap(find.text('Dismiss Samples →'));
      await tester.pumpAndSettle();

      expect(find.text('REMOVE SAMPLE DATA?'), findsOneWidget);
    });

    testWidgets('dialog shows correct message', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            campaignsProvider.overrideWith(
              () => _FixedCampaignsNotifier(_testCampaignSamples),
            ),
            hasSampleDataProvider.overrideWith(
              () => _MutableSampleDataNotifier(true),
            ),
          ],
          child: const MaterialApp(home: HomeScreen()),
        ),
      );

      await tester.tap(find.text('Dismiss Samples →'));
      await tester.pumpAndSettle();

      expect(find.text("This will clear the 2 sample campaigns. You'll start with a clean slate."), findsOneWidget);
    });

    testWidgets('dialog has KEEP SAMPLES and START FRESH buttons', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            campaignsProvider.overrideWith(
              () => _FixedCampaignsNotifier(_testCampaignSamples),
            ),
            hasSampleDataProvider.overrideWith(
              () => _MutableSampleDataNotifier(true),
            ),
          ],
          child: const MaterialApp(home: HomeScreen()),
        ),
      );

      await tester.tap(find.text('Dismiss Samples →'));
      await tester.pumpAndSettle();

      expect(find.text('KEEP SAMPLES'), findsOneWidget);
      expect(find.text('START FRESH'), findsOneWidget);
    });

    testWidgets('KEEP SAMPLES closes dialog without changes', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            campaignsProvider.overrideWith(
              () => _FixedCampaignsNotifier(_testCampaignSamples),
            ),
            hasSampleDataProvider.overrideWith(
              () => _MutableSampleDataNotifier(true),
            ),
          ],
          child: const MaterialApp(home: HomeScreen()),
        ),
      );

      await tester.tap(find.text('Dismiss Samples →'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('KEEP SAMPLES'));
      await tester.pumpAndSettle();

      expect(find.text('REMOVE SAMPLE DATA?'), findsNothing);
      expect(find.text('Dismiss Samples →'), findsOneWidget);
    });

    testWidgets('START FRESH dismisses samples', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            campaignsProvider.overrideWith(
              () => _FixedCampaignsNotifier(_testCampaignSamples),
            ),
            hasSampleDataProvider.overrideWith(
              () => _MutableSampleDataNotifier(true),
            ),
          ],
          child: const MaterialApp(home: HomeScreen()),
        ),
      );

      expect(find.text('SAMPLE DATA'), findsOneWidget);

      await tester.tap(find.text('Dismiss Samples →'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('START FRESH'));
      await tester.pumpAndSettle();

      expect(find.text('REMOVE SAMPLE DATA?'), findsNothing);
      expect(find.text('Dismiss Samples →'), findsNothing);
      expect(find.text('SAMPLE DATA'), findsNothing);
      expect(find.text('LIVE DATA'), findsOneWidget);
    });
  });

  group('HomeScreen — Activity Feed with Sample Data', () {
    testWidgets('renders sample campaign names', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            campaignsProvider.overrideWith(
              () => _FixedCampaignsNotifier(_testCampaignSamples),
            ),
            hasSampleDataProvider.overrideWith(
              () => _MutableSampleDataNotifier(true),
            ),
          ],
          child: const MaterialApp(home: HomeScreen()),
        ),
      );

      expect(find.text('Read Daily'), findsWidgets);
      expect(find.text('Exercise 5x/Week'), findsWidgets);
    });

    testWidgets('shows feed icons', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            campaignsProvider.overrideWith(
              () => _FixedCampaignsNotifier(_testCampaignSamples),
            ),
            hasSampleDataProvider.overrideWith(
              () => _MutableSampleDataNotifier(true),
            ),
          ],
          child: const MaterialApp(home: HomeScreen()),
        ),
      );

      expect(find.byIcon(Icons.check_circle), findsWidgets);
      expect(find.byIcon(Icons.radio_button_unchecked), findsWidgets);
    });
  });
}
