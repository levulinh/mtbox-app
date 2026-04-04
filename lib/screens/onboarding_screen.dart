import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/campaign.dart';
import '../providers/mock_data_provider.dart';
import '../theme.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pageController = PageController();

  // Form state for page 3
  final _nameController = TextEditingController(text: 'Exercise Daily');
  final _daysController = TextEditingController(text: '30');
  bool _submitted = false;

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _daysController.dispose();
    super.dispose();
  }

  void _goToPage(int page) {
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _completeOnboarding({bool skip = false}) {
    if (!skip) {
      setState(() => _submitted = true);
      final name = _nameController.text.trim();
      final days = int.tryParse(_daysController.text.trim()) ?? 0;
      if (name.isEmpty || days < 1) return;

      final campaign = Campaign(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        goal: name,
        totalDays: days,
        currentDay: 0,
        isActive: true,
        dayHistory: const [],
      );
      ref.read(campaignsProvider.notifier).add(campaign);
    }

    Hive.box('settings').put('onboardingDone', true);
    if (mounted) context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _WelcomePage(
            onGetStarted: () => _goToPage(1),
            onSkip: () => _completeOnboarding(skip: true),
          ),
          _HowItWorksPage(
            onNext: () => _goToPage(2),
            onBack: () => _goToPage(0),
          ),
          _CreateCampaignPage(
            nameController: _nameController,
            daysController: _daysController,
            submitted: _submitted,
            onCreate: _completeOnboarding,
            onBack: () => _goToPage(1),
          ),
        ],
      ),
    );
  }
}

// ─── Progress Dots ───────────────────────────────────────────────────────────

class _ProgressDots extends StatelessWidget {
  final int current;
  final int total;

  const _ProgressDots({required this.current, required this.total});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(total, (i) {
        final active = i == current;
        return Container(
          width: 10,
          height: 10,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          decoration: BoxDecoration(
            color: active ? kBlue : kWhite,
            border: Border.all(
              color: active ? kBlue : kBlack,
              width: kBorderWidth,
            ),
          ),
        );
      }),
    );
  }
}

// ─── Screen 1: Welcome ───────────────────────────────────────────────────────

class _WelcomePage extends StatelessWidget {
  final VoidCallback onGetStarted;
  final VoidCallback onSkip;

  const _WelcomePage({required this.onGetStarted, required this.onSkip});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Blue hero block
        Container(
          width: double.infinity,
          height: 320,
          color: kBlue,
          child: SafeArea(
            bottom: false,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    color: kWhite,
                    border: Border.all(color: kBlack, width: kBorderWidth),
                    boxShadow: const [
                      BoxShadow(
                        color: kBlack,
                        offset: Offset(3, 3),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  child: const Icon(Icons.flag, size: 48, color: kBlue),
                ),
                const SizedBox(height: 20),
                const Text(
                  'MTBOX',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: kWhite,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'BUILD HABITS THAT STICK',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xCCFFFFFF),
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
        // Divider shadow
        Container(height: 2, color: kBlack),

        // Body
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Track your goals,\none day at a time.',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: kBlack,
                    letterSpacing: -0.4,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'MTBox helps you build lasting habits by breaking big goals into daily actions — and showing your real progress every step of the way.',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: kTextSecondary,
                    height: 1.55,
                  ),
                ),
                const SizedBox(height: 24),
                const Center(child: _ProgressDots(current: 0, total: 3)),
                const SizedBox(height: 20),

                // GET STARTED button
                GestureDetector(
                  onTap: onGetStarted,
                  child: Container(
                    width: double.infinity,
                    height: 52,
                    decoration: BoxDecoration(
                      color: kBlue,
                      border: Border.all(color: kBlack, width: kBorderWidth),
                      boxShadow: const [
                        BoxShadow(
                          color: kBlack,
                          offset: Offset(kShadowOffset, kShadowOffset),
                          blurRadius: 0,
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'GET STARTED',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: kWhite,
                            letterSpacing: 1,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward, color: kWhite, size: 20),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Skip link
                GestureDetector(
                  onTap: onSkip,
                  child: const Center(
                    child: Text(
                      "SKIP — I KNOW THE DRILL",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: kTextSecondary,
                        letterSpacing: 0.6,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Screen 2: How It Works ──────────────────────────────────────────────────

class _HowItWorksPage extends StatelessWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;

  const _HowItWorksPage({required this.onNext, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // AppBar
        Container(
          color: kBlue,
          child: SafeArea(
            bottom: false,
            child: Container(
              height: 56,
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: kBlack, width: kBorderWidth),
                ),
                boxShadow: [
                  BoxShadow(
                    color: kBlack,
                    offset: Offset(0, 2),
                    blurRadius: 0,
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: onBack,
                    child: const Icon(Icons.arrow_back, color: kWhite, size: 24),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'HOW IT WORKS',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: kWhite,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Feature row 1
                _FeatureRow(
                  icon: Icons.flag,
                  title: 'Create a Campaign',
                  description:
                      'Pick a habit and set a goal — like "Exercise daily for 30 days".',
                ),
                const SizedBox(height: 16),

                // Feature row 2
                _FeatureRow(
                  icon: Icons.add_task,
                  title: 'Check In Daily',
                  description:
                      'Tap once each day to log your progress and build your streak.',
                ),
                const SizedBox(height: 16),

                // Example label
                Container(
                  decoration: const BoxDecoration(
                    border: Border(
                      left: BorderSide(color: kBlue, width: 3),
                    ),
                  ),
                  padding: const EdgeInsets.only(left: 8),
                  child: const Text(
                    'EXAMPLE CAMPAIGN',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: kTextSecondary,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Example campaign card
                _ExampleCampaignCard(),
                const SizedBox(height: 16),

                const Center(child: _ProgressDots(current: 1, total: 3)),
                const SizedBox(height: 16),

                // NEXT button
                GestureDetector(
                  onTap: onNext,
                  child: Container(
                    width: double.infinity,
                    height: 52,
                    decoration: BoxDecoration(
                      color: kBlue,
                      border: Border.all(color: kBlack, width: kBorderWidth),
                      boxShadow: const [
                        BoxShadow(
                          color: kBlack,
                          offset: Offset(kShadowOffset, kShadowOffset),
                          blurRadius: 0,
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'NEXT',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: kWhite,
                            letterSpacing: 1,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward, color: kWhite, size: 20),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Back link
                GestureDetector(
                  onTap: onBack,
                  child: const Center(
                    child: Text(
                      '← BACK',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: kTextSecondary,
                        letterSpacing: 0.5,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _FeatureRow({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kWhite,
        border: Border.all(color: kBlack, width: kBorderWidth),
        boxShadow: const [
          BoxShadow(
            color: kBlack,
            offset: Offset(kShadowOffset, kShadowOffset),
            blurRadius: 0,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            color: kBlue,
            child: Icon(icon, size: 30, color: kWhite),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: kTextSecondary,
                    height: 1.45,
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

class _ExampleCampaignCard extends StatelessWidget {
  const _ExampleCampaignCard();

  @override
  Widget build(BuildContext context) {
    const totalDays = 30;
    const doneDays = 12;
    final progress = doneDays / totalDays;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: kWhite,
        border: Border.all(color: kBlack, width: kBorderWidth),
        boxShadow: const [
          BoxShadow(
            color: kBlack,
            offset: Offset(kShadowOffset, kShadowOffset),
            blurRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Exercise Daily',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                color: kBlue,
                child: const Text(
                  'ACTIVE',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    color: kWhite,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'DAY 12 OF 30',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: kTextSecondary,
                  letterSpacing: 0.3,
                ),
              ),
              Text(
                '${(progress * 100).round()}%',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: kTextSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          // Progress bar
          Container(
            height: 10,
            decoration: BoxDecoration(
              color: kWhite,
              border: Border.all(color: kBlack, width: kBorderWidth),
            ),
            child: FractionallySizedBox(
              widthFactor: progress,
              alignment: Alignment.centerLeft,
              child: Container(color: kBlue),
            ),
          ),
          const SizedBox(height: 5),
          // Day ticks
          Wrap(
            spacing: 2,
            runSpacing: 2,
            children: List.generate(totalDays, (i) {
              final done = i < doneDays;
              return Container(
                width: 7,
                height: 7,
                color: done ? kBlue : const Color(0xFFE8E8E8),
              );
            }),
          ),
        ],
      ),
    );
  }
}

// ─── Screen 3: Create First Campaign ─────────────────────────────────────────

class _CreateCampaignPage extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController daysController;
  final bool submitted;
  final VoidCallback onCreate;
  final VoidCallback onBack;

  const _CreateCampaignPage({
    required this.nameController,
    required this.daysController,
    required this.submitted,
    required this.onCreate,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final nameError = submitted && nameController.text.trim().isEmpty;
    final daysVal = int.tryParse(daysController.text.trim()) ?? 0;
    final daysError = submitted && daysVal < 1;

    return Column(
      children: [
        // AppBar
        Container(
          color: kBlue,
          child: SafeArea(
            bottom: false,
            child: Container(
              height: 56,
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: kBlack, width: kBorderWidth),
                ),
                boxShadow: [
                  BoxShadow(
                    color: kBlack,
                    offset: Offset(0, 2),
                    blurRadius: 0,
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: onBack,
                    child: const Icon(Icons.arrow_back, color: kWhite, size: 24),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'FIRST CAMPAIGN',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: kWhite,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Let's set up your first campaign. You can always add more later.",
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: kTextSecondary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 20),

                // Campaign Name field
                const Text(
                  'CAMPAIGN NAME',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: kTextSecondary,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: kWhite,
                    border: Border.all(
                      color: nameError ? Colors.red : kBlue,
                      width: kBorderWidth,
                    ),
                  ),
                  child: TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.symmetric(horizontal: 12),
                      border: InputBorder.none,
                      hintText: 'e.g. Exercise Daily',
                      hintStyle: TextStyle(
                        color: Color(0xFFBBBBBB),
                        fontWeight: FontWeight.w500,
                        fontSize: 15,
                      ),
                    ),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: kBlack,
                    ),
                  ),
                ),
                if (nameError) ...[
                  const SizedBox(height: 4),
                  const Text(
                    'Campaign name is required',
                    style: TextStyle(fontSize: 11, color: Colors.red),
                  ),
                ],
                const SizedBox(height: 16),

                // Goal duration field
                const Text(
                  'GOAL DURATION',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: kTextSecondary,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Container(
                      width: 90,
                      height: 48,
                      decoration: BoxDecoration(
                        color: kWhite,
                        border: Border.all(
                          color: daysError ? Colors.red : kBlack,
                          width: kBorderWidth,
                        ),
                      ),
                      child: TextField(
                        controller: daysController,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.symmetric(horizontal: 8),
                          border: InputBorder.none,
                        ),
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: kBlue,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        height: 48,
                        decoration: const BoxDecoration(
                          color: Color(0xFFE8E8E8),
                          border: Border(
                            top: BorderSide(color: kBlack, width: kBorderWidth),
                            right: BorderSide(color: kBlack, width: kBorderWidth),
                            bottom: BorderSide(color: kBlack, width: kBorderWidth),
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        child: const Row(
                          children: [
                            Icon(Icons.calendar_today, size: 16, color: kTextSecondary),
                            SizedBox(width: 6),
                            Text(
                              'DAYS',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: kTextSecondary,
                                letterSpacing: 0.6,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                if (daysError) ...[
                  const SizedBox(height: 4),
                  const Text(
                    'Enter a valid number of days',
                    style: TextStyle(fontSize: 11, color: Colors.red),
                  ),
                ],
                const SizedBox(height: 6),
                const Text(
                  'We recommend starting with 14–30 days.',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF999999),
                  ),
                ),
                const SizedBox(height: 16),

                const Center(child: _ProgressDots(current: 2, total: 3)),
                const SizedBox(height: 16),

                // CREATE & START button
                GestureDetector(
                  onTap: onCreate,
                  child: Container(
                    width: double.infinity,
                    height: 52,
                    decoration: BoxDecoration(
                      color: kBlue,
                      border: Border.all(color: kBlack, width: kBorderWidth),
                      boxShadow: const [
                        BoxShadow(
                          color: kBlack,
                          offset: Offset(kShadowOffset, kShadowOffset),
                          blurRadius: 0,
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.flag, color: kWhite, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'CREATE & START',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: kWhite,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // BACK button
                GestureDetector(
                  onTap: onBack,
                  child: Container(
                    width: double.infinity,
                    height: 48,
                    decoration: BoxDecoration(
                      color: kWhite,
                      border: Border.all(color: kBlack, width: kBorderWidth),
                      boxShadow: const [
                        BoxShadow(
                          color: kBlack,
                          offset: Offset(kShadowOffset, kShadowOffset),
                          blurRadius: 0,
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        '← BACK',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: kBlack,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
