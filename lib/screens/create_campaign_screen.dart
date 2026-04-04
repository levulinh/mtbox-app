import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/campaign.dart';
import '../providers/mock_data_provider.dart';
import '../theme.dart';

const _kErrorRed = Color(0xFFCC2200);

class CreateCampaignScreen extends ConsumerStatefulWidget {
  const CreateCampaignScreen({super.key});

  @override
  ConsumerState<CreateCampaignScreen> createState() =>
      _CreateCampaignScreenState();
}

class _CreateCampaignScreenState extends ConsumerState<CreateCampaignScreen> {
  final _nameController = TextEditingController();
  final _goalController = TextEditingController();
  bool _submitted = false;

  String? get _nameError {
    if (!_submitted) return null;
    if (_nameController.text.trim().isEmpty) return 'Name is required';
    return null;
  }

  String? get _goalError {
    if (!_submitted) return null;
    final v = int.tryParse(_goalController.text.trim());
    if (v == null || v <= 0) return 'Enter a valid number of days';
    return null;
  }

  bool get _hasErrors => _nameError != null || _goalError != null;

  @override
  void dispose() {
    _nameController.dispose();
    _goalController.dispose();
    super.dispose();
  }

  void _submit() {
    setState(() => _submitted = true);
    final name = _nameController.text.trim();
    final goalDays = int.tryParse(_goalController.text.trim());
    if (name.isEmpty || goalDays == null || goalDays <= 0) return;

    final campaign = Campaign(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      goal: name,
      totalDays: goalDays,
      currentDay: 0,
      isActive: true,
      dayHistory: const [],
    );
    ref.read(campaignsProvider.notifier).add(campaign);
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppBar(
        backgroundColor: kBlue,
        foregroundColor: kWhite,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'NEW CAMPAIGN',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: kWhite,
            letterSpacing: 1.0,
          ),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(2),
          child: SizedBox(
            height: 2,
            child: DecoratedBox(
              decoration: BoxDecoration(color: kBlack),
              child: SizedBox.expand(),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _FormIntro(),
              if (_submitted && _hasErrors) ...[
                const SizedBox(height: 16),
                _ValidationBanner(),
              ],
              const SizedBox(height: 16),
              _NameField(
                controller: _nameController,
                error: _nameError,
                onChanged: (_) {
                  if (_submitted) setState(() {});
                },
              ),
              const SizedBox(height: 18),
              _GoalField(
                controller: _goalController,
                error: _goalError,
                onChanged: (_) {
                  if (_submitted) setState(() {});
                },
              ),
              const SizedBox(height: 20),
              const _Divider(),
              const SizedBox(height: 20),
              _ActionButtons(
                onCancel: () => context.pop(),
                onCreate: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FormIntro extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(left: BorderSide(color: kBlue, width: 3)),
      ),
      padding: const EdgeInsets.only(left: 8),
      child: const Text(
        'FILL IN THE DETAILS BELOW TO START TRACKING',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: kTextSecondary,
          letterSpacing: 1.0,
        ),
      ),
    );
  }
}

class _ValidationBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFF0EE),
        border: Border.all(color: _kErrorRed, width: kSoftBorderWidth),
        boxShadow: const [
          BoxShadow(
            color: _kErrorRed,
            offset: Offset(kShadowOffset, kShadowOffset),
            blurRadius: 0,
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: const [
          Icon(Icons.error_outline, color: _kErrorRed, size: 18),
          SizedBox(width: 8),
          Text(
            'PLEASE FIX THE ERRORS BELOW',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: _kErrorRed,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _NameField extends StatelessWidget {
  final TextEditingController controller;
  final String? error;
  final ValueChanged<String> onChanged;

  const _NameField({
    required this.controller,
    required this.error,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final hasError = error != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'CAMPAIGN NAME',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: kBlack,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          height: 48,
          decoration: BoxDecoration(
            color: kWhite,
            border: Border.all(
              color: hasError ? _kErrorRed : kSoftBorderColor,
              width: kSoftBorderWidth,
            ),
            boxShadow: [
              BoxShadow(
                color: hasError ? _kErrorRed : kSoftShadowColor,
                offset: const Offset(kShadowOffset, kShadowOffset),
                blurRadius: 0,
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            onChanged: onChanged,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: kBlack,
            ),
            decoration: const InputDecoration(
              hintText: 'Name your campaign…',
              hintStyle: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Color(0xFFAAAAAA),
              ),
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 12, vertical: 0),
              border: InputBorder.none,
            ),
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: 5),
          Row(
            children: [
              const Icon(Icons.error, color: _kErrorRed, size: 13),
              const SizedBox(width: 4),
              Text(
                error!.toUpperCase(),
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: _kErrorRed,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _GoalField extends StatelessWidget {
  final TextEditingController controller;
  final String? error;
  final ValueChanged<String> onChanged;

  const _GoalField({
    required this.controller,
    required this.error,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final hasError = error != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'GOAL (DAYS)',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: kBlack,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 100,
              height: 48,
              decoration: BoxDecoration(
                color: kWhite,
                border: Border.all(
                  color: hasError ? _kErrorRed : kSoftBorderColor,
                  width: kSoftBorderWidth,
                ),
                boxShadow: [
                  BoxShadow(
                    color: hasError ? _kErrorRed : kSoftShadowColor,
                    offset: const Offset(kShadowOffset, kShadowOffset),
                    blurRadius: 0,
                  ),
                ],
              ),
              child: TextField(
                controller: controller,
                onChanged: onChanged,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: kBlack,
                ),
                decoration: const InputDecoration(
                  hintText: '0',
                  hintStyle: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFAAAAAA),
                  ),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                  border: InputBorder.none,
                ),
              ),
            ),
            Container(
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFF0F0F0),
                border: const Border(
                  top: BorderSide(color: kSoftBorderColor, width: kSoftBorderWidth),
                  right: BorderSide(color: kSoftBorderColor, width: kSoftBorderWidth),
                  bottom: BorderSide(color: kSoftBorderColor, width: kSoftBorderWidth),
                  left: BorderSide.none,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: kSoftShadowColor,
                    offset: Offset(kShadowOffset, kShadowOffset),
                    blurRadius: 0,
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              alignment: Alignment.center,
              child: const Text(
                'DAYS',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: kTextSecondary,
                  letterSpacing: 0.8,
                ),
              ),
            ),
          ],
        ),
        if (hasError) ...[
          const SizedBox(height: 5),
          Row(
            children: [
              const Icon(Icons.error, color: _kErrorRed, size: 13),
              const SizedBox(width: 4),
              Text(
                error!.toUpperCase(),
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: _kErrorRed,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ],
        if (!hasError) ...[
          const SizedBox(height: 5),
          const Text(
            'How many days is this campaign?',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: kTextSecondary,
            ),
          ),
        ],
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Container(height: 2, color: kBlack);
  }
}

class _ActionButtons extends StatelessWidget {
  final VoidCallback onCancel;
  final VoidCallback onCreate;

  const _ActionButtons({required this.onCancel, required this.onCreate});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: onCancel,
            child: Container(
              height: 50,
              decoration: brutalistBox(),
              alignment: Alignment.center,
              child: const Text(
                'CANCEL',
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
        const SizedBox(width: 10),
        Expanded(
          child: GestureDetector(
            onTap: onCreate,
            child: Container(
              height: 50,
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
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.check, color: kWhite, size: 16),
                  SizedBox(width: 6),
                  Text(
                    'CREATE',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: kWhite,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
