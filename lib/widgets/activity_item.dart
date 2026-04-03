import 'package:flutter/material.dart';
import '../models/activity_entry.dart';
import '../theme.dart';

class ActivityItem extends StatelessWidget {
  final ActivityEntry entry;

  const ActivityItem({super.key, required this.entry});

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    return '${diff.inDays}d ago';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: entry.completed ? kBlue : kBackground,
              border: Border.all(color: kBlack, width: 1.5),
              shape: BoxShape.circle,
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
                ),
                Text(
                  _formatDate(entry.date),
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: entry.completed
                ? brutalistBox(color: kBlue, filled: true)
                : brutalistBox(),
            child: Text(
              entry.completed ? 'DONE' : 'MISSED',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: entry.completed ? kWhite : kBlack,
                letterSpacing: 0.8,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
