import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mtbox_app/models/campaign.dart';
import 'package:mtbox_app/providers/mock_data_provider.dart';
import 'package:mtbox_app/screens/campaign_completion_screen.dart';
import 'package:mtbox_app/screens/campaigns_screen.dart';
import 'package:mtbox_app/theme.dart';

void main() {
  group('CampaignCompletionScreen', () {
    late Campaign completedCampaign;

    setUp(() {
      completedCampaign = Campaign(
        id: 'campaign-1',
        name: 'Read 30 Books',
        goal: 'Complete a reading challenge',
        totalDays: 30,
        currentDay: 30,
        isActive: false,
        dayHistory: List.filled(30, true),
        lastCheckInDate: '2026-04-04',
      );
    });

    Widget buildTestApp({required Campaign campaign}) {
      return ProviderScope(
        overrides: [
          campaignsProvider.overrideWith(
            () => _FixedCampaignsNotifier([campaign]),
          ),
        ],
        child: MaterialApp.router(
          routerConfig: GoRouter(
            routes: [
              GoRoute(
                path: '/campaigns',
                builder: (context, state) => const CampaignsScreen(),
              ),
              GoRoute(
                path: '/campaigns/:id',
                builder: (context, state) => Scaffold(
                  appBar: AppBar(title: const Text('Campaign Detail')),
                  body: const Center(child: Text('Campaign Detail Screen')),
                ),
              ),
              GoRoute(
                path: '/campaigns/:id/complete',
                builder: (context, state) => CampaignCompletionScreen(
                  campaignId: state.pathParameters['id']!,
                ),
              ),
            ],
            initialLocation: '/campaigns/${campaign.id}/complete',
          ),
        ),
      );
    }

    testWidgets('renders all UI elements', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestApp(campaign: completedCampaign));

      // Confetti rows should render
      expect(find.byType(Container), findsWidgets);

      // Campaign name
      expect(find.text('Read 30 Books'), findsOneWidget);

      // Headline
      expect(find.text('GOAL ACHIEVED!'), findsOneWidget);

      // Label
      expect(find.text('CAMPAIGN COMPLETE'), findsOneWidget);

      // Trophy icon
      expect(find.byIcon(Icons.emoji_events), findsOneWidget);

      // Stats row with icons
      expect(find.byIcon(Icons.flag), findsOneWidget); // Days goal
      expect(find.byIcon(Icons.check_circle), findsOneWidget); // Completed
      expect(find.byIcon(Icons.local_fire_department), findsOneWidget); // Streak

      // Buttons
      expect(find.text('BACK TO CAMPAIGNS'), findsOneWidget);
      expect(find.text('VIEW FULL HISTORY'), findsOneWidget);

      // Back button icon
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });

    testWidgets('displays correct stat values', (WidgetTester tester) async {
      final campaign = Campaign(
        id: 'test-1',
        name: 'Test Campaign',
        goal: 'Test',
        totalDays: 5,
        currentDay: 5,
        isActive: false,
        dayHistory: [true, true, true, true, true],
        lastCheckInDate: '2026-04-04',
      );

      await tester.pumpWidget(buildTestApp(campaign: campaign));

      // Stats should show: 5, 5, 5 (goal, completed, streak)
      expect(find.text('5'), findsWidgets);

      // Labels
      expect(find.text('DAYS GOAL'), findsOneWidget);
      expect(find.text('COMPLETED'), findsOneWidget);
      expect(find.text('BEST STREAK'), findsOneWidget);
    });

    testWidgets('has correct background color (blue)', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestApp(campaign: completedCampaign));

      final scaffold = find.byType(Scaffold);
      expect(scaffold, findsOneWidget);

      final scaffoldWidget = tester.widget<Scaffold>(scaffold);
      expect(scaffoldWidget.backgroundColor, equals(kBlue));
    });

    testWidgets('Back to Campaigns button navigates to /campaigns',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestApp(campaign: completedCampaign));

      await tester.tap(find.text('BACK TO CAMPAIGNS'));
      await tester.pumpAndSettle();

      expect(find.byType(CampaignsScreen), findsOneWidget);
    });

    testWidgets('View Full History link navigates to campaign detail',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestApp(campaign: completedCampaign));

      await tester.tap(find.text('VIEW FULL HISTORY'));
      await tester.pumpAndSettle();

      // Should navigate to campaign detail route
      expect(find.text('Campaign Detail Screen'), findsOneWidget);
    });

    testWidgets('displays campaign not found when campaign does not exist',
        (WidgetTester tester) async {
      final testApp = ProviderScope(
        overrides: [
          campaignsProvider.overrideWith(
            () => _FixedCampaignsNotifier([completedCampaign]),
          ),
        ],
        child: MaterialApp(
          home: CampaignCompletionScreen(campaignId: 'nonexistent-id'),
        ),
      );

      await tester.pumpWidget(testApp);

      expect(find.text('Campaign not found'), findsOneWidget);
    });

    testWidgets('campaign name is centered and visible', (WidgetTester tester) async {
      final campaign = Campaign(
        id: 'test-1',
        name: 'My Long Campaign Name That Could Be Long',
        goal: 'Test',
        totalDays: 10,
        currentDay: 10,
        isActive: false,
        dayHistory: List.filled(10, true),
        lastCheckInDate: '2026-04-04',
      );

      await tester.pumpWidget(buildTestApp(campaign: campaign));

      expect(find.text('My Long Campaign Name That Could Be Long'), findsOneWidget);

      // Verify text alignment
      final textWidget = tester.widget<Text>(
        find.text('My Long Campaign Name That Could Be Long'),
      );
      expect(textWidget.textAlign, equals(TextAlign.center));
    });

    testWidgets('trophy icon is rendered with correct size and color',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestApp(campaign: completedCampaign));

      final trophyIcon = find.byIcon(Icons.emoji_events);
      expect(trophyIcon, findsOneWidget);

      final iconWidget = tester.widget<Icon>(trophyIcon);
      expect(iconWidget.size, equals(56));
      expect(iconWidget.color, equals(kBlue));
    });
  });
}

class _FixedCampaignsNotifier extends CampaignsNotifier {
  final List<Campaign> data;

  _FixedCampaignsNotifier(this.data);

  @override
  List<Campaign> build() => List<Campaign>.from(data);
}
