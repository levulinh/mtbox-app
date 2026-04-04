import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'screens/campaign_archive_screen.dart';
import 'screens/campaign_completion_screen.dart';
import 'screens/campaign_detail_screen.dart';
import 'screens/home_screen.dart';
import 'screens/campaigns_screen.dart';
import 'screens/create_campaign_screen.dart';
import 'screens/edit_campaign_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/stats_screen.dart';
import 'theme.dart';

CustomTransitionPage<void> _slidePage(LocalKey key, Widget child) {
  return CustomTransitionPage<void>(
    key: key,
    child: child,
    transitionDuration: const Duration(milliseconds: 250),
    reverseTransitionDuration: const Duration(milliseconds: 250),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return SlideTransition(
        position: animation.drive(
          Tween<Offset>(begin: const Offset(1.0, 0), end: Offset.zero)
              .chain(CurveTween(curve: Curves.easeOut)),
        ),
        child: child,
      );
    },
  );
}

GoRouter createRouter(String initialLocation) => GoRouter(
  initialLocation: initialLocation,
  routes: [
    ShellRoute(
      builder: (context, state, child) => _AppShell(child: child),
      routes: [
        GoRoute(
          path: '/',
          name: 'home',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: HomeScreen()),
        ),
        GoRoute(
          path: '/campaigns',
          name: 'campaigns',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: CampaignsScreen()),
        ),
        GoRoute(
          path: '/campaigns/new',
          name: 'create-campaign',
          pageBuilder: (context, state) =>
              _slidePage(state.pageKey, const CreateCampaignScreen()),
        ),
        GoRoute(
          path: '/profile',
          name: 'profile',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: ProfileScreen()),
        ),
      ],
    ),
    GoRoute(
      path: '/archive',
      name: 'campaign-archive',
      pageBuilder: (context, state) =>
          _slidePage(state.pageKey, const CampaignArchiveScreen()),
    ),
    GoRoute(
      path: '/stats',
      name: 'stats',
      pageBuilder: (context, state) =>
          _slidePage(state.pageKey, const StatsScreen()),
    ),
    GoRoute(
      path: '/campaigns/:id',
      name: 'campaign-detail',
      pageBuilder: (context, state) {
        final id = state.pathParameters['id']!;
        return _slidePage(state.pageKey, CampaignDetailScreen(campaignId: id));
      },
    ),
    GoRoute(
      path: '/campaigns/:id/edit',
      name: 'edit-campaign',
      pageBuilder: (context, state) => _slidePage(
        state.pageKey,
        EditCampaignScreen(campaignId: state.pathParameters['id']!),
      ),
    ),
    GoRoute(
      path: '/campaigns/:id/complete',
      name: 'campaign-complete',
      pageBuilder: (context, state) => _slidePage(
        state.pageKey,
        CampaignCompletionScreen(campaignId: state.pathParameters['id']!),
      ),
    ),
    GoRoute(
      path: '/onboarding',
      name: 'onboarding',
      pageBuilder: (context, state) =>
          _slidePage(state.pageKey, const OnboardingScreen()),
    ),
  ],
);

class _AppShell extends StatelessWidget {
  final Widget child;

  const _AppShell({required this.child});

  int _locationToIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/campaigns')) return 1;
    if (location.startsWith('/profile')) return 2;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = _locationToIndex(context);

    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: kBlack, width: kBorderWidth),
          ),
          color: kBackground,
        ),
        child: Row(
          children: [
            _NavItem(
              icon: Icons.home,
              label: 'HOME',
              isActive: currentIndex == 0,
              onTap: () => context.go('/'),
              isFirst: true,
            ),
            _NavItem(
              icon: Icons.flag,
              label: 'CAMPAIGNS',
              isActive: currentIndex == 1,
              onTap: () => context.go('/campaigns'),
            ),
            _NavItem(
              icon: Icons.person,
              label: 'PROFILE',
              isActive: currentIndex == 2,
              onTap: () => context.go('/profile'),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final bool isFirst;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
    this.isFirst = false,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? kBlue : kBackground,
            border: Border(
              left: isFirst
                  ? BorderSide.none
                  : const BorderSide(color: kBlack, width: kBorderWidth),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 22,
                color: isActive ? kWhite : kBlack,
              ),
              const SizedBox(height: 3),
              Text(
                label,
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: isActive ? kWhite : kBlack,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
