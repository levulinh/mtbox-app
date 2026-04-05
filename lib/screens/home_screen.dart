import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/activity_entry.dart';
import '../providers/mock_data_provider.dart';
import '../providers/sync_provider.dart';
import '../theme.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final campaigns = ref.watch(campaignsProvider);
    final feed = ref.watch(activityFeedProvider);
    final hasSampleData = ref.watch(hasSampleDataProvider);
    final syncState = ref.watch(syncStateProvider);

    final active = campaigns.where((c) => c.isActive).toList();
    final doneToday = active.where((c) => c.checkedInToday).length;
    final bestStreak = campaigns.isEmpty
        ? 0
        : campaigns
            .map((c) => c.currentStreak)
            .reduce((a, b) => a > b ? a : b);

    final groups = _buildDateGroups(feed);
    final isOffline = syncState.phase == SyncPhase.offline;
    final isSyncing = syncState.phase == SyncPhase.syncing;

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
                    if (hasSampleData)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: kTerracotta,
                          border: Border.all(
                              color: kBlack, width: kSoftBorderWidth),
                        ),
                        child: const Text(
                          'SAMPLE DATA',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: kWhite,
                            letterSpacing: 0.5,
                          ),
                        ),
                      )
                    else
                      _SyncBadge(phase: syncState.phase),
                  ],
                ),
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(2),
                child: Container(height: 2, color: kBlack),
              ),
            ),

            // Offline bar — shown when device has no connection
            if (isOffline)
              SliverToBoxAdapter(
                child: _OfflineBar(),
              ),

            // Catch-up progress bar — shown when reconnecting
            if (isSyncing)
              SliverToBoxAdapter(
                child:
                    _CatchUpBar(progress: syncState.catchUpProgress),
              ),

            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Welcome card shown only while sample data is present
                  if (hasSampleData) ...[
                    _WelcomeCard(onDismiss: _showDismissDialog),
                    const SizedBox(height: 12),
                  ],

                  // Silent sync notification — slides in when remote changes arrive
                  if (syncState.incomingNotification != null) ...[
                    _SyncNotification(
                        message: syncState.incomingNotification!),
                    const SizedBox(height: 12),
                  ],

                  // Today section header
                  _SectionHeader(label: _formatDateHeader(DateTime.now())),
                  const SizedBox(height: 10),

                  // Today summary card
                  _TodaySummaryCard(
                    activeCampaigns: active.length,
                    doneToday: doneToday,
                    bestStreak: bestStreak,
                    pendingSync: isOffline ? syncState.pendingChanges : 0,
                  ),
                  const SizedBox(height: 16),

                  // Device panel — shown when syncing or notification just received
                  if (!hasSampleData && !isOffline) ...[
                    _DevicesPanel(),
                    const SizedBox(height: 16),
                  ],

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

  void _showDismissDialog() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: 300,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: kWhite,
            border: Border.all(color: kBlack, width: kSoftBorderWidth),
            boxShadow: const [
              BoxShadow(
                color: kBlack,
                offset: Offset(3, 3),
                blurRadius: 0,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'REMOVE SAMPLE DATA?',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: kBlack,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "This will clear the 2 sample campaigns. You'll start with a clean slate.",
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: kTextSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.of(dialogContext).pop(),
                      child: Container(
                        height: 36,
                        decoration: BoxDecoration(
                          color: kWhite,
                          border: Border.all(
                              color: kBlack, width: kSoftBorderWidth),
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          'KEEP SAMPLES',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: kBlack,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(dialogContext).pop();
                        ref.read(campaignsProvider.notifier).dismissSamples();
                        ref.read(hasSampleDataProvider.notifier).dismiss();
                      },
                      child: Container(
                        height: 36,
                        decoration: BoxDecoration(
                          color: kBlue,
                          border: Border.all(
                              color: kBlack, width: kSoftBorderWidth),
                          boxShadow: const [
                            BoxShadow(
                              color: kBlack,
                              offset: Offset(2, 2),
                              blurRadius: 0,
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          'START FRESH',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: kWhite,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
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
// Sync badge in the app bar (3 states)
// ---------------------------------------------------------------------------
class _SyncBadge extends StatelessWidget {
  final SyncPhase phase;

  const _SyncBadge({required this.phase});

  @override
  Widget build(BuildContext context) {
    return switch (phase) {
      SyncPhase.synced => Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(46),
            border: Border.all(
                color: Colors.white.withAlpha(115), width: kSoftBorderWidth),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.sync, size: 12, color: kWhite),
              SizedBox(width: 4),
              Text(
                'SYNCED',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  color: kWhite,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
        ),
      SyncPhase.syncing => Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(31),
            border: Border.all(
                color: Colors.white.withAlpha(128),
                width: kSoftBorderWidth,
                strokeAlign: BorderSide.strokeAlignInside),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.sync, size: 12, color: kWhite),
              SizedBox(width: 4),
              Text(
                'SYNCING\u2026',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  color: kWhite,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
        ),
      SyncPhase.offline => Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFB83232),
            border: Border.all(
                color: const Color(0xFF8B1A1A), width: kSoftBorderWidth),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.cloud_off, size: 12, color: kWhite),
              SizedBox(width: 4),
              Text(
                'OFFLINE',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  color: kWhite,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
        ),
    };
  }
}

// ---------------------------------------------------------------------------
// Offline warning bar (below app bar when disconnected)
// ---------------------------------------------------------------------------
class _OfflineBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: const BoxDecoration(
        color: Color(0xFFFEF3C7),
        border: Border(
          bottom: BorderSide(color: Color(0xFFD97706), width: 2),
        ),
      ),
      child: const Row(
        children: [
          Icon(Icons.wifi_off, size: 16, color: Color(0xFFD97706)),
          SizedBox(width: 8),
          Text(
            'NO CONNECTION — CHANGES SAVED LOCALLY',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              color: Color(0xFF78350F),
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Catch-up progress bar (shown while reconnecting and downloading changes)
// ---------------------------------------------------------------------------
class _CatchUpBar extends StatelessWidget {
  final double progress;

  const _CatchUpBar({required this.progress});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      color: kBlue,
      child: Row(
        children: [
          const Icon(Icons.sync, size: 13, color: kWhite),
          const SizedBox(width: 8),
          const Text(
            'CATCHING UP \u00B7 3 CHANGES FROM OTHER DEVICES',
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w900,
              color: kWhite,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              height: 3,
              color: Colors.white.withAlpha(77),
              child: FractionallySizedBox(
                widthFactor: progress.clamp(0.0, 1.0),
                alignment: Alignment.centerLeft,
                child: Container(color: kWhite),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Silent sync notification — slides in when remote changes arrive
// ---------------------------------------------------------------------------
class _SyncNotification extends StatelessWidget {
  final String message;

  const _SyncNotification({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: kWhite,
        border: Border.all(color: kBlack, width: kSoftBorderWidth),
        boxShadow: const [
          BoxShadow(
              color: kBlack, offset: Offset(3, 3), blurRadius: 0),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            color: kBlue,
            alignment: Alignment.center,
            child: const Icon(Icons.sync_alt, size: 18, color: kWhite),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'CHANGES SYNCED',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: kTextPrimary,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  message,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: kTextSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const Text(
            'JUST NOW',
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: kTextSecondary,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Device panel — shows all known devices and their sync status
// ---------------------------------------------------------------------------
class _DevicesPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: brutalistBox(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: const BoxDecoration(
              border: Border(
                  bottom: BorderSide(
                      color: kSoftBorderColor, width: kSoftBorderWidth)),
            ),
            child: Container(
              decoration: const BoxDecoration(
                  border: Border(
                      left: BorderSide(color: kBlue, width: 3))),
              padding: const EdgeInsets.only(left: 8),
              child: const Text(
                'YOUR DEVICES',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: kTextSecondary,
                  letterSpacing: 1.0,
                ),
              ),
            ),
          ),
          ...kMockDevices.asMap().entries.map((e) {
            final isLast = e.key == kMockDevices.length - 1;
            return _DeviceRow(device: e.value, showDivider: !isLast);
          }),
        ],
      ),
    );
  }
}

class _DeviceRow extends StatelessWidget {
  final DeviceInfo device;
  final bool showDivider;

  const _DeviceRow({required this.device, required this.showDivider});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: showDivider
          ? const BoxDecoration(
              border: Border(
                  bottom: BorderSide(
                      color: Color(0xFFE8E2DA), width: kSoftBorderWidth)))
          : null,
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: const BoxDecoration(
              color: kBackground,
              border: Border.fromBorderSide(
                  BorderSide(color: kSoftBorderColor, width: kSoftBorderWidth)),
            ),
            alignment: Alignment.center,
            child: Icon(device.icon, size: 14, color: kBlue),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  device.name,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: kTextPrimary,
                  ),
                ),
                Text(
                  'LAST ACTIVE: ${device.lastActive.toUpperCase()}',
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
          _DeviceStatusBadge(device: device),
        ],
      ),
    );
  }
}

class _DeviceStatusBadge extends StatelessWidget {
  final DeviceInfo device;

  const _DeviceStatusBadge({required this.device});

  @override
  Widget build(BuildContext context) {
    final Color bg;
    final Color fg;
    final Color border;
    final IconData icon;
    final String label;

    if (device.isCurrentDevice) {
      bg = kBlue;
      fg = kWhite;
      border = kSoftBorderColor;
      icon = Icons.check;
      label = 'THIS DEVICE';
    } else if (device.isOffline) {
      bg = const Color(0xFFFEF3C7);
      fg = const Color(0xFF92400E);
      border = const Color(0xFFD97706);
      icon = Icons.cloud_off;
      label = 'OFFLINE';
    } else {
      bg = kWhite;
      fg = kTextSecondary;
      border = kSoftBorderColor;
      icon = Icons.sync;
      label = 'SYNCED';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        border: Border.all(color: border, width: kSoftBorderWidth),
        boxShadow: [
          BoxShadow(
              color: kSoftShadowColor,
              offset: const Offset(1, 1),
              blurRadius: 0),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 9, color: fg),
          const SizedBox(width: 3),
          Text(
            label,
            style: TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.w900,
              color: fg,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Welcome card shown during sample-data first-run state
// ---------------------------------------------------------------------------
class _WelcomeCard extends StatelessWidget {
  final VoidCallback onDismiss;

  const _WelcomeCard({required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: kWhite,
        border: Border(
          left: const BorderSide(color: kBlue, width: 3),
          top: BorderSide(color: kSoftBorderColor, width: kSoftBorderWidth),
          right: BorderSide(color: kSoftBorderColor, width: kSoftBorderWidth),
          bottom:
              BorderSide(color: kSoftBorderColor, width: kSoftBorderWidth),
        ),
        boxShadow: [
          BoxShadow(
            color: kSoftShadowColor,
            offset: const Offset(2, 2),
            blurRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            "You're all set! Explore these sample campaigns or dismiss them to start fresh.",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: kTextPrimary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 6),
          GestureDetector(
            onTap: onDismiss,
            child: const Text(
              'Dismiss Samples \u2192',
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: kTerracotta,
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
  final int pendingSync;

  const _TodaySummaryCard({
    required this.activeCampaigns,
    required this.doneToday,
    required this.bestStreak,
    required this.pendingSync,
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
              pendingSync > 0
                  ? _StatCell(
                      icon: Icons.cloud_sync,
                      value: '$pendingSync',
                      label: 'Pending',
                      highlight: true,
                    )
                  : _StatCell(
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
  final bool highlight;

  const _StatCell({
    required this.icon,
    required this.value,
    required this.label,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = highlight ? const Color(0xFFD97706) : kBlue;
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
            Icon(icon, size: 16, color: color),
            const SizedBox(height: 2),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: color,
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
// Single feed entry row — includes device attribution chip
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
                  bottom:
                      BorderSide(color: Color(0xFFE0E0E0), width: 1)),
            )
          : null,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 1),
            child: Icon(
              isDone ? Icons.check_circle : Icons.radio_button_unchecked,
              size: 20,
              color: isDone ? kBlue : const Color(0xFFBDBDBD),
            ),
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
                          ? 'Not checked in yet \u00B7 Day ${entry.dayNumber} of ${entry.totalDays}'
                          : 'Day ${entry.dayNumber} of ${entry.totalDays}')
                      : (isPending ? 'Not checked in yet' : ''),
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: kTextSecondary,
                  ),
                ),
                // Device attribution chip — shown for completed entries
                if (isDone && entry.deviceName != null) ...[
                  const SizedBox(height: 4),
                  _DeviceAttrChip(deviceName: entry.deviceName!),
                ],
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

// ---------------------------------------------------------------------------
// Device attribution chip shown under an activity entry
// ---------------------------------------------------------------------------
class _DeviceAttrChip extends StatelessWidget {
  final String deviceName;

  const _DeviceAttrChip({required this.deviceName});

  IconData _iconFor(String name) {
    if (name.toLowerCase().contains('mac') ||
        name.toLowerCase().contains('laptop')) {
      return Icons.laptop_mac;
    }
    if (name.toLowerCase().contains('ipad') ||
        name.toLowerCase().contains('tablet')) {
      return Icons.tablet_mac;
    }
    return Icons.phone_iphone;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: const BoxDecoration(
        color: kBackground,
        border: Border.fromBorderSide(
            BorderSide(color: kSoftBorderColor, width: kSoftBorderWidth)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_iconFor(deviceName), size: 10, color: kBlue),
          const SizedBox(width: 4),
          Text(
            deviceName.toUpperCase(),
            style: const TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.w900,
              color: kTextSecondary,
              letterSpacing: 0.5,
            ),
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
      child: Column(
        children: [
          const Icon(Icons.history, size: 40, color: Color(0xFFCCCCCC)),
          const SizedBox(height: 8),
          const Text(
            'NO ACTIVITY YET',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: kBlack,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Check in on a campaign to see your history here.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: kTextSecondary),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => context.go('/campaigns'),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: kBlue,
                border: Border.all(
                    color: kSoftBorderColor, width: kSoftBorderWidth),
              ),
              child: const Text(
                'GO TO CAMPAIGNS \u2192',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: kWhite,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
