import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/campaign.dart';
import '../providers/mock_data_provider.dart';
import '../theme.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String? _toastMessage;

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
    setState(() {
      _toastMessage =
          'Day ${updated.currentDay} checked in! Streak: ${updated.currentStreak} days';
    });
  }

  @override
  Widget build(BuildContext context) {
    final campaigns = ref.watch(campaignsProvider);
    final active = campaigns.where((c) => c.isActive).toList();
    final doneToday = active.where((c) => c.checkedInToday).length;
    final bestStreak = campaigns.isEmpty
        ? 0
        : campaigns.map((c) => c.currentStreak).reduce((a, b) => a > b ? a : b);

    return Scaffold(
      backgroundColor: kBackground,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              backgroundColor: kBlue,
              expandedHeight: 56,
              flexibleSpace: FlexibleSpaceBar(
                titlePadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                title: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'HOME',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: kWhite,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: const Color(0xFF4AFF91),
                            border: Border.all(
                              color: Colors.black.withAlpha(77),
                              width: 1,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          'LIVE DATA',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: kWhite,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(2),
                child: Container(height: 2, color: kBlack),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Today section header
                  _SectionHeader(label: _formatDateHeader(DateTime.now())),
                  const SizedBox(height: 10),
                  // Today summary card
                  _TodaySummaryCard(
                    activeCampaigns: active.length,
                    doneToday: doneToday,
                    bestStreak: bestStreak,
                  ),
                  const SizedBox(height: 16),
                  // Active campaigns header
                  _SectionHeader(
                    label: 'Active Campaigns (${active.length})',
                  ),
                  const SizedBox(height: 10),
                  // Toast message
                  if (_toastMessage != null) _CheckInToast(message: _toastMessage!),
                  // Active campaign cards or empty state
                  if (active.isEmpty)
                    _EmptyActiveCampaigns()
                  else
                    ...active.map(
                      (c) => _HomeCampaignCard(
                        campaign: c,
                        onCheckIn: () => _handleCheckIn(c.id),
                      ),
                    ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateHeader(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return 'Today — ${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}

// ---------------------------------------------------------------------------
// Section header with blue left border
// ---------------------------------------------------------------------------
class _SectionHeader extends StatelessWidget {
  final String label;

  const _SectionHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(left: BorderSide(color: kBlue, width: 3)),
      ),
      padding: const EdgeInsets.only(left: 8),
      child: Text(
        label,
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

// ---------------------------------------------------------------------------
// Today summary card
// ---------------------------------------------------------------------------
class _TodaySummaryCard extends StatelessWidget {
  final int activeCampaigns;
  final int doneToday;
  final int bestStreak;

  const _TodaySummaryCard({
    required this.activeCampaigns,
    required this.doneToday,
    required this.bestStreak,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: brutalistBox(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'YOUR ACTIVITY AT A GLANCE',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Color(0xFF555555),
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _StatCell(
                icon: Icons.flag,
                value: '$activeCampaigns',
                label: 'Active',
              ),
              const SizedBox(width: 8),
              _StatCell(
                icon: Icons.check_circle,
                value: '$doneToday',
                label: 'Done Today',
              ),
              const SizedBox(width: 8),
              _StatCell(
                icon: Icons.local_fire_department,
                value: '$bestStreak',
                label: 'Best Streak',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatCell extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _StatCell({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: const BoxDecoration(
          border: Border.fromBorderSide(
            BorderSide(color: kBlack, width: kBorderWidth),
          ),
        ),
        child: Column(
          children: [
            Icon(icon, size: 16, color: kBlue),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: kBlue,
              ),
            ),
            Text(
              label.toUpperCase(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: Color(0xFF555555),
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Home campaign card (compact, with check-in + detail chevron)
// ---------------------------------------------------------------------------
class _HomeCampaignCard extends StatelessWidget {
  final Campaign campaign;
  final VoidCallback? onCheckIn;

  const _HomeCampaignCard({required this.campaign, this.onCheckIn});

  @override
  Widget build(BuildContext context) {
    final pct = (campaign.progressPercent * 100).round();
    final checkedIn = campaign.checkedInToday;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: brutalistBox(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title row + badge
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  campaign.name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: kBlack,
                  ),
                ),
              ),
              // Badge: "Done Today" (green) or "Active" (blue)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: checkedIn ? const Color(0xFF4AFF91) : kBlue,
                  border: Border.all(color: kBlack, width: kBorderWidth),
                ),
                child: Text(
                  checkedIn ? 'DONE TODAY' : 'ACTIVE',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    color: checkedIn ? kBlack : kWhite,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          // Day progress label
          Text(
            'Day ${campaign.currentDay} of ${campaign.totalDays} — $pct%',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Color(0xFF555555),
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 6),
          // Progress bar
          Container(
            height: 10,
            decoration: const BoxDecoration(
              color: kWhite,
              border: Border.fromBorderSide(
                BorderSide(color: kBlack, width: kBorderWidth),
              ),
            ),
            child: FractionallySizedBox(
              widthFactor: campaign.progressPercent.clamp(0.0, 1.0),
              alignment: Alignment.centerLeft,
              child: Container(color: kBlue),
            ),
          ),
          const SizedBox(height: 6),
          // Day tick strip
          _DayTicks(
            totalDays: campaign.totalDays,
            dayHistory: campaign.dayHistory,
          ),
          const SizedBox(height: 10),
          // Action row: check-in button + detail chevron
          Row(
            children: [
              Expanded(
                child: checkedIn
                    ? _ConfirmedRow()
                    : _CheckInBtn(onTap: onCheckIn),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => context.push('/campaigns/${campaign.id}'),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: brutalistBox(),
                  alignment: Alignment.center,
                  child: const Icon(Icons.chevron_right,
                      size: 18, color: Color(0xFF555555)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DayTicks extends StatelessWidget {
  final int totalDays;
  final List<bool> dayHistory;

  const _DayTicks({required this.totalDays, required this.dayHistory});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(totalDays, (i) {
        final bool done = i < dayHistory.length && dayHistory[i];
        final bool future = i >= dayHistory.length;

        final Color tickColor = done
            ? kBlue
            : future
                ? const Color(0xFFF0F0F0)
                : kWhite;
        final Color borderColor =
            future ? const Color(0xFFCCCCCC) : kBlack;

        return Expanded(
          child: Container(
            height: 10,
            margin: const EdgeInsets.symmetric(horizontal: 1),
            decoration: BoxDecoration(
              color: tickColor,
              border: Border.all(color: borderColor, width: 1),
            ),
          ),
        );
      }),
    );
  }
}

class _CheckInBtn extends StatelessWidget {
  final VoidCallback? onTap;

  const _CheckInBtn({this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 40,
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
            Icon(Icons.add_task, color: kWhite, size: 16),
            SizedBox(width: 6),
            Text(
              'CHECK IN',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: kWhite,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConfirmedRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      decoration: const BoxDecoration(
        color: kWhite,
        border: Border.fromBorderSide(
          BorderSide(color: kBlack, width: kBorderWidth),
        ),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle, color: kBlue, size: 16),
          SizedBox(width: 6),
          Text(
            'CHECKED IN',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: kBlack,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Empty state when no active campaigns
// ---------------------------------------------------------------------------
class _EmptyActiveCampaigns extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: const BoxDecoration(
        color: kWhite,
        border: Border.fromBorderSide(
          BorderSide(color: Color(0xFFCCCCCC), width: 2),
        ),
      ),
      child: const Column(
        children: [
          Icon(Icons.flag_outlined, size: 40, color: Color(0xFFCCCCCC)),
          SizedBox(height: 8),
          Text(
            'NO ACTIVE CAMPAIGNS',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: kBlack,
              letterSpacing: 0.5,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Go to Campaigns to start one.',
            style: TextStyle(fontSize: 12, color: Color(0xFF555555)),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Check-in toast
// ---------------------------------------------------------------------------
class _CheckInToast extends StatelessWidget {
  final String message;

  const _CheckInToast({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
              message.toUpperCase(),
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
    );
  }
}
