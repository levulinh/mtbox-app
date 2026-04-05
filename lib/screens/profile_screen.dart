import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../providers/mock_data_provider.dart';
import '../providers/user_profile_provider.dart';
import '../theme.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(statsProvider);
    final campaigns = ref.watch(campaignsProvider);
    final profile = ref.watch(userProfileProvider);
    final auth = ref.watch(authProvider);
    final totalDaysTracked =
        campaigns.fold<int>(0, (sum, c) => sum + c.currentDay);
    final displayName = profile.displayName.isNotEmpty
        ? profile.displayName
        : (auth.currentEmail?.split('@').first ?? 'You');

    return Scaffold(
      backgroundColor: kBackground,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            const SliverAppBar(
              pinned: false,
              backgroundColor: kBackground,
              expandedHeight: 70,
              flexibleSpace: FlexibleSpaceBar(
                titlePadding:
                    EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                title: Text(
                  'PROFILE',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: kBlack,
                    letterSpacing: 1.2,
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
                    GestureDetector(
                      onTap: () => context.push('/my-profile'),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: brutalistBox(),
                        child: Row(
                          children: [
                            Container(
                              width: 56,
                              height: 56,
                              decoration:
                                  brutalistBox(color: kBlue, filled: true),
                              child: Center(
                                child: Text(
                                  profile.initials,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w900,
                                    color: kWhite,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    displayName.toUpperCase(),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 0.5,
                                      color: kTextPrimary,
                                    ),
                                  ),
                                  if (auth.currentEmail != null)
                                    Text(
                                      auth.currentEmail!,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: kTextSecondary,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.chevron_right,
                              size: 20,
                              color: kBlack,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'STATS',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: brutalistBox(),
                      child: Column(
                        children: [
                          _StatRow(
                            icon: Icons.check_circle_outline,
                            label: 'Total Completed',
                            value: '${stats['completed']}',
                          ),
                          const Divider(
                              height: 1, color: kBlack, thickness: 1),
                          _StatRow(
                            icon: Icons.calendar_today,
                            label: 'Total Days Tracked',
                            value: '$totalDaysTracked',
                          ),
                          const Divider(
                              height: 1, color: kBlack, thickness: 1),
                          _StatRow(
                            icon: Icons.local_fire_department,
                            label: 'Best Streak',
                            value: '${stats['longestStreak']}d',
                          ),
                          const Divider(
                              height: 1, color: kBlack, thickness: 1),
                          GestureDetector(
                            onTap: () => context.push('/stats'),
                            child: const _SettingsRow(
                              icon: Icons.bar_chart,
                              label: 'Stats Dashboard',
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'SETTINGS',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: brutalistBox(),
                      child: Column(
                        children: [
                          const _SettingsRow(
                            icon: Icons.settings,
                            label: 'Preferences',
                          ),
                          const Divider(height: 1, color: kBlack, thickness: 1),
                          GestureDetector(
                            onTap: () => context.push('/account'),
                            child: const _SettingsRow(
                              icon: Icons.manage_accounts,
                              label: 'Account',
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
          ],
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Icon(icon, size: 18, color: kBlue),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: kBlue,
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  final IconData icon;
  final String label;

  const _SettingsRow({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      child: Row(
        children: [
          Icon(icon, size: 18, color: kBlack),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
          const Icon(Icons.chevron_right, size: 20, color: kBlack),
        ],
      ),
    );
  }
}
