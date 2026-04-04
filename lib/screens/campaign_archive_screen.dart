import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/campaign.dart';
import '../providers/mock_data_provider.dart';
import '../theme.dart';

class CampaignArchiveScreen extends ConsumerWidget {
  const CampaignArchiveScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final campaigns = ref.watch(campaignsProvider);
    final completed = campaigns.where((c) => !c.isActive).toList();

    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppBar(
        backgroundColor: kBlue,
        foregroundColor: kWhite,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'ARCHIVE',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: kWhite,
            letterSpacing: 1.0,
          ),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(Icons.emoji_events,
                color: Color(0x99FFFFFF), size: 20),
          ),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(2),
          child: DecoratedBox(
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: kBlack, width: 2)),
            ),
            child: SizedBox(height: 2, width: double.infinity),
          ),
        ),
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Summary banner
                  _SummaryBanner(count: completed.length),
                  const SizedBox(height: 16),

                  // Section header
                  if (completed.isNotEmpty) ...[
                    Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: const BoxDecoration(
                        border: Border(
                            left: BorderSide(color: kBlue, width: 3)),
                      ),
                      padding: const EdgeInsets.only(left: 8),
                      child: Text(
                        'COMPLETED CAMPAIGNS — ${completed.length}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: kTextSecondary,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                    ...completed.map((c) => _ArchiveCard(campaign: c)),
                  ] else
                    _EmptyArchive(),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryBanner extends StatelessWidget {
  final int count;

  const _SummaryBanner({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: brutalistBox(),
      child: Row(
        children: [
          const Icon(Icons.emoji_events, size: 28, color: kBlue),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$count',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: kBlue,
                  height: 1,
                ),
              ),
              const Text(
                'CAMPAIGNS COMPLETED',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: kTextSecondary,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ArchiveCard extends StatelessWidget {
  final Campaign campaign;

  const _ArchiveCard({required this.campaign});

  String _dateRange() {
    if (campaign.lastCheckInDate == null) return 'Completed';
    final parts = campaign.lastCheckInDate!.split('-');
    final end = DateTime(
      int.parse(parts[0]),
      int.parse(parts[1]),
      int.parse(parts[2]),
    );
    final start = end.subtract(Duration(days: campaign.totalDays - 1));
    return '${_fmt(start)} – ${_fmt(end)}';
  }

  static String _fmt(DateTime d) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[d.month - 1]} ${d.day}, ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    final pct = campaign.completedDays / campaign.totalDays;
    final pctLabel = '${(pct * 100).round()}%';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: brutalistBox(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header: name + COMPLETED badge
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
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 7, vertical: 3),
                color: kBlack,
                child: const Text(
                  'COMPLETED',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    color: kWhite,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Progress bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Day ${campaign.totalDays} of ${campaign.totalDays}',
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: kTextSecondary,
                  letterSpacing: 0.5,
                ),
              ),
              Text(
                pctLabel,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: kTextSecondary,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Container(
            height: 10,
            decoration: const BoxDecoration(
              color: kBackground,
              border:
                  Border.fromBorderSide(BorderSide(color: kSoftBorderColor, width: kSoftBorderWidth)),
            ),
            child: FractionallySizedBox(
              widthFactor: pct.clamp(0.0, 1.0),
              alignment: Alignment.centerLeft,
              child: Container(color: kBlack),
            ),
          ),
          const SizedBox(height: 8),

          // Day ticks
          _DayTicks(dayHistory: campaign.dayHistory),
          const SizedBox(height: 10),

          // Meta row
          Container(
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: kBlack, width: 1)),
            ),
            padding: const EdgeInsets.only(top: 10),
            child: Row(
              children: [
                _MetaCell(
                  icon: Icons.flag,
                  value: '${campaign.totalDays}',
                  label: 'Goal Days',
                ),
                _MetaCell(
                  icon: Icons.check_circle,
                  value: '${campaign.completedDays}',
                  label: 'Completed',
                ),
                _MetaCell(
                  icon: Icons.local_fire_department,
                  value: '${campaign.bestStreak}',
                  label: 'Best Streak',
                  isLast: true,
                ),
              ],
            ),
          ),

          // Footer: date range + view details
          Container(
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: kBlack, width: 1)),
            ),
            padding: const EdgeInsets.only(top: 10),
            margin: const EdgeInsets.only(top: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _dateRange(),
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: kTextSecondary,
                    letterSpacing: 0.5,
                  ),
                ),
                GestureDetector(
                  onTap: () => context.push('/campaigns/${campaign.id}'),
                  child: const Row(
                    children: [
                      Text(
                        'VIEW DETAILS',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: kBlue,
                          letterSpacing: 0.5,
                        ),
                      ),
                      SizedBox(width: 2),
                      Icon(Icons.chevron_right, size: 14, color: kBlue),
                    ],
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

class _DayTicks extends StatelessWidget {
  final List<bool> dayHistory;

  const _DayTicks({required this.dayHistory});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: dayHistory
          .map((done) => Expanded(
                child: Container(
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 1),
                  decoration: BoxDecoration(
                    color: done ? kBlack : kWhite,
                    border: Border.all(color: kBlack, width: 1),
                  ),
                ),
              ))
          .toList(),
    );
  }
}

class _MetaCell extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final bool isLast;

  const _MetaCell({
    required this.icon,
    required this.value,
    required this.label,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        decoration: isLast
            ? null
            : const BoxDecoration(
                border:
                    Border(right: BorderSide(color: kBlack, width: 1))),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 13, color: kBlue),
                const SizedBox(width: 3),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: kBlack,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              label.toUpperCase(),
              style: const TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: kTextSecondary,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyArchive extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
      decoration: const BoxDecoration(
        color: kWhite,
        border: Border.fromBorderSide(
          BorderSide(color: Color(0xFFCCCCCC), width: 2),
        ),
      ),
      child: Column(
        children: const [
          Icon(Icons.emoji_events_outlined,
              size: 48, color: Color(0xFFCCCCCC)),
          SizedBox(height: 12),
          Text(
            'NO COMPLETED CAMPAIGNS',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: kBlack,
              letterSpacing: 0.5,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Complete a campaign to see it here.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: kTextSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
