import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mtbox_app/models/campaign.dart';
import 'package:mtbox_app/providers/mock_data_provider.dart';
import 'package:mtbox_app/screens/share_progress_screen.dart';

class _FixedCampaignsNotifier extends CampaignsNotifier {
  final List<Campaign> _campaigns;
  _FixedCampaignsNotifier(this._campaigns);

  @override
  List<Campaign> build() => _campaigns;
}

void main() {
  group('ShareProgressScreen', () {
    testWidgets('renders app bar with SHARE PROGRESS title',
        (WidgetTester tester) async {
      final campaign = Campaign(
        id: '1',
        name: 'Exercise',
        goal: 'Exercise daily',
        totalDays: 30,
        currentDay: 15,
        isActive: true,
        dayHistory: List.filled(15, true),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            campaignsProvider.overrideWith(() => _FixedCampaignsNotifier([campaign])),
          ],
          child: MaterialApp(
            home: ShareProgressScreen(campaignId: campaign.id),
          ),
        ),
      );

      expect(find.text('SHARE PROGRESS'), findsOneWidget);
    });

    testWidgets('renders close button in app bar', (WidgetTester tester) async {
      final campaign = Campaign(
        id: '1',
        name: 'Exercise',
        goal: 'Exercise daily',
        totalDays: 30,
        currentDay: 15,
        isActive: true,
        dayHistory: List.filled(15, true),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            campaignsProvider.overrideWith(() => _FixedCampaignsNotifier([campaign])),
          ],
          child: MaterialApp(
            home: ShareProgressScreen(campaignId: campaign.id),
          ),
        ),
      );

      expect(find.byIcon(Icons.close), findsOneWidget);
    });

    testWidgets('displays campaign name', (WidgetTester tester) async {
      final campaign = Campaign(
        id: '1',
        name: 'Reading Challenge',
        goal: 'Read 10 books',
        totalDays: 60,
        currentDay: 30,
        isActive: true,
        dayHistory: List.filled(30, true),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            campaignsProvider.overrideWith(() => _FixedCampaignsNotifier([campaign])),
          ],
          child: MaterialApp(
            home: ShareProgressScreen(campaignId: campaign.id),
          ),
        ),
      );

      expect(find.text('READING CHALLENGE'), findsOneWidget);
    });

    testWidgets('displays progress percentage', (WidgetTester tester) async {
      final campaign = Campaign(
        id: '1',
        name: 'Exercise',
        goal: 'Exercise daily',
        totalDays: 100,
        currentDay: 50,
        isActive: true,
        dayHistory: List.filled(50, true),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            campaignsProvider.overrideWith(() => _FixedCampaignsNotifier([campaign])),
          ],
          child: MaterialApp(
            home: ShareProgressScreen(campaignId: campaign.id),
          ),
        ),
      );

      expect(find.text('50'), findsOneWidget);
    });

    testWidgets('displays day count', (WidgetTester tester) async {
      final campaign = Campaign(
        id: '1',
        name: 'Exercise',
        goal: 'Exercise daily',
        totalDays: 30,
        currentDay: 10,
        isActive: true,
        dayHistory: List.filled(10, true),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            campaignsProvider.overrideWith(() => _FixedCampaignsNotifier([campaign])),
          ],
          child: MaterialApp(
            home: ShareProgressScreen(campaignId: campaign.id),
          ),
        ),
      );

      expect(find.text('10 / 30'), findsOneWidget);
      expect(find.text('DAYS COMPLETE'), findsOneWidget);
    });

    testWidgets('renders SAVE button', (WidgetTester tester) async {
      final campaign = Campaign(
        id: '1',
        name: 'Exercise',
        goal: 'Exercise daily',
        totalDays: 30,
        currentDay: 15,
        isActive: true,
        dayHistory: List.filled(15, true),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            campaignsProvider.overrideWith(() => _FixedCampaignsNotifier([campaign])),
          ],
          child: MaterialApp(
            home: ShareProgressScreen(campaignId: campaign.id),
          ),
        ),
      );

      expect(find.text('SAVE'), findsOneWidget);
      expect(find.byIcon(Icons.download), findsOneWidget);
    });

    testWidgets('renders SHARE NOW button', (WidgetTester tester) async {
      final campaign = Campaign(
        id: '1',
        name: 'Exercise',
        goal: 'Exercise daily',
        totalDays: 30,
        currentDay: 15,
        isActive: true,
        dayHistory: List.filled(15, true),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            campaignsProvider.overrideWith(() => _FixedCampaignsNotifier([campaign])),
          ],
          child: MaterialApp(
            home: ShareProgressScreen(campaignId: campaign.id),
          ),
        ),
      );

      expect(find.text('SHARE NOW'), findsOneWidget);
      expect(find.byIcon(Icons.ios_share), findsOneWidget);
    });

    testWidgets('displays PREVIEW section label', (WidgetTester tester) async {
      final campaign = Campaign(
        id: '1',
        name: 'Exercise',
        goal: 'Exercise daily',
        totalDays: 30,
        currentDay: 15,
        isActive: true,
        dayHistory: List.filled(15, true),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            campaignsProvider.overrideWith(() => _FixedCampaignsNotifier([campaign])),
          ],
          child: MaterialApp(
            home: ShareProgressScreen(campaignId: campaign.id),
          ),
        ),
      );

      expect(find.text('PREVIEW'), findsOneWidget);
    });

    testWidgets('shows MTBox branding on card', (WidgetTester tester) async {
      final campaign = Campaign(
        id: '1',
        name: 'Exercise',
        goal: 'Exercise daily',
        totalDays: 30,
        currentDay: 15,
        isActive: true,
        dayHistory: List.filled(15, true),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            campaignsProvider.overrideWith(() => _FixedCampaignsNotifier([campaign])),
          ],
          child: MaterialApp(
            home: ShareProgressScreen(campaignId: campaign.id),
          ),
        ),
      );

      expect(find.text('MTBOX'), findsOneWidget);
      expect(find.text('CAMPAIGN TRACKER'), findsOneWidget);
      expect(find.byIcon(Icons.bolt), findsOneWidget);
    });

    testWidgets('shows campaign day challenge text', (WidgetTester tester) async {
      final campaign = Campaign(
        id: '1',
        name: 'Exercise',
        goal: 'Exercise daily',
        totalDays: 30,
        currentDay: 15,
        isActive: true,
        dayHistory: List.filled(15, true),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            campaignsProvider.overrideWith(() => _FixedCampaignsNotifier([campaign])),
          ],
          child: MaterialApp(
            home: ShareProgressScreen(campaignId: campaign.id),
          ),
        ),
      );

      expect(find.text('30-Day Challenge'), findsOneWidget);
    });

    testWidgets('handles campaign not found gracefully',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            campaignsProvider.overrideWith(() => _FixedCampaignsNotifier([])),
          ],
          child: MaterialApp(
            home: ShareProgressScreen(campaignId: 'nonexistent'),
          ),
        ),
      );

      expect(find.text('Campaign not found'), findsOneWidget);
    });

    testWidgets('progress percentage updates with different values',
        (WidgetTester tester) async {
      // Test 50% progress
      final campaign50 = Campaign(
        id: 'test_50',
        name: 'Test',
        goal: 'Test goal',
        totalDays: 30,
        currentDay: 15,
        isActive: true,
        dayHistory: List.filled(15, true),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            campaignsProvider.overrideWith(() => _FixedCampaignsNotifier([campaign50])),
          ],
          child: MaterialApp(
            home: ShareProgressScreen(campaignId: campaign50.id),
          ),
        ),
      );

      expect(find.text('50'), findsOneWidget);
    });
  });
}
