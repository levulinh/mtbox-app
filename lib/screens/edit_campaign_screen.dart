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
const _kDeleteRed = Color(0xFFE53935);

class EditCampaignScreen extends ConsumerStatefulWidget {
  final String campaignId;

  const EditCampaignScreen({super.key, required this.campaignId});

  @override
  ConsumerState<EditCampaignScreen> createState() => _EditCampaignScreenState();
}

class _EditCampaignScreenState extends ConsumerState<EditCampaignScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _goalController;
  late final TextEditingController _metricController;
  bool _submitted = false;
  bool _initialized = false;
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
    if (v == null || v <= 0) return 'Enter a valid goal amount';
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
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _goalController = TextEditingController();
    _metricController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _goalController.dispose();
    _metricController.dispose();
    super.dispose();
  }

  void _save() {
    setState(() => _submitted = true);
    final name = _nameController.text.trim();
    final goalAmount = int.tryParse(_goalController.text.trim());
    final metric = _metricController.text.trim();
    if (name.isEmpty || goalAmount == null || goalAmount <= 0) return;
    if (_selectedGoalType == GoalType.custom && metric.isEmpty) return;
    ref.read(campaignsProvider.notifier).update(
          widget.campaignId,
          name: name,
          totalDays: goalAmount,
          colorHex: _selectedColor,
          iconName: _selectedIcon,
          goalType: _selectedGoalType,
          metricName: metric,
        );
    context.pop();
  }

  void _confirmDelete(String campaignName) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => _DeleteDialog(
        campaignName: campaignName,
        onDelete: () {
          Navigator.of(dialogContext).pop();
          ref.read(campaignsProvider.notifier).delete(widget.campaignId);
          context.go('/campaigns');
        },
        onCancel: () => Navigator.of(dialogContext).pop(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final campaigns = ref.watch(campaignsProvider);
    final campaign = campaigns.where((c) => c.id == widget.campaignId).firstOrNull;

    if (campaign == null) {
      return const Scaffold(body: Center(child: Text('Campaign not found')));
    }

    // Pre-fill once after first build when campaign is available
    if (!_initialized) {
      _nameController.text = campaign.name;
      _goalController.text = campaign.totalDays.toString();
      _selectedColor = campaign.colorHex;
      _selectedIcon = campaign.iconName;
      _selectedGoalType = campaign.goalType;
      _metricController.text = campaign.metricName;
      _initialized = true;
    }

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
          'EDIT CAMPAIGN',
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
              _SectionLabel(text: 'CAMPAIGN DETAILS'),
              const SizedBox(height: 12),
              if (_submitted && _hasErrors) ...[
                _ValidationBanner(),
                const SizedBox(height: 16),
              ],
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
                onGoalTypeChanged: (t) =>
                    setState(() => _selectedGoalType = t),
                onGoalChanged: (_) {
                  if (_submitted) setState(() {});
                },
                onMetricChanged: (_) {
                  if (_submitted) setState(() {});
                },
              ),
              const SizedBox(height: 20),
              _SectionLabel(text: 'APPEARANCE'),
              const SizedBox(height: 12),
              AppearancePickers(
                selectedColor: _selectedColor,
                selectedIcon: _selectedIcon,
                onColorSelected: (hex) => setState(() => _selectedColor = hex),
                onIconSelected: (name) => setState(() => _selectedIcon = name),
              ),
              const SizedBox(height: 20),
              _ActionButtons(
                onCancel: () => context.pop(),
                onSave: _save,
              ),
              const SizedBox(height: 4),
              _AnnotationDivider(),
              const SizedBox(height: 4),
              _DeleteButton(onTap: () => _confirmDelete(campaign.name)),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;

  const _SectionLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(left: BorderSide(color: kBlue, width: 3)),
      ),
      padding: const EdgeInsets.only(left: 8),
      child: Text(
        text,
        style: const TextStyle(
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

class _ActionButtons extends StatelessWidget {
  final VoidCallback onCancel;
  final VoidCallback onSave;

  const _ActionButtons({required this.onCancel, required this.onSave});

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
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.close, size: 16),
                  SizedBox(width: 6),
                  Text(
                    'CANCEL',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: kBlack,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: GestureDetector(
            onTap: onSave,
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
                  Icon(Icons.save, color: kWhite, size: 16),
                  SizedBox(width: 6),
                  Text(
                    'SAVE',
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

class _AnnotationDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Expanded(
          child: Divider(
            thickness: 2,
            color: Color(0xFF999999),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            'DELETE CAMPAIGN',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: Color(0xFF999999),
              letterSpacing: 1.0,
            ),
          ),
        ),
        Expanded(
          child: Divider(
            thickness: 2,
            color: Color(0xFF999999),
          ),
        ),
      ],
    );
  }
}

class _DeleteButton extends StatelessWidget {
  final VoidCallback onTap;

  const _DeleteButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: kWhite,
          border: Border.all(color: _kDeleteRed, width: kSoftBorderWidth),
          boxShadow: const [
            BoxShadow(
              color: _kDeleteRed,
              offset: Offset(kShadowOffset, kShadowOffset),
              blurRadius: 0,
            ),
          ],
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.delete_forever, color: _kDeleteRed, size: 18),
            SizedBox(width: 6),
            Text(
              'DELETE THIS CAMPAIGN',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: _kDeleteRed,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DeleteDialog extends StatelessWidget {
  final String campaignName;
  final VoidCallback onDelete;
  final VoidCallback onCancel;

  const _DeleteDialog({
    required this.campaignName,
    required this.onDelete,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        width: 311,
        decoration: const BoxDecoration(
          color: kWhite,
          border: Border.fromBorderSide(BorderSide(color: kSoftBorderColor, width: kSoftBorderWidth)),
          boxShadow: [
            BoxShadow(
              color: kSoftShadowColor,
              offset: Offset(4, 4),
              blurRadius: 0,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: const BoxDecoration(
                color: _kDeleteRed,
                border: Border(
                  bottom: BorderSide(color: kSoftBorderColor, width: kSoftBorderWidth),
                ),
              ),
              child: const Row(
                children: [
                  Icon(Icons.warning, color: kWhite, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'DELETE CAMPAIGN?',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: kWhite,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: kBlack,
                        height: 1.5,
                      ),
                      children: [
                        const TextSpan(text: 'Are you sure you want to delete '),
                        TextSpan(
                          text: '"$campaignName"',
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        const TextSpan(text: '?'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'THIS CANNOT BE UNDONE. ALL HISTORY WILL BE LOST.',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: _kDeleteRed,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: kSoftBorderColor, width: kSoftBorderWidth)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: onCancel,
                      child: Container(
                        height: 48,
                        decoration: const BoxDecoration(
                          color: kWhite,
                          border: Border(
                            right: BorderSide(color: kSoftBorderColor, width: kSoftBorderWidth),
                          ),
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          'KEEP IT',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: kBlack,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: onDelete,
                      child: Container(
                        height: 48,
                        color: _kDeleteRed,
                        alignment: Alignment.center,
                        child: const Text(
                          'DELETE',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: kWhite,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
