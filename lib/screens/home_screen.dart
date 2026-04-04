import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/activity_entry.dart';
import '../providers/mock_data_provider.dart';
import '../theme.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final campaigns = ref.watch(campaignsProvider);
    final feed = ref.watch(activityFeedProvider);

    final active = campaigns.where((c) => c.isActive).toList();
    final doneToday = active.where((c) => c.checkedInToday).length;
    final bestStreak = campaigns.isEmpty
        ? 0
        : campaigns
            .map((c) => c.currentStreak)
            .reduce((a, b) => a > b ? a : b);

    final groups = _buildDateGroups(feed);

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
                    Expanded(
                      child: RichText(
                        text: const TextSpan(
                          text: 'HEY ',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: kWhite,
                            letterSpacing: 0.5,
                          ),
                          children: [
                            TextSpan(
                              text: 'DREW',
                              style: TextStyle(color: Color(0xFF4AFF91)),
                            ),
                          ],
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
                  // Real-time sync notice
                  _RealTimeNotice(),
                  const SizedBox(height: 16),
                  // RECENT ACTIVITY section header
                  _SectionHeader(
                    label: 'RECENT ACTIVITY (${feed.length} entries)',
                  ),
                  const SizedBox(height: 10),
                  // Date-grouped feed
                  if (feed.isEmpty)
                    _EmptyFeed()
                  else
                    ...groups.map(
                      (group) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _FeedGroup(
                          dateLabel: group.$1,
                          entries: group.$2,
                        ),
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

  /// Groups feed entries (already sorted most-recent-first) into (label, entries)
  /// tuples, one per distinct calendar day.
  List<(String, List<ActivityEntry>)> _buildDateGroups(
      List<ActivityEntry> entries) {
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final groups = <(String, List<ActivityEntry>)>[];
    DateTime? currentDay;

    for (final entry in entries) {
      final entryDay =
          DateTime(entry.date.year, entry.date.month, entry.date.day);
      if (currentDay == null || entryDay != currentDay) {
        currentDay = entryDay;
        groups.add((_dateGroupLabel(entryDay, todayDate), [entry]));
      } else {
        groups.last.$2.add(entry);
      }
    }
    return groups;
  }

  String _dateGroupLabel(DateTime day, DateTime today) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final diff = today.difference(day).inDays;
    if (diff == 0) return 'Today — ${months[day.month - 1]} ${day.day}';
    if (diff == 1) return 'Yesterday — ${months[day.month - 1]} ${day.day}';
    return '${months[day.month - 1]} ${day.day}';
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
          color: kTextSecondary,
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
              color: kTextSecondary,
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
            BorderSide(color: kSoftBorderColor, width: kSoftBorderWidth),
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

// ---------------------------------------------------------------------------
// Real-time sync notice bar
// ---------------------------------------------------------------------------
class _RealTimeNotice extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: const BoxDecoration(
        color: Color(0xFFE4EAF4),
        border: Border.fromBorderSide(
          BorderSide(color: kBlue, width: kSoftBorderWidth),
        ),
      ),
      child: const Row(
        children: [
          Icon(Icons.sync, size: 14, color: kBlue),
          SizedBox(width: 6),
          Expanded(
            child: Text(
              'FEED UPDATES LIVE — NEW CHECK-INS APPEAR INSTANTLY',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: kBlue,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Date group card (header + entries)
// ---------------------------------------------------------------------------
class _FeedGroup extends StatelessWidget {
  final String dateLabel;
  final List<ActivityEntry> entries;

  const _FeedGroup({required this.dateLabel, required this.entries});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: brutalistBox(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Date group header
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            color: kBlack,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  dateLabel.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: kWhite,
                    letterSpacing: 1.0,
                  ),
                ),
                Text(
                  '${entries.length} ${entries.length == 1 ? 'entry' : 'entries'}',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFAAAAAA),
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          // Feed entries
          ...entries.asMap().entries.map((e) {
            final isLast = e.key == entries.length - 1;
            return _FeedEntry(entry: e.value, showDivider: !isLast);
          }),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Single feed entry row
// ---------------------------------------------------------------------------
class _FeedEntry extends StatelessWidget {
  final ActivityEntry entry;
  final bool showDivider;

  const _FeedEntry({required this.entry, required this.showDivider});

  @override
  Widget build(BuildContext context) {
    final isDone = entry.completed;
    final isPending = entry.isPending;

    return Container(
      decoration: showDivider
          ? const BoxDecoration(
              border: Border(
                  bottom: BorderSide(color: Color(0xFFE0E0E0), width: 1)),
            )
          : null,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          Icon(
            isDone ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 20,
            color: isDone ? kBlue : const Color(0xFFBDBDBD),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.campaignName,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: kBlack,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 1),
                Text(
                  entry.dayNumber > 0 && entry.totalDays > 0
                      ? (isPending
                          ? 'Not checked in yet · Day ${entry.dayNumber} of ${entry.totalDays}'
                          : 'Day ${entry.dayNumber} of ${entry.totalDays}')
                      : (isPending ? 'Not checked in yet' : ''),
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: kTextSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _StatusBadge(
            isDone: isDone,
            isPending: isPending,
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final bool isDone;
  final bool isPending;

  const _StatusBadge({required this.isDone, required this.isPending});

  @override
  Widget build(BuildContext context) {
    final String label;
    final Color bg;
    final Color fg;
    final Color border;

    if (isDone) {
      label = 'DONE';
      bg = kBlue;
      fg = kWhite;
      border = kBlue;
    } else if (isPending) {
      label = 'PENDING';
      bg = kWhite;
      fg = kTextSecondary;
      border = const Color(0xFFBDBDBD);
    } else {
      label = 'MISSED';
      bg = kWhite;
      fg = kTextSecondary;
      border = const Color(0xFFBDBDBD);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        border: Border.all(color: border, width: kSoftBorderWidth),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w700,
          color: fg,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Empty state when feed has no entries
// ---------------------------------------------------------------------------
class _EmptyFeed extends StatelessWidget {
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
          Icon(Icons.history, size: 40, color: Color(0xFFCCCCCC)),
          SizedBox(height: 8),
          Text(
            'NO ACTIVITY YET',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: kBlack,
              letterSpacing: 0.5,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Check in on a campaign to see your history here.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: kTextSecondary),
          ),
        ],
      ),
    );
  }
}
