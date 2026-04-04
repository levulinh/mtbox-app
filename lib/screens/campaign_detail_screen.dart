import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/campaign.dart';
import '../providers/mock_data_provider.dart';
import '../theme.dart';
import '../widgets/stat_card.dart';

class CampaignDetailScreen extends ConsumerWidget {
  final String campaignId;

  const CampaignDetailScreen({super.key, required this.campaignId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final campaigns = ref.watch(campaignsProvider);
    Campaign? campaign;
    try {
      campaign = campaigns.firstWhere((c) => c.id == campaignId);
    } catch (_) {}

    if (campaign == null) {
      return const Scaffold(
        body: Center(child: Text('Campaign not found')),
      );
    }

    final pct = (campaign.progressPercent * 100).round();
    final remaining = campaign.totalDays - campaign.currentDay;

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
        title: Text(
          campaign.name.toUpperCase(),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: kWhite,
            letterSpacing: 0.5,
          ),
        ),
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
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Stats row
                  Row(
                    children: [
                      StatCard(
                        label: 'Day Streak',
                        value: '${campaign.currentStreak}',
                        icon: Icons.local_fire_department,
                      ),
                      const SizedBox(width: 8),
                      StatCard(
                        label: 'Completed',
                        value: '${campaign.completedDays}',
                        icon: Icons.check_circle,
                      ),
                      const SizedBox(width: 8),
                      StatCard(
                        label: 'Goal Days',
                        value: '${campaign.totalDays}',
                        icon: Icons.flag,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Progress section
                  _SectionLabel(label: 'Progress'),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: brutalistBox(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          '${campaign.currentDay} of ${campaign.totalDays} days — $pct%',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: kTextSecondary,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        _DetailProgressBar(percent: campaign.progressPercent),
                        const SizedBox(height: 4),
                        Text(
                          '$remaining days remaining',
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: kTextSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Day grid
                  _SectionLabel(label: 'Campaign Days'),
                  _DayGrid(campaign: campaign),
                  const SizedBox(height: 16),

                  // Recent Activity
                  _SectionLabel(label: 'Recent Activity'),
                  _ActivityList(campaign: campaign),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;

  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: const BoxDecoration(
        border: Border(left: BorderSide(color: kBlue, width: 3)),
      ),
      padding: const EdgeInsets.only(left: 8),
      child: Text(
        label.toUpperCase(),
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

class _DetailProgressBar extends StatelessWidget {
  final double percent;

  const _DetailProgressBar({required this.percent});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 10,
      decoration: const BoxDecoration(
        color: kBackground,
        border: Border.fromBorderSide(
          BorderSide(color: kBlack, width: 2),
        ),
      ),
      child: FractionallySizedBox(
        widthFactor: percent.clamp(0.0, 1.0),
        alignment: Alignment.centerLeft,
        child: Container(color: kBlue),
      ),
    );
  }
}

class _DayGrid extends StatelessWidget {
  final Campaign campaign;

  const _DayGrid({required this.campaign});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: brutalistBox(),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 7,
          mainAxisSpacing: 2,
          crossAxisSpacing: 2,
          childAspectRatio: 1,
        ),
        itemCount: campaign.totalDays,
        itemBuilder: (context, i) {
          final dayNumber = i + 1;
          final isToday = dayNumber == campaign.currentDay;
          final isFuture = dayNumber > campaign.currentDay;
          final isDone = !isFuture && campaign.dayHistory[i];

          Color bg;
          Color borderColor;
          Color textColor;
          double borderWidth = 1;

          if (isFuture) {
            bg = const Color(0xFFF0F0F0);
            borderColor = const Color(0xFFE0E0E0);
            textColor = const Color(0xFF999999);
          } else if (isDone) {
            bg = kBlue;
            borderColor = kBlue;
            textColor = kWhite;
          } else {
            bg = kWhite;
            borderColor = const Color(0xFFCCCCCC);
            textColor = const Color(0xFFCCCCCC);
          }

          if (isToday) {
            borderColor = kBlack;
            borderWidth = 2;
          }

          return Container(
            decoration: BoxDecoration(
              color: bg,
              border: Border.all(color: borderColor, width: borderWidth),
            ),
            child: Center(
              child: Text(
                '$dayNumber',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ActivityList extends StatelessWidget {
  final Campaign campaign;

  const _ActivityList({required this.campaign});

  String _dayLabel(int daysAgo) {
    if (daysAgo == 0) return 'Today';
    if (daysAgo == 1) return 'Yesterday';
    final date = DateTime.now().subtract(Duration(days: daysAgo));
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}';
  }

  @override
  Widget build(BuildContext context) {
    final indices = List.generate(campaign.dayHistory.length, (i) => i)
        .reversed
        .toList();

    return Container(
      decoration: brutalistBox(),
      child: Column(
        children: List.generate(indices.length, (listIdx) {
          final i = indices[listIdx];
          final dayNumber = i + 1;
          final isDone = campaign.dayHistory[i];
          final daysAgo = campaign.currentDay - dayNumber;
          final isLast = listIdx == indices.length - 1;

          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: isLast
                ? null
                : const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Color(0xFFE0E0E0), width: 1),
                    ),
                  ),
            child: Row(
              children: [
                Icon(
                  isDone ? Icons.check_circle : Icons.radio_button_unchecked,
                  size: 20,
                  color: isDone ? kBlue : const Color(0xFFCCCCCC),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _dayLabel(daysAgo),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: kBlack,
                        ),
                      ),
                      Text(
                        'DAY $dayNumber',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: kTextSecondary,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  isDone ? 'DONE' : 'MISSED',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                    color: isDone ? kBlue : const Color(0xFFCCCCCC),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
