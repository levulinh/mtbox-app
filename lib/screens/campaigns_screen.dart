import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/mock_data_provider.dart';
import '../providers/sync_provider.dart';
import '../theme.dart';
import '../widgets/campaign_card.dart';

class CampaignsScreen extends ConsumerStatefulWidget {
  const CampaignsScreen({super.key});

  @override
  ConsumerState<CampaignsScreen> createState() => _CampaignsScreenState();
}

class _CampaignsScreenState extends ConsumerState<CampaignsScreen> {
  String? _toastMessage;
  Timer? _toastTimer;

  @override
  void dispose() {
    _toastTimer?.cancel();
    super.dispose();
  }

  void _handleCheckIn(String campaignId) {
    final completed =
        ref.read(campaignsProvider.notifier).checkIn(campaignId);
    if (completed) {
      context.push('/campaigns/$campaignId/complete');
      return;
    }
    final updated = ref
        .read(campaignsProvider)
        .firstWhere((c) => c.id == campaignId);
    _toastTimer?.cancel();
    setState(() {
      _toastMessage =
          'Day ${updated.currentDay} checked in! Streak: ${updated.currentStreak} days';
    });
    _toastTimer = Timer(const Duration(milliseconds: 2500), () {
      if (mounted) setState(() => _toastMessage = null);
    });
  }

  @override
  Widget build(BuildContext context) {
    final campaigns = ref.watch(campaignsProvider);
    final syncState = ref.watch(syncStateProvider);
    final isOffline = syncState.phase == SyncPhase.offline;
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
                    if (_toastMessage != null) _CheckInToast(message: _toastMessage!),
                    if (active.isNotEmpty) ...[
                      _SectionHeader(label: 'ACTIVE', count: active.length),
                      ...active.map((c) => CampaignCard(
                            campaign: c,
                            onCheckIn: () => _handleCheckIn(c.id),
                            isPendingSync: isOffline && c.checkedInToday,
                          )),
                    ],
                    if (completed.isNotEmpty) ...[
                      if (active.isNotEmpty) const SizedBox(height: 8),
                      _ArchiveBanner(),
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
          onPressed: () => context.push('/campaigns/new'),
          backgroundColor: Colors.transparent,
          elevation: 0,
          shape: const RoundedRectangleBorder(),
          child: const Icon(Icons.add, color: kWhite, size: 28),
        ),
      ),
    );
  }
}

class _CheckInToast extends StatefulWidget {
  final String message;

  const _CheckInToast({required this.message});

  @override
  State<_CheckInToast> createState() => _CheckInToastState();
}

class _CheckInToastState extends State<_CheckInToast>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<Offset> _slide;
  late final Animation<double> _fade;

  // Confetti color palette using app colors
  static const _confettiColors = [
    kBlue,
    kWhite,
    Color(0xFFFFD700), // gold
    Color(0xFFB5735A), // terracotta
    Color(0xFF4AFF91), // green
  ];

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _slide = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slide,
      child: FadeTransition(
        opacity: _fade,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Confetti row
            SizedBox(
              height: 12,
              child: Row(
                children: List.generate(24, (i) {
                  final color =
                      _confettiColors[i % _confettiColors.length];
                  return Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 1),
                      color: color,
                    ),
                  );
                }),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: const BoxDecoration(
                color: kBlack,
                border: Border(
                  left: BorderSide(color: kBlue, width: 4),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: kBlue, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.message.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: kWhite,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
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
          color: kTextSecondary,
          letterSpacing: 1.0,
        ),
      ),
    );
  }
}

class _ArchiveBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/archive'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: brutalistBox(),
        child: Row(
          children: const [
            Icon(Icons.emoji_events, size: 20, color: kBlue),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'VIEW COMPLETED CAMPAIGNS',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: kBlack,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            Text(
              'ARCHIVE',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: kBlue,
                letterSpacing: 0.5,
              ),
            ),
            SizedBox(width: 2),
            Icon(Icons.chevron_right, size: 16, color: kBlue),
          ],
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
                    color: kTextSecondary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () => context.push('/campaigns/new'),
                  child: Container(
                    height: 48,
                    decoration: const BoxDecoration(
                      color: kBlue,
                      border: Border.fromBorderSide(
                        BorderSide(color: kBlack, width: kBorderWidth),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: kBlack,
                          offset: Offset(kShadowOffset, kShadowOffset),
                          blurRadius: 0,
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add, color: kWhite, size: 18),
                        SizedBox(width: 8),
                        Text(
                          'START A CAMPAIGN',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: kWhite,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
