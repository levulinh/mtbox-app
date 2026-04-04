import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/campaign.dart';
import '../providers/mock_data_provider.dart';
import '../theme.dart';

class CampaignCompletionScreen extends ConsumerWidget {
  final String campaignId;

  const CampaignCompletionScreen({super.key, required this.campaignId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final campaigns = ref.watch(campaignsProvider);
    Campaign? campaign;
    try {
      campaign = campaigns.firstWhere((c) => c.id == campaignId);
    } catch (_) {}

    if (campaign == null) {
      return const Scaffold(body: Center(child: Text('Campaign not found')));
    }

    final c = campaign;

    return Scaffold(
      backgroundColor: kBlue,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 32, 24, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Confetti row 1
                _ConfettiRow(
                  pattern: [
                    _SquareType.empty,
                    _SquareType.filled,
                    _SquareType.solid,
                    _SquareType.empty,
                    _SquareType.filled,
                    _SquareType.solid,
                    _SquareType.empty,
                    _SquareType.filled,
                  ],
                ),
                const SizedBox(height: 6),
                // Confetti row 2
                _ConfettiRow(
                  pattern: [
                    _SquareType.filled,
                    _SquareType.solid,
                    _SquareType.empty,
                    _SquareType.filled,
                    _SquareType.solid,
                    _SquareType.empty,
                    _SquareType.filled,
                  ],
                ),

                // Trophy block
                Container(
                  margin: const EdgeInsets.fromLTRB(0, 16, 0, 20),
                  width: 100,
                  height: 100,
                  decoration: const BoxDecoration(
                    color: kWhite,
                    border: Border.fromBorderSide(
                      BorderSide(color: kSoftBorderColor, width: 2),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: kSoftShadowColor,
                        offset: Offset(4, 4),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.emoji_events,
                    size: 56,
                    color: kBlue,
                  ),
                ),

                // "Campaign Complete" label
                const Text(
                  'CAMPAIGN COMPLETE',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2,
                    color: Color(0xBFFFFFFF),
                  ),
                ),
                const SizedBox(height: 6),

                // Campaign name
                Text(
                  c.name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: kWhite,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),

                // "Goal Achieved!" headline with bottom border
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(bottom: 20),
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Color(0x66FFFFFF), width: 3),
                    ),
                  ),
                  child: const Text(
                    'GOAL ACHIEVED!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: kWhite,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                // Stats row
                Row(
                  children: [
                    _StatBlock(
                      icon: Icons.flag,
                      value: '${c.totalDays}',
                      label: 'Days Goal',
                    ),
                    const SizedBox(width: 10),
                    _StatBlock(
                      icon: Icons.check_circle,
                      value: '${c.completedDays}',
                      label: 'Completed',
                    ),
                    const SizedBox(width: 10),
                    _StatBlock(
                      icon: Icons.local_fire_department,
                      value: '${c.currentStreak}',
                      label: 'Best Streak',
                    ),
                  ],
                ),
                const SizedBox(height: 36),

                // Back to Campaigns button
                GestureDetector(
                  onTap: () => context.go('/campaigns'),
                  child: Container(
                    height: 52,
                    decoration: const BoxDecoration(
                      color: kWhite,
                      border: Border.fromBorderSide(
                        BorderSide(color: kSoftBorderColor, width: kSoftBorderWidth),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: kSoftShadowColor,
                          offset: Offset(3, 3),
                          blurRadius: 0,
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.arrow_back, size: 20, color: kBlue),
                        SizedBox(width: 8),
                        Text(
                          'BACK TO CAMPAIGNS',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: kBlue,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // View Full History link
                GestureDetector(
                  onTap: () => context.push('/campaigns/${c.id}'),
                  child: const Padding(
                    padding: EdgeInsets.only(top: 14),
                    child: Text(
                      'VIEW FULL HISTORY',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
                        color: Color(0xA6FFFFFF),
                        decoration: TextDecoration.underline,
                        decorationColor: Color(0xA6FFFFFF),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

enum _SquareType { empty, filled, solid }

class _ConfettiRow extends StatelessWidget {
  final List<_SquareType> pattern;

  const _ConfettiRow({required this.pattern});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: pattern.map((type) {
        return Container(
          width: 14,
          height: 14,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          decoration: BoxDecoration(
            color: switch (type) {
              _SquareType.solid => kWhite,
              _SquareType.filled => const Color(0x40FFFFFF),
              _SquareType.empty => Colors.transparent,
            },
            border: Border.all(
              color: switch (type) {
                _SquareType.solid => kWhite,
                _ => const Color(0x99FFFFFF),
              },
              width: 2,
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _StatBlock extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _StatBlock({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: const BoxDecoration(
          color: Color(0x26FFFFFF),
          border: Border.fromBorderSide(
            BorderSide(color: Color(0x80FFFFFF), width: 2),
          ),
        ),
        child: Column(
          children: [
            Icon(icon, size: 18, color: Color(0xCCFFFFFF)),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: kWhite,
              ),
            ),
            Text(
              label.toUpperCase(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
                color: Color(0xB3FFFFFF),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
