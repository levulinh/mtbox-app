import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/campaign.dart';
import '../theme.dart';

class CampaignCard extends StatelessWidget {
  final Campaign campaign;
  final VoidCallback? onCheckIn;
  final bool isPendingSync;

  const CampaignCard({
    super.key,
    required this.campaign,
    this.onCheckIn,
    this.isPendingSync = false,
  });

  @override
  Widget build(BuildContext context) {
    final pct = (campaign.progressPercent * 100).round();
    final color = campaign.campaignColor;

    return GestureDetector(
      onTap: () => context.push('/campaigns/${campaign.id}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: brutalistBox(),
        child: Stack(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 4px accent stripe in campaign color
                Container(width: 4, color: color),
                // Card body
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(10, 12, 12, 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Padding(
                                padding: campaign.hasStreak
                                    ? const EdgeInsets.only(right: 82)
                                    : EdgeInsets.zero,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // 40×40 icon box in campaign color
                                    Container(
                                      width: 40,
                                      height: 40,
                                      color: color,
                                      alignment: Alignment.center,
                                      child: Icon(
                                        campaign.iconData,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            campaign.name,
                                            style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w800,
                                              color: kBlack,
                                              letterSpacing: 0.3,
                                            ),
                                          ),
                                          const SizedBox(height: 3),
                                          Row(
                                            children: [
                                              Text(
                                                '${campaign.currentDay} OF ${campaign.totalDays} ${campaign.unitLabel}',
                                                style: const TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w600,
                                                  color: kTextSecondary,
                                                  letterSpacing: 0.3,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          _GoalTypeChip(campaign: campaign),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () =>
                                  context.push('/campaigns/${campaign.id}/edit'),
                              child: Container(
                                width: 32,
                                height: 32,
                                decoration: brutalistBox(),
                                alignment: Alignment.center,
                                child: const Icon(Icons.edit,
                                    size: 16, color: kBlack),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: _ProgressBar(
                                percent: campaign.progressPercent,
                                isActive: campaign.isActive,
                                color: color,
                              ),
                            ),
                            const SizedBox(width: 8),
                            SizedBox(
                              width: 28,
                              child: Text(
                                '$pct%',
                                textAlign: TextAlign.right,
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: kTextSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        _DayTickStrip(
                          totalDays: campaign.totalDays,
                          dayHistory: campaign.dayHistory,
                          showTodayTick:
                              campaign.isActive && !campaign.checkedInToday,
                          color: color,
                        ),
                        if (isPendingSync && campaign.checkedInToday) ...[
                          const SizedBox(height: 8),
                          _PendingSyncChip(),
                        ] else if (campaign.isActive) ...[
                          const SizedBox(height: 12),
                          campaign.checkedInToday
                              ? _ConfirmedState()
                              : _CheckInButton(
                                  label: campaign.checkInLabel,
                                  onTap: onCheckIn,
                                ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
            if (campaign.hasStreak)
              Positioned(
                top: 10,
                right: 56,
                child: _StreakBadge(campaign: campaign),
              ),
          ],
        ),
      ),
    );
  }
}

class _StreakBadge extends StatelessWidget {
  final Campaign campaign;

  const _StreakBadge({required this.campaign});

  @override
  Widget build(BuildContext context) {
    final broken = campaign.isStreakBroken;
    final count = campaign.streakDisplayCount;
    final iconColor = broken ? kTextSecondary : kWhite;
    final textColor = broken ? kBlack : kWhite;
    final labelColor = broken ? kTextSecondary : kWhite.withAlpha(217);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: broken ? kWhite : kBlue,
        border: Border.all(color: kSoftBorderColor, width: kSoftBorderWidth),
        boxShadow: const [
          BoxShadow(
            color: kSoftShadowColor,
            offset: Offset(kShadowOffset, kShadowOffset),
            blurRadius: 0,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.local_fire_department, size: 14, color: iconColor),
          const SizedBox(width: 3),
          Text(
            '$count',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w900,
              color: textColor,
            ),
          ),
          const SizedBox(width: 2),
          Text(
            'DAY',
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
              color: labelColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final double percent;
  final bool isActive;
  final Color color;

  const _ProgressBar({
    required this.percent,
    required this.isActive,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 10,
      decoration: const BoxDecoration(
        color: Color(0xFFE8E2DA),
        border: Border.fromBorderSide(
          BorderSide(color: kSoftBorderColor, width: kSoftBorderWidth),
        ),
      ),
      child: FractionallySizedBox(
        widthFactor: percent.clamp(0.0, 1.0),
        alignment: Alignment.centerLeft,
        child: Container(color: isActive ? color : kBlack),
      ),
    );
  }
}

class _DayTickStrip extends StatelessWidget {
  final int totalDays;
  final List<bool> dayHistory;
  final bool showTodayTick;
  final Color color;

  const _DayTickStrip({
    required this.totalDays,
    required this.dayHistory,
    required this.showTodayTick,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final todayIndex = showTodayTick ? dayHistory.length : -1;

    return Row(
      children: List.generate(totalDays, (i) {
        final bool isToday = i == todayIndex;
        final bool done = i < dayHistory.length && dayHistory[i];
        final bool future = i > dayHistory.length ||
            (i == dayHistory.length && !showTodayTick);

        Color tickColor;
        Color borderColor;
        if (isToday) {
          tickColor = const Color(0xFFFFD700);
          borderColor = kBlack;
        } else if (done) {
          tickColor = color;
          borderColor = kSoftBorderColor;
        } else if (future) {
          tickColor = const Color(0xFFE8E2DA);
          borderColor = Colors.grey.shade300;
        } else {
          tickColor = kWhite;
          borderColor = kSoftBorderColor;
        }

        return Expanded(
          child: Container(
            height: 8,
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

class _CheckInButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;

  const _CheckInButton({required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 44,
        decoration: const BoxDecoration(
          color: kBlue,
          border: Border.fromBorderSide(
            BorderSide(color: kSoftBorderColor, width: kSoftBorderWidth),
          ),
          boxShadow: [
            BoxShadow(
              color: kSoftShadowColor,
              offset: Offset(kShadowOffset, kShadowOffset),
              blurRadius: 0,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add_task, color: kWhite, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: kWhite,
                letterSpacing: 1.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Small chip below campaign name showing the goal type.
class _GoalTypeChip extends StatelessWidget {
  final Campaign campaign;

  const _GoalTypeChip({required this.campaign});

  @override
  Widget build(BuildContext context) {
    final (icon, label) = switch (campaign.goalType) {
      GoalType.days => (Icons.calendar_today, 'DAYS'),
      GoalType.hours => (Icons.schedule, 'HOURS'),
      GoalType.sessions => (Icons.repeat, 'SESSIONS'),
      GoalType.custom => (
          Icons.tune,
          campaign.metricName.isNotEmpty
              ? campaign.metricName.toUpperCase()
              : 'CUSTOM'
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFFF0EDE8),
        border: Border.all(color: kSoftBorderColor, width: 1.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 9, color: kTextSecondary),
          const SizedBox(width: 3),
          Text(
            label,
            style: const TextStyle(
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

class _ConfirmedState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      decoration: const BoxDecoration(
        color: kWhite,
        border: Border.fromBorderSide(
          BorderSide(color: kSoftBorderColor, width: kSoftBorderWidth),
        ),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle, color: kBlue, size: 18),
          SizedBox(width: 8),
          Text(
            'CHECKED IN TODAY',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: kBlack,
              letterSpacing: 1.0,
            ),
          ),
        ],
      ),
    );
  }
}

/// Shown on campaign cards when the device is offline and the check-in
/// hasn't been uploaded to the server yet.
class _PendingSyncChip extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: const BoxDecoration(
        color: Color(0xFFFEF3C7),
        border: Border.fromBorderSide(
          BorderSide(color: Color(0xFFD97706), width: kSoftBorderWidth),
        ),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.cloud_upload, size: 12, color: Color(0xFFD97706)),
          SizedBox(width: 5),
          Text(
            'PENDING SYNC — WILL UPLOAD WHEN CONNECTED',
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: Color(0xFF92400E),
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
