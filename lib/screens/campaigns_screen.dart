import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/mock_data_provider.dart';
import '../theme.dart';
import '../widgets/campaign_card.dart';

class CampaignsScreen extends ConsumerWidget {
  const CampaignsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final campaigns = ref.watch(campaignsProvider);

    return Scaffold(
      backgroundColor: kBackground,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            const SliverAppBar(
              pinned: false,
              backgroundColor: kBackground,
              expandedHeight: 70,
              flexibleSpace: FlexibleSpaceBar(
                titlePadding:
                    EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                title: Text(
                  'CAMPAIGNS',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: kBlack,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => CampaignCard(campaign: campaigns[index]),
                  childCount: campaigns.length,
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Container(
        decoration: brutalistBox(color: kBlue, filled: true),
        child: FloatingActionButton.extended(
          onPressed: null,
          backgroundColor: Colors.transparent,
          elevation: 0,
          shape: const RoundedRectangleBorder(),
          icon: const Icon(Icons.add, color: kWhite),
          label: const Text(
            'START NEW CAMPAIGN',
            style: TextStyle(
              color: kWhite,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
          ),
        ),
      ),
    );
  }
}
