import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/mock_data_provider.dart';
import '../theme.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  int _maxStreak(List<bool> history) {
    var best = 0;
    var current = 0;
    for (final day in history) {
      if (day) {
        current++;
        if (current > best) best = current;
      } else {
        current = 0;
      }
    }
    return best;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final campaigns = ref.watch(campaignsProvider);

    final total = campaigns.length;
    final completed =
        campaigns.where((c) => !c.isActive && c.currentDay >= c.totalDays).length;
    final active = campaigns.where((c) => c.isActive).length;
    final abandoned =
        campaigns.where((c) => !c.isActive && c.currentDay < c.totalDays).length;
    final longestStreak = campaigns
        .map((c) => _maxStreak(c.dayHistory))
        .fold(0, (a, b) => a > b ? a : b);
    final completionRate = total == 0 ? 0.0 : completed / total;

    return Scaffold(
      backgroundColor: kBackground,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              backgroundColor: kBlue,
              foregroundColor: kWhite,
              elevation: 0,
              shadowColor: kBlack,
              leading: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: const Icon(Icons.arrow_back, color: kWhite),
              ),
              title: const Text(
                'STATS',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: kWhite,
                  letterSpacing: 1.0,
                ),
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(2),
                child: Container(height: 2, color: kBlack),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // OVERVIEW section
                  _SectionHeader(label: 'Overview'),
                  const SizedBox(height: 8),
                  _StatCard(
                    icon: Icons.bar_chart,
                    value: '$total',
                    label: 'Total Campaigns',
                    desc: 'All campaigns ever created',
                  ),
                  const SizedBox(height: 8),
                  _StatCard(
                    icon: Icons.local_fire_department,
                    valueWidget: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: '$longestStreak',
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w700,
                              color: kBlue,
                              height: 1,
                            ),
                          ),
                          const TextSpan(
                            text: ' DAYS',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: kTextSecondary,
                              height: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                    label: 'Longest Streak',
                    desc: 'Best consecutive check-in run',
                  ),
                  const SizedBox(height: 8),
                  _CompletionRateCard(
                    completionRate: completionRate,
                    completed: completed,
                    total: total,
                  ),
                  const SizedBox(height: 16),
                  // BREAKDOWN section
                  _SectionHeader(label: 'Campaign Breakdown'),
                  const SizedBox(height: 8),
                  _BreakdownRow(
                    dotColor: kBlue,
                    label: 'Completed',
                    count: completed,
                    total: total,
                    barColor: kBlue,
                  ),
                  const SizedBox(height: 8),
                  _BreakdownRow(
                    dotColor: kBackground,
                    label: 'Active',
                    count: active,
                    total: total,
                    barColor: kTextSecondary,
                  ),
                  const SizedBox(height: 8),
                  _BreakdownRow(
                    dotColor: kBlack,
                    label: 'Abandoned',
                    count: abandoned,
                    total: total,
                    barColor: kBlack,
                  ),
                  const SizedBox(height: 24),
                ]),
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

  const _SectionHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 8),
      decoration: const BoxDecoration(
        border: Border(left: BorderSide(color: kBlue, width: 3)),
      ),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.0,
          color: kTextSecondary,
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String? value;
  final Widget? valueWidget;
  final String label;
  final String desc;

  const _StatCard({
    required this.icon,
    this.value,
    this.valueWidget,
    required this.label,
    required this.desc,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: brutalistBox(),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: brutalistBox(color: kBlue, filled: true),
            child: Icon(icon, color: kWhite, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (valueWidget != null)
                  valueWidget!
                else
                  Text(
                    value!,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: kBlue,
                      height: 1,
                    ),
                  ),
                const SizedBox(height: 4),
                Text(
                  label.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.0,
                    color: kTextSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  desc,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: kTextSecondary,
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

class _CompletionRateCard extends StatelessWidget {
  final double completionRate;
  final int completed;
  final int total;

  const _CompletionRateCard({
    required this.completionRate,
    required this.completed,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final percent = (completionRate * 100).round();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: brutalistBox(),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: brutalistBox(color: kBlue, filled: true),
            child: const Icon(Icons.percent, color: kWhite, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$percent%',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: kBlue,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'COMPLETION RATE',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.0,
                    color: kTextSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$completed of $total campaigns completed',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: kTextSecondary,
                  ),
                ),
                const SizedBox(height: 10),
                // Progress bar
                Container(
                  height: 10,
                  decoration: BoxDecoration(
                    color: kBackground,
                    border: Border.all(color: kBlack, width: 2),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: completionRate.clamp(0.0, 1.0),
                    child: Container(color: kBlue),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '0%',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: kTextSecondary,
                      ),
                    ),
                    Text(
                      '$percent% — YOU',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: kTextSecondary,
                      ),
                    ),
                    const Text(
                      '100%',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: kTextSecondary,
                      ),
                    ),
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

class _BreakdownRow extends StatelessWidget {
  final Color dotColor;
  final String label;
  final int count;
  final int total;
  final Color barColor;

  const _BreakdownRow({
    required this.dotColor,
    required this.label,
    required this.count,
    required this.total,
    required this.barColor,
  });

  @override
  Widget build(BuildContext context) {
    final fraction = total == 0 ? 0.0 : (count / total).clamp(0.0, 1.0);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: brutalistBox(),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: dotColor,
              border: Border.all(color: kBlack, width: 2),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label.toUpperCase(),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          ),
          Container(
            width: 100,
            height: 8,
            decoration: BoxDecoration(
              color: kBackground,
              border: Border.all(color: kBlack, width: 2),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: fraction,
              child: Container(color: barColor),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 20,
            child: Text(
              '$count',
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
