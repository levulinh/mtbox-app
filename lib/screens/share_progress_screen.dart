import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gal/gal.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import '../models/campaign.dart';
import '../providers/mock_data_provider.dart';
import '../theme.dart';

class ShareProgressScreen extends ConsumerStatefulWidget {
  final String campaignId;

  const ShareProgressScreen({super.key, required this.campaignId});

  @override
  ConsumerState<ShareProgressScreen> createState() =>
      _ShareProgressScreenState();
}

class _ShareProgressScreenState extends ConsumerState<ShareProgressScreen> {
  final ScreenshotController _screenshotController = ScreenshotController();
  bool _saving = false;
  bool _sharing = false;
  String? _statusMessage;

  Future<Uint8List?> _captureCard() async {
    return await _screenshotController.capture(pixelRatio: 3.0);
  }

  Future<void> _saveToGallery() async {
    if (_saving) return;
    setState(() {
      _saving = true;
      _statusMessage = null;
    });
    try {
      final bytes = await _captureCard();
      if (bytes == null) throw Exception('Capture failed');
      await Gal.putImageBytes(bytes, name: 'mtbox_progress');
      if (mounted) {
        setState(() => _statusMessage = 'SAVED TO GALLERY');
      }
    } catch (_) {
      if (mounted) {
        setState(() => _statusMessage = 'SAVE FAILED — TRY AGAIN');
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _shareNow() async {
    if (_sharing) return;
    setState(() {
      _sharing = true;
      _statusMessage = null;
    });
    try {
      final bytes = await _captureCard();
      if (bytes == null) throw Exception('Capture failed');
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/mtbox_progress.png');
      await file.writeAsBytes(bytes);
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path, mimeType: 'image/png')],
          subject: 'My MTBox Progress',
        ),
      );
    } catch (_) {
      if (mounted) {
        setState(() => _statusMessage = 'SHARE FAILED — TRY AGAIN');
      }
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final campaigns = ref.watch(campaignsProvider);
    Campaign? campaign;
    try {
      campaign = campaigns.firstWhere((c) => c.id == widget.campaignId);
    } catch (_) {}

    if (campaign == null) {
      return const Scaffold(body: Center(child: Text('Campaign not found')));
    }

    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppBar(
        backgroundColor: kBlue,
        foregroundColor: kWhite,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'SHARE PROGRESS',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: kWhite,
            letterSpacing: 1.0,
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
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Preview section
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionLabel(label: 'PREVIEW'),
                    const SizedBox(height: 10),
                    // Wrap share card in Screenshot widget
                    Screenshot(
                      controller: _screenshotController,
                      child: _ShareCard(campaign: campaign),
                    ),
                  ],
                ),
              ),

              // Status message
              if (_statusMessage != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: _statusMessage!.contains('FAILED')
                          ? const Color(0xFFFFF0EE)
                          : const Color(0xFFEEF8EE),
                      border: Border.all(
                        color: _statusMessage!.contains('FAILED')
                            ? const Color(0xFFCC2200)
                            : const Color(0xFF4CAF50),
                        width: kSoftBorderWidth,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _statusMessage!.contains('FAILED')
                              ? Icons.error_outline
                              : Icons.check_circle,
                          size: 16,
                          color: _statusMessage!.contains('FAILED')
                              ? const Color(0xFFCC2200)
                              : const Color(0xFF4CAF50),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _statusMessage!,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: _statusMessage!.contains('FAILED')
                                ? const Color(0xFFCC2200)
                                : const Color(0xFF2E7D32),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Action buttons
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                child: Row(
                  children: [
                    // Save to Gallery
                    Expanded(
                      child: GestureDetector(
                        onTap: _saving ? null : _saveToGallery,
                        child: Container(
                          height: 48,
                          decoration: brutalistBox(),
                          child: _saving
                              ? const Center(
                                  child: SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: kBlue,
                                    ),
                                  ),
                                )
                              : const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.download, size: 18, color: kBlack),
                                    SizedBox(width: 6),
                                    Text(
                                      'SAVE',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w900,
                                        color: kBlack,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Share Now
                    Expanded(
                      child: GestureDetector(
                        onTap: _sharing ? null : _shareNow,
                        child: Container(
                          height: 48,
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
                          child: _sharing
                              ? const Center(
                                  child: SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: kWhite,
                                    ),
                                  ),
                                )
                              : const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.ios_share, size: 18, color: kWhite),
                                    SizedBox(width: 6),
                                    Text(
                                      'SHARE NOW',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w900,
                                        color: kWhite,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
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

// ── The shareable card widget ─────────────────────────────────────────────────

class _ShareCard extends StatelessWidget {
  final Campaign campaign;

  const _ShareCard({required this.campaign});

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final pct = (campaign.progressPercent * 100).round();
    final today = DateTime.now();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: kWhite,
        border: Border.fromBorderSide(BorderSide(color: kBlack, width: 2)),
        boxShadow: [
          BoxShadow(
            color: kBlack,
            offset: Offset(4, 4),
            blurRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Brand strip
          Container(
            padding: const EdgeInsets.only(bottom: 12),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Color(0xFFE8E2DA), width: 1.5),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 26,
                  height: 26,
                  decoration: const BoxDecoration(
                    color: kBlue,
                    border: Border.fromBorderSide(
                        BorderSide(color: kBlack, width: 1.5)),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(Icons.bolt, size: 15, color: kWhite),
                ),
                const SizedBox(width: 8),
                const Text(
                  'MTBOX',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: kBlue,
                    letterSpacing: 2.0,
                  ),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    border: Border.all(color: kTerracotta, width: 1.5),
                  ),
                  child: const Text(
                    'CAMPAIGN TRACKER',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      color: kTerracotta,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Campaign name
          Text(
            campaign.name.toUpperCase(),
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: kTextPrimary,
              letterSpacing: -0.5,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            '${campaign.totalDays}-Day Challenge',
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: kTextSecondary,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 16),

          // Big percentage + count block
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$pct',
                style: const TextStyle(
                  fontSize: 54,
                  fontWeight: FontWeight.w900,
                  color: kBlue,
                  height: 1,
                  letterSpacing: -3,
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(bottom: 6),
                child: Text(
                  '%',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: kBlue,
                  ),
                ),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${campaign.currentDay} / ${campaign.totalDays}',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: kTextPrimary,
                        height: 1,
                      ),
                    ),
                    const Text(
                      'DAYS COMPLETE',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: kTextSecondary,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Progress bar
          Container(
            height: 14,
            decoration: const BoxDecoration(
              color: Color(0xFFE8E2DA),
              border: Border.fromBorderSide(
                BorderSide(color: kBlack, width: 2),
              ),
            ),
            child: FractionallySizedBox(
              widthFactor: campaign.progressPercent.clamp(0.0, 1.0),
              alignment: Alignment.centerLeft,
              child: Container(color: kBlue),
            ),
          ),
          const SizedBox(height: 12),

          // Day tick strip
          _CardTickStrip(
            totalDays: campaign.totalDays,
            dayHistory: campaign.dayHistory,
          ),
          const SizedBox(height: 16),

          // Footer: streak + date
          Container(
            padding: const EdgeInsets.only(top: 12),
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: Color(0xFFE8E2DA), width: 1.5),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  decoration: const BoxDecoration(
                    color: kBlue,
                    border: Border.fromBorderSide(
                        BorderSide(color: kBlack, width: 1.5)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.local_fire_department,
                          size: 12, color: kWhite),
                      const SizedBox(width: 4),
                      Text(
                        '${campaign.currentStreak}-Day Streak'.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          color: kWhite,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Text(
                  _formatDate(today).toUpperCase(),
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: kTextSecondary,
                    letterSpacing: 0.5,
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

class _CardTickStrip extends StatelessWidget {
  final int totalDays;
  final List<bool> dayHistory;

  const _CardTickStrip({
    required this.totalDays,
    required this.dayHistory,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: List.generate(totalDays, (i) {
        final bool done = i < dayHistory.length && dayHistory[i];
        final bool future = i >= dayHistory.length;

        Color tickColor;
        Color borderColor;
        if (done) {
          tickColor = kBlue;
          borderColor = kBlue;
        } else if (future) {
          tickColor = const Color(0xFFE8E2DA);
          borderColor = const Color(0xFFB0A898);
        } else {
          tickColor = kWhite;
          borderColor = kSoftBorderColor;
        }

        return Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: tickColor,
            border: Border.all(color: borderColor, width: 1.5),
          ),
        );
      }),
    );
  }
}
