import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/mock_data_provider.dart';
import '../theme.dart';
import '../widgets/activity_item.dart';
import '../widgets/stat_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(statsProvider);
    final feed = ref.watch(activityFeedProvider);

    return Scaffold(
      backgroundColor: kBackground,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: false,
              backgroundColor: kBackground,
              expandedHeight: 70,
              flexibleSpace: FlexibleSpaceBar(
                titlePadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                title: RichText(
                  text: const TextSpan(
                    children: [
                      TextSpan(
                        text: 'HEY DREW',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: kBlack,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _formatDate(DateTime.now()),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        StatCard(
                          label: 'Total',
                          value: '${stats['total']}',
                          icon: Icons.flag,
                        ),
                        const SizedBox(width: 8),
                        StatCard(
                          label: 'Active',
                          value: '${stats['active']}',
                          icon: Icons.play_circle_outline,
                        ),
                        const SizedBox(width: 8),
                        StatCard(
                          label: 'Best Streak',
                          value: '${stats['longestStreak']}d',
                          icon: Icons.local_fire_department,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'RECENT ACTIVITY',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5,
                        color: kBlack,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: brutalistBox(),
                      child: Column(
                        children: feed
                            .map((e) => ActivityItem(entry: e))
                            .toList(),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN',
      'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC',
    ];
    const days = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
    return '${days[date.weekday - 1]}, ${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
