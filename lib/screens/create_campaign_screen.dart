import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/campaign.dart';
import '../providers/mock_data_provider.dart';
import '../theme.dart';
import '../widgets/appearance_pickers.dart';
import '../widgets/goal_type_selector.dart';

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
  final _metricController = TextEditingController();
  bool _submitted = false;
  String _selectedColor = kCampaignColorOptions[0];
  String _selectedIcon = kCampaignIconOptions[0].$1;
  GoalType _selectedGoalType = GoalType.days;

  String? get _nameError {
    if (!_submitted) return null;
    if (_nameController.text.trim().isEmpty) return 'Name is required';
    return null;
  }

  String? get _goalError {
    if (!_submitted) return null;
    final v = int.tryParse(_goalController.text.trim());
    if (v == null || v <= 0) {
      return 'Enter a valid goal amount';
    }
    return null;
  }

  String? get _metricError {
    if (!_submitted) return null;
    if (_selectedGoalType == GoalType.custom &&
        _metricController.text.trim().isEmpty) {
      return 'Metric name is required';
    }
    return null;
  }

  bool get _hasErrors =>
      _nameError != null || _goalError != null || _metricError != null;

  @override
  void dispose() {
    _nameController.dispose();
    _goalController.dispose();
    _metricController.dispose();
    super.dispose();
  }

  void _submit() {
    setState(() => _submitted = true);
    final name = _nameController.text.trim();
    final goalAmount = int.tryParse(_goalController.text.trim());
    final metric = _metricController.text.trim();
    if (name.isEmpty || goalAmount == null || goalAmount <= 0) return;
    if (_selectedGoalType == GoalType.custom && metric.isEmpty) return;

    final campaign = Campaign(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      goal: name,
      totalDays: goalAmount,
      currentDay: 0,
      isActive: true,
      dayHistory: const [],
      colorHex: _selectedColor,
      iconName: _selectedIcon,
      goalType: _selectedGoalType,
      metricName: metric,
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
              _GoalSection(
                goalType: _selectedGoalType,
                goalController: _goalController,
                metricController: _metricController,
                goalError: _goalError,
                metricError: _metricError,
                onGoalTypeChanged: (t) => setState(() => _selectedGoalType = t),
                onGoalChanged: (_) {
                  if (_submitted) setState(() {});
                },
                onMetricChanged: (_) {
                  if (_submitted) setState(() {});
                },
              ),
              const SizedBox(height: 20),
              _SectionLabel(),
              const SizedBox(height: 12),
              AppearancePickers(
                selectedColor: _selectedColor,
                selectedIcon: _selectedIcon,
                onColorSelected: (hex) => setState(() => _selectedColor = hex),
                onIconSelected: (name) => setState(() => _selectedIcon = name),
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
      child: const Row(
        children: [
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

/// Goal section: type selector + amount field + optional custom metric field.
class _GoalSection extends StatelessWidget {
  final GoalType goalType;
  final TextEditingController goalController;
  final TextEditingController metricController;
  final String? goalError;
  final String? metricError;
  final ValueChanged<GoalType> onGoalTypeChanged;
  final ValueChanged<String> onGoalChanged;
  final ValueChanged<String> onMetricChanged;

  const _GoalSection({
    required this.goalType,
    required this.goalController,
    required this.metricController,
    required this.goalError,
    required this.metricError,
    required this.onGoalTypeChanged,
    required this.onGoalChanged,
    required this.onMetricChanged,
  });

  @override
  Widget build(BuildContext context) {
    final unitLabel = _unitPillLabel(goalType, metricController.text.trim());
    final hasGoalError = goalError != null;
    final hasMetricError = metricError != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'GOAL TYPE',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: kBlack,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 8),
        GoalTypeSelector(
          selected: goalType,
          onSelected: onGoalTypeChanged,
        ),
        const SizedBox(height: 14),
        const Text(
          'GOAL AMOUNT',
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
                  color: hasGoalError ? _kErrorRed : kSoftBorderColor,
                  width: kSoftBorderWidth,
                ),
                boxShadow: [
                  BoxShadow(
                    color: hasGoalError ? _kErrorRed : kSoftShadowColor,
                    offset: const Offset(kShadowOffset, kShadowOffset),
                    blurRadius: 0,
                  ),
                ],
              ),
              child: TextField(
                controller: goalController,
                onChanged: onGoalChanged,
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
              decoration: const BoxDecoration(
                color: Color(0xFFF0F0F0),
                border: Border(
                  top: BorderSide(color: kSoftBorderColor, width: kSoftBorderWidth),
                  right: BorderSide(color: kSoftBorderColor, width: kSoftBorderWidth),
                  bottom: BorderSide(color: kSoftBorderColor, width: kSoftBorderWidth),
                  left: BorderSide.none,
                ),
                boxShadow: [
                  BoxShadow(
                    color: kSoftShadowColor,
                    offset: Offset(kShadowOffset, kShadowOffset),
                    blurRadius: 0,
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              alignment: Alignment.center,
              child: Text(
                unitLabel,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: kTextSecondary,
                  letterSpacing: 0.8,
                ),
              ),
            ),
          ],
        ),
        if (hasGoalError) ...[
          const SizedBox(height: 5),
          _ErrorRow(message: goalError!),
        ],
        if (goalType == GoalType.custom) ...[
          const SizedBox(height: 14),
          const Text(
            'METRIC NAME',
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
                color: hasMetricError ? _kErrorRed : kBlue,
                width: kSoftBorderWidth,
              ),
              boxShadow: [
                BoxShadow(
                  color: hasMetricError ? _kErrorRed : kSoftShadowColor,
                  offset: const Offset(kShadowOffset, kShadowOffset),
                  blurRadius: 0,
                ),
              ],
            ),
            child: TextField(
              controller: metricController,
              onChanged: onMetricChanged,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: kBlack,
              ),
              decoration: const InputDecoration(
                hintText: 'e.g. Pages read, Miles run…',
                hintStyle: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFFAAAAAA),
                ),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                border: InputBorder.none,
              ),
            ),
          ),
          if (hasMetricError) ...[
            const SizedBox(height: 5),
            _ErrorRow(message: metricError!),
          ],
        ],
      ],
    );
  }
}

String _unitPillLabel(GoalType type, String metric) {
  switch (type) {
    case GoalType.days:
      return 'DAYS';
    case GoalType.hours:
      return 'HRS';
    case GoalType.sessions:
      return 'SESSIONS';
    case GoalType.custom:
      return metric.isNotEmpty ? metric.toUpperCase() : 'UNITS';
  }
}

class _ErrorRow extends StatelessWidget {
  final String message;
  const _ErrorRow({required this.message});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.error, color: _kErrorRed, size: 13),
        const SizedBox(width: 4),
        Text(
          message.toUpperCase(),
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: _kErrorRed,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(left: BorderSide(color: kBlue, width: 3)),
      ),
      padding: const EdgeInsets.only(left: 8),
      child: const Text(
        'APPEARANCE',
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
              decoration: const BoxDecoration(
                color: kBlue,
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
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
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
