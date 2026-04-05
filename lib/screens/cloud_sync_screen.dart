import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/campaign.dart';
import '../providers/mock_data_provider.dart';
import '../theme.dart';

enum _SyncPhase { syncing, success, failed }

enum _ItemStatus { pending, uploading, done }

class _SyncItem {
  final Campaign campaign;
  _ItemStatus status = _ItemStatus.pending;

  _SyncItem({required this.campaign});
}

class CloudSyncScreen extends ConsumerStatefulWidget {
  const CloudSyncScreen({super.key});

  @override
  ConsumerState<CloudSyncScreen> createState() => _CloudSyncScreenState();
}

class _CloudSyncScreenState extends ConsumerState<CloudSyncScreen> {
  _SyncPhase _phase = _SyncPhase.syncing;
  List<_SyncItem> _items = [];
  final int _uploadedAtFailure = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startSync();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startSync() {
    final campaigns = ref.read(campaignsProvider);
    setState(() {
      _phase = _SyncPhase.syncing;
      _items = campaigns.map((c) => _SyncItem(campaign: c)).toList();
    });
    _uploadNext(0);
  }

  void _uploadNext(int index) {
    if (index >= _items.length) {
      _timer = Timer(const Duration(milliseconds: 400), () {
        if (mounted) {
          Hive.box('settings').put('cloudSyncDone', true);
          setState(() => _phase = _SyncPhase.success);
        }
      });
      return;
    }

    // Mark current as uploading
    setState(() => _items[index].status = _ItemStatus.uploading);

    _timer = Timer(const Duration(milliseconds: 700), () {
      if (!mounted) return;
      setState(() => _items[index].status = _ItemStatus.done);
      _uploadNext(index + 1);
    });
  }

  void _retrySync() {
    _timer?.cancel();
    _startSync();
  }

  void _continueToApp() {
    context.go('/');
  }

  int get _uploadedCount => _items.where((i) => i.status == _ItemStatus.done).length;

  int get _totalCheckIns =>
      _items.fold(0, (sum, i) => sum + i.campaign.dayHistory.where((d) => d).length);

  int get _bestStreak {
    if (_items.isEmpty) return 0;
    return _items
        .map((i) => i.campaign.bestStreak)
        .fold(0, (a, b) => a > b ? a : b);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _AppLabel(),
              Expanded(
                child: switch (_phase) {
                  _SyncPhase.syncing => _SyncingBody(
                      items: _items,
                      uploadedCount: _uploadedCount,
                    ),
                  _SyncPhase.success => _SuccessBody(
                      campaignCount: _items.length,
                      checkInCount: _totalCheckIns,
                      bestStreak: _bestStreak,
                    ),
                  _SyncPhase.failed => _FailedBody(
                      uploadedAtFailure: _uploadedAtFailure,
                      totalCount: _items.length,
                    ),
                },
              ),
              _buildButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildButtons() {
    return switch (_phase) {
      _SyncPhase.syncing => const SizedBox.shrink(),
      _SyncPhase.success => _PrimaryButton(
          icon: Icons.arrow_forward,
          label: 'CONTINUE TO APP',
          onTap: _continueToApp,
        ),
      _SyncPhase.failed => Column(
          children: [
            _PrimaryButton(
              icon: Icons.refresh,
              label: 'RETRY SYNC',
              onTap: _retrySync,
            ),
            const SizedBox(height: 10),
            _SecondaryButton(
              icon: Icons.phone_android,
              label: 'CONTINUE OFFLINE',
              onTap: _continueToApp,
            ),
          ],
        ),
    };
  }
}

// ── App label row ─────────────────────────────────────────────────────────────

class _AppLabel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 28),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: kBlue,
              border: Border.all(color: kSoftBorderColor, width: kSoftBorderWidth),
            ),
            child: const Icon(Icons.flag, size: 18, color: kWhite),
          ),
          const SizedBox(width: 8),
          const Text(
            'MTBOX',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
              color: kTextPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

// ── State 1: Syncing ──────────────────────────────────────────────────────────

class _SyncingBody extends StatelessWidget {
  final List<_SyncItem> items;
  final int uploadedCount;

  const _SyncingBody({required this.items, required this.uploadedCount});

  @override
  Widget build(BuildContext context) {
    final total = items.length;
    final pct = total == 0 ? 0.0 : uploadedCount / total;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _IconBlock(icon: Icons.cloud_upload, isError: false),
          const SizedBox(height: 20),
          const Text(
            'SYNCING YOUR DATA',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
              color: kTextPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'Uploading your campaigns and progress to the cloud. This only takes a moment.',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: kTextSecondary,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          _ProgressBar(percent: pct),
          Text(
            'Uploading $uploadedCount of $total campaigns...',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: kTextSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          _SectionHeader(label: 'Syncing Items'),
          const SizedBox(height: 10),
          ...items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: _SyncItemRow(item: item),
              )),
          const SizedBox(height: 20),
          _InfoCard(
            icon: Icons.security,
            message:
                'Your existing local data is safe — nothing will be overwritten or deleted during this sync.',
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

// ── State 2: Success ──────────────────────────────────────────────────────────

class _SuccessBody extends StatelessWidget {
  final int campaignCount;
  final int checkInCount;
  final int bestStreak;

  const _SuccessBody({
    required this.campaignCount,
    required this.checkInCount,
    required this.bestStreak,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _IconBlock(icon: Icons.check_circle, isError: false),
          const SizedBox(height: 20),
          const Text(
            'DATA SYNCED!',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
              color: kTextPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'Your campaigns are now cloud-backed and accessible on all your devices.',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: kTextSecondary,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              _StatCell(icon: Icons.flag, value: '$campaignCount', label: 'CAMPAIGNS'),
              const SizedBox(width: 8),
              _StatCell(
                  icon: Icons.check_circle,
                  value: '$checkInCount',
                  label: 'CHECK-INS'),
              const SizedBox(width: 8),
              _StatCell(
                  icon: Icons.whatshot, value: '$bestStreak', label: 'BEST STREAK'),
            ],
          ),
          const SizedBox(height: 20),
          _InfoCard(
            icon: Icons.cloud_done,
            message:
                'All your data is securely stored in the cloud. Sign in on any device to pick up right where you left off.',
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

// ── State 3: Failed ───────────────────────────────────────────────────────────

class _FailedBody extends StatelessWidget {
  final int uploadedAtFailure;
  final int totalCount;

  const _FailedBody({
    required this.uploadedAtFailure,
    required this.totalCount,
  });

  static const _kErrorRed = Color(0xFFB83232);

  @override
  Widget build(BuildContext context) {
    final pct = totalCount == 0 ? 0.0 : uploadedAtFailure / totalCount;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _IconBlock(icon: Icons.cloud_off, isError: true),
          const SizedBox(height: 20),
          const Text(
            'SYNC FAILED',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
              color: kTextPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            "We couldn't reach the server. Your local campaigns are untouched — nothing was lost.",
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: kTextSecondary,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: kWhite,
              border: Border.all(color: _kErrorRed, width: kSoftBorderWidth),
              boxShadow: [
                BoxShadow(
                  color: _kErrorRed.withAlpha(102),
                  offset: const Offset(kShadowOffset, kShadowOffset),
                  blurRadius: 0,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Icon(Icons.error_outline, size: 15, color: _kErrorRed),
                    SizedBox(width: 6),
                    Text(
                      'CONNECTION ERROR',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                        color: _kErrorRed,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  'Unable to reach the sync server. Check your internet connection and try again.',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: kTextSecondary,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _SectionHeader(label: 'Upload Progress at Failure'),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$uploadedAtFailure of $totalCount campaigns uploaded',
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                  color: kTextSecondary,
                ),
              ),
              const Text(
                'Failed',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: _kErrorRed,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Container(
            height: 10,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFE8E2DA),
              border:
                  Border.all(color: _kErrorRed, width: kSoftBorderWidth),
              boxShadow: [
                BoxShadow(
                  color: _kErrorRed.withAlpha(77),
                  offset: const Offset(kShadowOffset, kShadowOffset),
                  blurRadius: 0,
                ),
              ],
            ),
            child: FractionallySizedBox(
              widthFactor: pct,
              alignment: Alignment.centerLeft,
              child: Container(color: _kErrorRed),
            ),
          ),
          const SizedBox(height: 20),
          _InfoCard(
            icon: Icons.security,
            message:
                'Your local data is completely safe. Nothing was overwritten or deleted. Retry anytime — already-uploaded campaigns won\'t be duplicated.',
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

// ── Shared sub-widgets ────────────────────────────────────────────────────────

class _IconBlock extends StatelessWidget {
  final IconData icon;
  final bool isError;

  static const _kErrorRed = Color(0xFFB83232);

  const _IconBlock({required this.icon, required this.isError});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 88,
      height: 88,
      decoration: BoxDecoration(
        color: isError ? _kErrorRed : kBlue,
        border: Border.all(color: kBlack, width: kBorderWidth),
        boxShadow: const [
          BoxShadow(
            color: kBlack,
            offset: Offset(3, 3),
            blurRadius: 0,
          ),
        ],
      ),
      child: Icon(icon, size: 44, color: kWhite),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final double percent;

  const _ProgressBar({required this.percent});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'UPLOAD PROGRESS',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                letterSpacing: 1,
                color: kTextSecondary,
              ),
            ),
            Text(
              '${(percent * 100).round()}%',
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                color: kBlue,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          height: 10,
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFFE8E2DA),
            border: Border.all(color: kSoftBorderColor, width: kSoftBorderWidth),
            boxShadow: const [
              BoxShadow(
                color: kSoftShadowColor,
                offset: Offset(kShadowOffset, kShadowOffset),
                blurRadius: 0,
              ),
            ],
          ),
          child: FractionallySizedBox(
            widthFactor: percent.clamp(0.0, 1.0),
            alignment: Alignment.centerLeft,
            child: Container(color: kBlue),
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;

  const _SectionHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.only(left: 8),
        decoration: const BoxDecoration(
          border: Border(left: BorderSide(color: kBlue, width: 3)),
        ),
        child: Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1,
            color: kTextSecondary,
          ),
        ),
      ),
    );
  }
}

class _SyncItemRow extends StatelessWidget {
  final _SyncItem item;

  const _SyncItemRow({required this.item});

  @override
  Widget build(BuildContext context) {
    final isPending = item.status == _ItemStatus.pending;
    final isDone = item.status == _ItemStatus.done;
    final isUploading = item.status == _ItemStatus.uploading;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: kWhite,
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
        children: [
          Container(
            width: 34,
            height: 34,
            color: isPending ? const Color(0xFFE8E2DA) : kBlue,
            child: Icon(
              item.campaign.iconData,
              size: 18,
              color: isPending ? kTextSecondary : kWhite,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.campaign.name.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.3,
                    color: kTextPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${item.campaign.dayHistory.where((d) => d).length} check-ins · ${item.campaign.totalDays} day goal',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: kTextSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            decoration: BoxDecoration(
              color: isDone
                  ? kBlue
                  : isUploading
                      ? kBackground
                      : kBackground,
              border: Border.all(
                color: isDone
                    ? kBlue
                    : isUploading
                        ? kBlue
                        : kSoftBorderColor,
                width: kSoftBorderWidth,
              ),
            ),
            child: Text(
              isDone
                  ? 'DONE'
                  : isUploading
                      ? 'UPLOADING...'
                      : 'PENDING',
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
                color: isDone
                    ? kWhite
                    : isUploading
                        ? kBlue
                        : kTextSecondary,
              ),
            ),
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
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: kWhite,
          border: Border.all(color: kSoftBorderColor, width: kSoftBorderWidth),
          boxShadow: const [
            BoxShadow(
              color: kSoftShadowColor,
              offset: Offset(kShadowOffset, kShadowOffset),
              blurRadius: 0,
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, size: 20, color: kBlue),
            const SizedBox(height: 3),
            Text(
              value,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: kBlue,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
                color: kTextSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String message;

  const _InfoCard({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: kBlue,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 1),
            child: Icon(icon, size: 17, color: kWhite),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: kWhite,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _PrimaryButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 50,
        decoration: BoxDecoration(
          color: kBlue,
          border: Border.all(color: kBlack, width: kBorderWidth),
          boxShadow: const [
            BoxShadow(
              color: kBlack,
              offset: Offset(2, 2),
              blurRadius: 0,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: kWhite),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w900,
                color: kWhite,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SecondaryButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SecondaryButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 50,
        decoration: BoxDecoration(
          color: kWhite,
          border: Border.all(color: kBlack, width: kBorderWidth),
          boxShadow: const [
            BoxShadow(
              color: kBlack,
              offset: Offset(2, 2),
              blurRadius: 0,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: kTextPrimary),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w900,
                color: kTextPrimary,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
