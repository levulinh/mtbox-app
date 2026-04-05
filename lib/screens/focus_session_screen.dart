import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/campaign.dart';
import '../providers/mock_data_provider.dart';
import '../theme.dart';

// Dark focus mode palette
const _kDark = Color(0xFF1A1A1A);
const _kDarkCard = Color(0xFF252525);
const _kDarkBorder = Color(0xFF3A3A3A);
const _kDarkSecondary = Color(0xFF888888);

enum _Phase { running, complete }

class FocusSessionScreen extends ConsumerStatefulWidget {
  final String campaignId;

  const FocusSessionScreen({super.key, required this.campaignId});

  @override
  ConsumerState<FocusSessionScreen> createState() => _FocusSessionScreenState();
}

class _FocusSessionScreenState extends ConsumerState<FocusSessionScreen> {
  // Default target duration in seconds (25 minutes)
  int _targetSeconds = 25 * 60;
  int _elapsedSeconds = 0;
  Timer? _timer;
  _Phase _phase = _Phase.running;

  // Captured before check-in, for the completion screen
  int _progressBeforeCheckIn = 0;
  int _totalDaysSnapshot = 0;
  int _streakSnapshot = 0;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        _elapsedSeconds++;
        if (_elapsedSeconds >= _targetSeconds) {
          _timer?.cancel();
          _recordSession();
        }
      });
    });
  }

  void _recordSession() {
    final campaigns = ref.read(campaignsProvider);
    Campaign? campaign;
    try {
      campaign = campaigns.firstWhere((c) => c.id == widget.campaignId);
    } catch (_) {}
    if (campaign != null) {
      _progressBeforeCheckIn = campaign.currentDay;
      _totalDaysSnapshot = campaign.totalDays;
      _streakSnapshot = campaign.currentStreak;
    }
    _timer?.cancel();
    ref.read(campaignsProvider.notifier).checkIn(widget.campaignId);
    setState(() => _phase = _Phase.complete);
  }

  void _endEarly() {
    _timer?.cancel();
    _recordSession();
  }

  Future<void> _adjustDuration() async {
    final options = [5, 10, 15, 20, 25, 30, 45, 60];
    final currentMinutes = _targetSeconds ~/ 60;
    await showDialog<void>(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: _kDarkCard,
        child: Container(
          decoration: BoxDecoration(
            color: _kDarkCard,
            border: Border.all(color: _kDarkBorder, width: 1.5),
            boxShadow: const [
              BoxShadow(color: Colors.black54, offset: Offset(4, 4), blurRadius: 0),
            ],
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'SET DURATION',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  color: kWhite,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              ...options.map((mins) {
                final selected = mins == currentMinutes;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _targetSeconds = mins * 60;
                      if (_elapsedSeconds >= _targetSeconds) {
                        _elapsedSeconds = _targetSeconds - 1;
                      }
                    });
                    Navigator.of(ctx).pop();
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                    decoration: BoxDecoration(
                      color: selected ? kBlue : _kDark,
                      border: Border.all(color: selected ? kBlue : _kDarkBorder, width: 1.5),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '$mins MINUTES',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: selected ? kWhite : _kDarkSecondary,
                            letterSpacing: 0.5,
                          ),
                        ),
                        if (selected)
                          const Icon(Icons.check, size: 16, color: kWhite),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  String _formatDuration(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    if (m > 0 && s > 0) return '${m}m ${s}s';
    if (m > 0) return '${m}m';
    return '${s}s';
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: _kDark,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: _kDark,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: _kDark,
        body: SafeArea(
          child: _phase == _Phase.running
              ? _RunningView(
                  campaignId: widget.campaignId,
                  elapsedSeconds: _elapsedSeconds,
                  targetSeconds: _targetSeconds,
                  onAdjustDuration: _adjustDuration,
                  onEndEarly: _endEarly,
                  formatTime: _formatTime,
                )
              : _CompleteView(
                  campaignId: widget.campaignId,
                  elapsedSeconds: _elapsedSeconds,
                  progressBefore: _progressBeforeCheckIn,
                  totalDays: _totalDaysSnapshot,
                  streak: _streakSnapshot,
                  formatDuration: _formatDuration,
                ),
        ),
      ),
    );
  }
}

// ─── Running View ─────────────────────────────────────────────────────────────

class _RunningView extends ConsumerWidget {
  final String campaignId;
  final int elapsedSeconds;
  final int targetSeconds;
  final VoidCallback onAdjustDuration;
  final VoidCallback onEndEarly;
  final String Function(int) formatTime;

  const _RunningView({
    required this.campaignId,
    required this.elapsedSeconds,
    required this.targetSeconds,
    required this.onAdjustDuration,
    required this.onEndEarly,
    required this.formatTime,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final campaigns = ref.watch(campaignsProvider);
    Campaign? campaign;
    try {
      campaign = campaigns.firstWhere((c) => c.id == campaignId);
    } catch (_) {}

    final remaining = (targetSeconds - elapsedSeconds).clamp(0, targetSeconds);
    final progress = targetSeconds > 0 ? elapsedSeconds / targetSeconds.toDouble() : 0.0;
    final targetMins = targetSeconds ~/ 60;

    return Column(
      children: [
        // Header
        _FocusHeader(campaignName: campaign?.name ?? ''),

        const Spacer(),

        // Large timer display
        Text(
          formatTime(remaining),
          style: const TextStyle(
            fontSize: 76,
            fontWeight: FontWeight.w900,
            color: kWhite,
            letterSpacing: -2,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'REMAINING',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: _kDarkSecondary,
            letterSpacing: 2,
          ),
        ),

        const SizedBox(height: 28),

        // Progress bar with timestamps
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            children: [
              _FocusProgressBar(progress: progress),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    formatTime(elapsedSeconds),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: _kDarkSecondary,
                      letterSpacing: 0.5,
                    ),
                  ),
                  Text(
                    formatTime(targetSeconds),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: _kDarkSecondary,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Editable target duration pill
        GestureDetector(
          onTap: onAdjustDuration,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: _kDarkCard,
              border: Border.all(color: _kDarkBorder, width: 1.5),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.timer, size: 14, color: kBlue),
                const SizedBox(width: 6),
                Text(
                  '$targetMins MIN SESSION',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: kBlue,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(Icons.edit, size: 12, color: _kDarkSecondary),
              ],
            ),
          ),
        ),

        const Spacer(),

        // End Session Early ghost button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: GestureDetector(
            onTap: onEndEarly,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: Colors.transparent,
                border: Border.all(color: _kDarkBorder, width: 1.5),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.stop_circle_outlined, size: 18, color: _kDarkSecondary),
                  SizedBox(width: 8),
                  Text(
                    'END SESSION EARLY',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: _kDarkSecondary,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Notifications silenced hint
        const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notifications_off, size: 13, color: _kDarkSecondary),
            SizedBox(width: 5),
            Text(
              'Notifications silenced',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: _kDarkSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}

// ─── Complete View ─────────────────────────────────────────────────────────────

class _CompleteView extends ConsumerWidget {
  final String campaignId;
  final int elapsedSeconds;
  final int progressBefore;
  final int totalDays;
  final int streak;
  final String Function(int) formatDuration;

  const _CompleteView({
    required this.campaignId,
    required this.elapsedSeconds,
    required this.progressBefore,
    required this.totalDays,
    required this.streak,
    required this.formatDuration,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final campaigns = ref.watch(campaignsProvider);
    Campaign? campaign;
    try {
      campaign = campaigns.firstWhere((c) => c.id == campaignId);
    } catch (_) {}

    final progressAfter = campaign?.currentDay ?? (progressBefore + 1);
    final pctBefore = totalDays > 0 ? progressBefore / totalDays : 0.0;
    final pctAfter = totalDays > 0 ? progressAfter / totalDays : 0.0;
    final isCompleted = campaign != null && !campaign.isActive;

    return Column(
      children: [
        const _FocusHeader(campaignName: '', isComplete: true),

        const Spacer(),

        // Auto-log confirmation card
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _kDarkCard,
              border: Border.all(color: kBlue, width: 1.5),
            ),
            child: Row(
              children: [
                const Icon(Icons.bolt, size: 22, color: kBlue),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'SESSION AUTO-LOGGED',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          color: kWhite,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isCompleted
                            ? 'Campaign completed!'
                            : 'Check-in recorded for today.',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: _kDarkSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 28),

        // 3-stat row
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Row(
            children: [
              _StatCell(
                label: 'DURATION',
                value: formatDuration(elapsedSeconds),
                icon: Icons.timer,
              ),
              const SizedBox(width: 8),
              _StatCell(
                label: 'STREAK',
                value: '${streak + 1}',
                icon: Icons.local_fire_department,
              ),
              const SizedBox(width: 8),
              _StatCell(
                label: 'DAYS DONE',
                value: '$progressAfter',
                icon: Icons.check_circle,
              ),
            ],
          ),
        ),

        const SizedBox(height: 28),

        // Before → After progress comparison
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _kDarkCard,
              border: Border.all(color: _kDarkBorder, width: 1.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'CAMPAIGN PROGRESS',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: _kDarkSecondary,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'BEFORE',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: _kDarkSecondary.withAlpha(180),
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(height: 4),
                          _DarkProgressBar(percent: pctBefore),
                          const SizedBox(height: 4),
                          Text(
                            '$progressBefore / $totalDays',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: _kDarkSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Icon(Icons.arrow_forward, size: 18, color: kBlue),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'AFTER',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: kBlue.withAlpha(200),
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(height: 4),
                          _DarkProgressBar(percent: pctAfter, color: kBlue),
                          const SizedBox(height: 4),
                          Text(
                            '$progressAfter / $totalDays',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: kWhite,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        const Spacer(),

        // Return to campaign button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: kBlue,
                border: Border.all(color: kBlue, width: 1.5),
                boxShadow: const [
                  BoxShadow(color: Colors.black54, offset: Offset(3, 3), blurRadius: 0),
                ],
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.arrow_back, size: 18, color: kWhite),
                  SizedBox(width: 8),
                  Text(
                    'BACK TO CAMPAIGN',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: kWhite,
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

// ─── Shared Widgets ─────────────────────────────────────────────────────────────

class _FocusHeader extends StatelessWidget {
  final String campaignName;
  final bool isComplete;

  const _FocusHeader({required this.campaignName, this.isComplete = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: _kDarkBorder, width: 1.5)),
      ),
      child: Row(
        children: [
          // Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isComplete ? const Color(0xFF2E7D32) : kBlue,
            ),
            child: Text(
              isComplete ? 'COMPLETE' : 'FOCUS MODE',
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                color: kWhite,
                letterSpacing: 1.2,
              ),
            ),
          ),
          const SizedBox(width: 12),
          if (campaignName.isNotEmpty)
            Expanded(
              child: Text(
                campaignName.toUpperCase(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: _kDarkSecondary,
                  letterSpacing: 0.5,
                ),
              ),
            )
          else
            const Expanded(child: SizedBox()),
          // Close button (only during running)
          if (!isComplete)
            GestureDetector(
              onTap: () => context.pop(),
              child: const Icon(Icons.close, size: 20, color: _kDarkSecondary),
            ),
        ],
      ),
    );
  }
}

class _FocusProgressBar extends StatelessWidget {
  final double progress;

  const _FocusProgressBar({required this.progress});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 6,
      decoration: BoxDecoration(
        color: _kDarkCard,
        border: Border.all(color: _kDarkBorder, width: 1),
      ),
      child: FractionallySizedBox(
        widthFactor: progress.clamp(0.0, 1.0),
        alignment: Alignment.centerLeft,
        child: Container(color: kBlue),
      ),
    );
  }
}

class _DarkProgressBar extends StatelessWidget {
  final double percent;
  final Color color;

  const _DarkProgressBar({required this.percent, this.color = _kDarkSecondary});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 8,
      decoration: BoxDecoration(
        color: _kDark,
        border: Border.all(color: _kDarkBorder, width: 1),
      ),
      child: FractionallySizedBox(
        widthFactor: percent.clamp(0.0, 1.0),
        alignment: Alignment.centerLeft,
        child: Container(color: color),
      ),
    );
  }
}

class _StatCell extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatCell({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        decoration: BoxDecoration(
          color: _kDarkCard,
          border: Border.all(color: _kDarkBorder, width: 1.5),
        ),
        child: Column(
          children: [
            Icon(icon, size: 18, color: kBlue),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: kWhite,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: const TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: _kDarkSecondary,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
