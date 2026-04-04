import 'package:flutter/material.dart';
import '../models/campaign.dart';
import '../theme.dart';

/// 4-cell brutalist segmented control for selecting a campaign goal type.
class GoalTypeSelector extends StatelessWidget {
  final GoalType selected;
  final ValueChanged<GoalType> onSelected;

  const GoalTypeSelector({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
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
        children: [
          _GoalTypeCell(
            goalType: GoalType.days,
            icon: Icons.calendar_today,
            label: 'Days',
            selected: selected == GoalType.days,
            isFirst: true,
            isLast: false,
            onTap: () => onSelected(GoalType.days),
          ),
          _GoalTypeCell(
            goalType: GoalType.hours,
            icon: Icons.schedule,
            label: 'Hours',
            selected: selected == GoalType.hours,
            isFirst: false,
            isLast: false,
            onTap: () => onSelected(GoalType.hours),
          ),
          _GoalTypeCell(
            goalType: GoalType.sessions,
            icon: Icons.repeat,
            label: 'Sessions',
            selected: selected == GoalType.sessions,
            isFirst: false,
            isLast: false,
            onTap: () => onSelected(GoalType.sessions),
          ),
          _GoalTypeCell(
            goalType: GoalType.custom,
            icon: Icons.tune,
            label: 'Custom',
            selected: selected == GoalType.custom,
            isFirst: false,
            isLast: true,
            onTap: () => onSelected(GoalType.custom),
          ),
        ],
      ),
    );
  }
}

class _GoalTypeCell extends StatelessWidget {
  final GoalType goalType;
  final IconData icon;
  final String label;
  final bool selected;
  final bool isFirst;
  final bool isLast;
  final VoidCallback onTap;

  const _GoalTypeCell({
    required this.goalType,
    required this.icon,
    required this.label,
    required this.selected,
    required this.isFirst,
    required this.isLast,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bg = selected ? kBlue : kWhite;
    final fg = selected ? kWhite : kBlack;
    final borderLeft = isFirst
        ? BorderSide.none
        : const BorderSide(color: kSoftBorderColor, width: kSoftBorderWidth);

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 52,
          decoration: BoxDecoration(
            color: bg,
            border: Border(left: borderLeft),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: fg),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: fg,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
