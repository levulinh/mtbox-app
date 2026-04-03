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
    final active = campaigns.where((c) => c.isActive).toList();
    final completed = campaigns.where((c) => !c.isActive).toList();

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
            if (campaigns.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: _EmptyState(),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    if (active.isNotEmpty) ...[
                      _SectionHeader(
                          label: 'ACTIVE', count: active.length),
                      ...active.map((c) => CampaignCard(campaign: c)),
                    ],
                    if (completed.isNotEmpty) ...[
                      if (active.isNotEmpty) const SizedBox(height: 8),
                      _SectionHeader(
                          label: 'COMPLETED', count: completed.length),
                      ...completed.map((c) => CampaignCard(campaign: c)),
                    ],
                  ]),
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: Container(
        width: 52,
        height: 52,
        decoration: brutalistBox(color: kBlue, filled: true),
        child: FloatingActionButton(
          onPressed: null,
          backgroundColor: Colors.transparent,
          elevation: 0,
          shape: const RoundedRectangleBorder(),
          child: const Icon(Icons.add, color: kWhite, size: 28),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;
  final int count;

  const _SectionHeader({required this.label, required this.count});

  @override
  Widget build(BuildContext context) {
    final noun = count == 1 ? 'campaign' : 'campaigns';
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: const BoxDecoration(
        border: Border(left: BorderSide(color: kBlue, width: 3)),
      ),
      padding: const EdgeInsets.only(left: 8),
      child: Text(
        '$label — $count $noun',
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Color(0xFF555555),
          letterSpacing: 1.0,
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 32, 16, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
            decoration: const BoxDecoration(
              color: kWhite,
              border: Border.fromBorderSide(
                BorderSide(color: Color(0xFFCCCCCC), width: 2),
              ),
            ),
            child: Column(
              children: [
                const Icon(Icons.flag_outlined,
                    size: 48, color: Color(0xFFCCCCCC)),
                const SizedBox(height: 12),
                const Text(
                  'NO CAMPAIGNS YET',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: kBlack,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Start your first campaign\nand build a great habit.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF555555),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text(
                      'TAP + TO BEGIN',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: kBlue,
                        letterSpacing: 0.5,
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(Icons.arrow_downward, size: 16, color: kBlue),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
