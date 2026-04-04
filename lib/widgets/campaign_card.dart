import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/campaign.dart';
import '../theme.dart';

class CampaignCard extends StatelessWidget {
  final Campaign campaign;

  const CampaignCard({super.key, required this.campaign});

  @override
  Widget build(BuildContext context) {
    final pct = (campaign.progressPercent * 100).round();

    return GestureDetector(
      onTap: () => context.push('/campaigns/${campaign.id}'),
      child: Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: brutalistBox(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  campaign.name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: kBlack,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: campaign.isActive
                    ? brutalistBox(color: kBlue, filled: true)
                    : brutalistBox(),
                child: Text(
                  campaign.isActive ? 'ACTIVE' : 'DONE',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: campaign.isActive ? kWhite : kBlack,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            campaign.goal,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                'DAY ${campaign.currentDay} OF ${campaign.totalDays}',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                ),
              ),
              const Spacer(),
              Text(
                '$pct%',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: campaign.isActive ? kBlue : kBlack,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          _ProgressBar(
              percent: campaign.progressPercent, isActive: campaign.isActive),
          const SizedBox(height: 10),
          _DayTickStrip(
            totalDays: campaign.totalDays,
            dayHistory: campaign.dayHistory,
          ),
        ],
      ),
    ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final double percent;
  final bool isActive;

  const _ProgressBar({required this.percent, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 16,
      decoration: const BoxDecoration(
        color: kBackground,
        border: Border.fromBorderSide(
          BorderSide(color: kBlack, width: kBorderWidth),
        ),
      ),
      child: FractionallySizedBox(
        widthFactor: percent.clamp(0.0, 1.0),
        alignment: Alignment.centerLeft,
        child: Container(color: isActive ? kBlue : kBlack),
      ),
    );
  }
}

class _DayTickStrip extends StatelessWidget {
  final int totalDays;
  final List<bool> dayHistory;

  const _DayTickStrip({
    required this.totalDays,
    required this.dayHistory,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(totalDays, (i) {
        final bool done = i < dayHistory.length && dayHistory[i];
        final bool future = i >= dayHistory.length;
        return Expanded(
          child: Container(
            height: 8,
            margin: const EdgeInsets.symmetric(horizontal: 1),
            decoration: BoxDecoration(
              color: future
                  ? const Color(0xFFE8E8E8)
                  : done
                      ? kBlue
                      : kWhite,
              border: Border.all(
                color: future ? Colors.grey.shade300 : kBlack,
                width: 1,
              ),
            ),
          ),
        );
      }),
    );
  }
}
