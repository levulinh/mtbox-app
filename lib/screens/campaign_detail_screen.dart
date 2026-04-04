import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/campaign.dart';
import '../providers/mock_data_provider.dart';
import '../services/notification_service.dart';
import '../theme.dart';
import '../widgets/stat_card.dart';

class CampaignDetailScreen extends ConsumerStatefulWidget {
  final String campaignId;

  const CampaignDetailScreen({super.key, required this.campaignId});

  @override
  ConsumerState<CampaignDetailScreen> createState() =>
      _CampaignDetailScreenState();
}

class _CampaignDetailScreenState extends ConsumerState<CampaignDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final campaigns = ref.watch(campaignsProvider);
    Campaign? campaign;
    try {
      campaign = campaigns.firstWhere((c) => c.id == widget.campaignId);
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
                  const SizedBox(height: 16),

                  // Daily Reminder
                  _ReminderSection(campaign: campaign),
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

// ─── Reminder Section ─────────────────────────────────────────────────────────

class _ReminderSection extends ConsumerWidget {
  final Campaign campaign;

  const _ReminderSection({required this.campaign});

  String _formatTime(String? time) {
    if (time == null) return '9:00 AM';
    final parts = time.split(':');
    final hour = int.tryParse(parts[0]) ?? 9;
    final minute = int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0;
    final tod = TimeOfDay(hour: hour, minute: minute);
    final h = tod.hourOfPeriod == 0 ? 12 : tod.hourOfPeriod;
    final m = tod.minute.toString().padLeft(2, '0');
    final period = tod.period == DayPeriod.am ? 'AM' : 'PM';
    return '$h:$m $period';
  }

  Future<void> _onToggle(BuildContext context, WidgetRef ref) async {
    final enabling = !campaign.reminderEnabled;
    if (enabling) {
      await NotificationService.requestPermissions();
      final defaultTime = campaign.reminderTime ?? '09:00';
      ref.read(campaignsProvider.notifier).setReminder(
            campaign.id,
            enabled: true,
            time: defaultTime,
          );
      await NotificationService.scheduleDaily(
        campaignId: campaign.id,
        campaignName: campaign.name,
        time: defaultTime,
      );
    } else {
      ref.read(campaignsProvider.notifier).setReminder(
            campaign.id,
            enabled: false,
          );
      await NotificationService.cancel(campaign.id);
    }
  }

  Future<void> _onTimeTap(BuildContext context, WidgetRef ref) async {
    final parts = (campaign.reminderTime ?? '09:00').split(':');
    final initial = TimeOfDay(
      hour: int.tryParse(parts[0]) ?? 9,
      minute: int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0,
    );
    final picked = await showTimePicker(context: context, initialTime: initial);
    if (picked == null) return;
    final timeStr =
        '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
    ref.read(campaignsProvider.notifier).setReminder(
          campaign.id,
          enabled: true,
          time: timeStr,
        );
    await NotificationService.scheduleDaily(
      campaignId: campaign.id,
      campaignName: campaign.name,
      time: timeStr,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enabled = campaign.reminderEnabled;
    final timeLabel = _formatTime(campaign.reminderTime);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header with notifications_active icon
        Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: const BoxDecoration(
            border: Border(left: BorderSide(color: kBlue, width: 3)),
          ),
          padding: const EdgeInsets.only(left: 8),
          child: const Row(
            children: [
              Icon(Icons.notifications_active, size: 13, color: kBlue),
              SizedBox(width: 5),
              Text(
                'DAILY REMINDER',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF555555),
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
        ),

        // Card
        Container(
          decoration: BoxDecoration(
            color: kWhite,
            border: Border.all(color: kBlack, width: kBorderWidth),
            boxShadow: const [
              BoxShadow(
                color: kBlack,
                offset: Offset(kShadowOffset, kShadowOffset),
                blurRadius: 0,
              ),
            ],
          ),
          child: Column(
            children: [
              // Toggle row
              GestureDetector(
                onTap: () => _onToggle(context, ref),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 13),
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Color(0xFFE8E8E8), width: 1),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        enabled
                            ? Icons.notifications_active
                            : Icons.notifications,
                        size: 20,
                        color: enabled ? kBlue : const Color(0xFF555555),
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Daily Reminder',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: kBlack,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Get a nudge each day to check in',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF555555),
                              ),
                            ),
                          ],
                        ),
                      ),
                      _BrutalistToggle(value: enabled),
                    ],
                  ),
                ),
              ),

              // Time row (greyed out when disabled)
              Opacity(
                opacity: enabled ? 1.0 : 0.35,
                child: GestureDetector(
                  onTap: enabled ? () => _onTimeTap(context, ref) : null,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 13),
                    child: Row(
                      children: [
                        const Icon(Icons.alarm,
                            size: 20, color: Color(0xFF555555)),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text(
                            'Remind me at',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: kBlack,
                            ),
                          ),
                        ),
                        Text(
                          timeLabel,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: kBlue,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.chevron_right,
                            size: 18, color: kBlack),
                      ],
                    ),
                  ),
                ),
              ),

              // Info bar (only when enabled)
              if (enabled)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                  decoration: const BoxDecoration(
                    color: kBlue,
                    border: Border(
                      top: BorderSide(color: kBlack, width: kBorderWidth),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle,
                          size: 14, color: kWhite),
                      const SizedBox(width: 6),
                      Text(
                        'REMINDER SET FOR $timeLabel DAILY',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: kWhite,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _BrutalistToggle extends StatelessWidget {
  final bool value;

  const _BrutalistToggle({required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 22,
      decoration: BoxDecoration(
        color: value ? kBlue : const Color(0xFFE0E0E0),
        border: Border.all(color: kBlack, width: kBorderWidth),
      ),
      child: Stack(
        children: [
          AnimatedPositioned(
            duration: const Duration(milliseconds: 150),
            top: 2,
            left: value ? 22 : 2,
            child: Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: kWhite,
                border: Border.all(
                  color: value ? kWhite : const Color(0xFF888888),
                  width: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
