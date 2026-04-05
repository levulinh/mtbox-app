import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../providers/user_profile_provider.dart';
import '../theme.dart';

const _kRed = Color(0xFFB83232);

class AccountManagementScreen extends ConsumerWidget {
  const AccountManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final profile = ref.watch(userProfileProvider);
    final displayName = profile.displayName.isNotEmpty
        ? profile.displayName
        : (auth.currentEmail?.split('@').first ?? 'You');

    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppBar(
        backgroundColor: kBlue,
        foregroundColor: kWhite,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: kWhite),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'ACCOUNT',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: kWhite,
            letterSpacing: 0.5,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(kBorderWidth),
          child: Container(height: kBorderWidth, color: kBlack),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: brutalistBox(),
                child: Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: brutalistBox(color: kBlue, filled: true),
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
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          displayName.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: kTextPrimary,
                            letterSpacing: -0.3,
                          ),
                        ),
                        if (auth.currentEmail != null)
                          Text(
                            auth.currentEmail!.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: kTextSecondary,
                              letterSpacing: 0.4,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // SESSION section
              _SectionHeader(label: 'Session'),
              _ActionRow(
                icon: Icons.logout,
                iconColor: kTextSecondary,
                label: 'Sign Out',
                onTap: () => _showSignOutDialog(context, ref),
              ),
              const SizedBox(height: 20),

              // DATA MANAGEMENT section
              _SectionHeader(label: 'Data Management'),
              _ActionRow(
                icon: Icons.delete_sweep,
                iconColor: kTerracotta,
                label: 'Clear Local Data',
                caption: 'Keeps your cloud account',
                onTap: () => _showClearLocalDataDialog(context, ref),
              ),
              const SizedBox(height: 20),

              // DANGER ZONE section
              _SectionHeader(label: 'Danger Zone', isDanger: true),
              _ActionRow(
                icon: Icons.delete_forever,
                iconColor: _kRed,
                label: 'Delete Account',
                labelColor: _kRed,
                caption: 'Cannot be undone',
                onTap: () => _showDeleteAccountDialog(context, ref),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  void _showSignOutDialog(BuildContext context, WidgetRef ref) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => _BrutalistDialog(
        headerColor: kBlue,
        headerIcon: Icons.logout,
        headerTitle: 'Sign Out?',
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "You'll need to sign back in to access your campaigns across devices.",
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: kTextPrimary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 12),
            _InfoRow(
              icon: Icons.cloud_done,
              text: 'Your data stays safely in the cloud',
            ),
          ],
        ),
        cancelLabel: 'Keep Me Signed In',
        confirmLabel: 'Sign Out',
        confirmColor: kBlue,
        onConfirm: () async {
          Navigator.of(dialogContext).pop();
          await ref.read(authProvider.notifier).signOut();
          if (context.mounted) context.go('/sign-in');
        },
      ),
    );
  }

  void _showClearLocalDataDialog(BuildContext context, WidgetRef ref) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => _BrutalistDialog(
        headerColor: kTerracotta,
        headerIcon: Icons.delete_sweep,
        headerTitle: 'Clear Local Data?',
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'This removes all data from this device only.',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: kTextPrimary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 12),
            _ConsequenceRow(
              icon: Icons.info_outline,
              iconColor: kTerracotta,
              text: 'All campaigns removed from this device',
            ),
            const SizedBox(height: 8),
            _ConsequenceRow(
              icon: Icons.info_outline,
              iconColor: kTerracotta,
              text: 'All check-in history cleared from this device',
            ),
            const SizedBox(height: 8),
            _ConsequenceRow(
              icon: Icons.check_circle_outline,
              iconColor: kBlue,
              text: 'Your cloud account and data are unaffected',
              textColor: kBlue,
              bold: true,
            ),
            const SizedBox(height: 12),
            const Text(
              'Sign back in to restore your data from the cloud.',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: kTextSecondary,
                height: 1.5,
              ),
            ),
          ],
        ),
        cancelLabel: 'Cancel',
        confirmLabel: 'Clear Data',
        confirmColor: kTerracotta,
        onConfirm: () async {
          Navigator.of(dialogContext).pop();
          await ref.read(authProvider.notifier).clearLocalData();
        },
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context, WidgetRef ref) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => _BrutalistDialog(
        headerColor: _kRed,
        headerIcon: Icons.warning,
        headerTitle: 'Delete Account?',
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ConsequenceRow(
              icon: Icons.close,
              iconColor: _kRed,
              text: 'All campaigns deleted',
            ),
            const SizedBox(height: 8),
            _ConsequenceRow(
              icon: Icons.close,
              iconColor: _kRed,
              text: 'All check-in history deleted',
            ),
            const SizedBox(height: 8),
            _ConsequenceRow(
              icon: Icons.close,
              iconColor: _kRed,
              text: 'Account removed from cloud',
            ),
            const SizedBox(height: 12),
            const Text(
              'THIS ACTION CANNOT BE UNDONE.',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: _kRed,
                letterSpacing: 0.4,
              ),
            ),
          ],
        ),
        cancelLabel: 'Keep My Account',
        confirmLabel: 'Delete Forever',
        confirmColor: _kRed,
        onConfirm: () async {
          Navigator.of(dialogContext).pop();
          await ref.read(authProvider.notifier).deleteAccount();
          if (context.mounted) context.go('/sign-in');
        },
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;
  final bool isDanger;

  const _SectionHeader({required this.label, this.isDanger = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.only(left: 8),
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(
              color: isDanger ? _kRed : kBlue,
              width: 3,
            ),
          ),
        ),
        child: Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.0,
            color: kTextSecondary,
          ),
        ),
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final Color? labelColor;
  final String? caption;
  final VoidCallback onTap;

  const _ActionRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    this.labelColor,
    this.caption,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: brutalistBox(),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFFEEE9E4),
                border: Border.all(color: kSoftBorderColor, width: kSoftBorderWidth),
              ),
              child: Icon(icon, size: 20, color: iconColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: labelColor ?? kTextPrimary,
                    ),
                  ),
                  if (caption != null)
                    Text(
                      caption!.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: kTextSecondary,
                        letterSpacing: 0.5,
                      ),
                    ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, size: 20, color: Color(0xFFAEAEAE)),
          ],
        ),
      ),
    );
  }
}

class _BrutalistDialog extends StatelessWidget {
  final Color headerColor;
  final IconData headerIcon;
  final String headerTitle;
  final Widget content;
  final String cancelLabel;
  final String confirmLabel;
  final Color confirmColor;
  final VoidCallback onConfirm;

  const _BrutalistDialog({
    required this.headerColor,
    required this.headerIcon,
    required this.headerTitle,
    required this.content,
    required this.cancelLabel,
    required this.confirmLabel,
    required this.confirmColor,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 32),
      child: Container(
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
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              height: 52,
              decoration: BoxDecoration(
                color: headerColor,
                border: const Border(
                  bottom: BorderSide(color: kBlack, width: kBorderWidth),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(headerIcon, color: kWhite, size: 22),
                  const SizedBox(width: 10),
                  Text(
                    headerTitle.toUpperCase(),
                    style: const TextStyle(
                      color: kWhite,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
            ),
            // Body
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 14),
              child: content,
            ),
            // Footer
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                children: [
                  _DialogBtn(
                    label: cancelLabel,
                    color: kWhite,
                    textColor: kTextPrimary,
                    onTap: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(height: 8),
                  _DialogBtn(
                    label: confirmLabel,
                    color: confirmColor,
                    textColor: kWhite,
                    onTap: onConfirm,
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

class _DialogBtn extends StatelessWidget {
  final String label;
  final Color color;
  final Color textColor;
  final VoidCallback onTap;

  const _DialogBtn({
    required this.label,
    required this.color,
    required this.textColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 44,
        decoration: BoxDecoration(
          color: color,
          border: Border.all(color: kBlack, width: kBorderWidth),
          boxShadow: [
            BoxShadow(
              color: kSoftShadowColor,
              offset: const Offset(kShadowOffset, kShadowOffset),
              blurRadius: 0,
            ),
          ],
        ),
        child: Center(
          child: Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: textColor,
              letterSpacing: 0.8,
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color: const Color(0xFFEDF1F8),
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
        children: [
          Icon(icon, size: 16, color: kBlue),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text.toUpperCase(),
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: kBlue,
                letterSpacing: 0.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ConsequenceRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String text;
  final Color? textColor;
  final bool bold;

  const _ConsequenceRow({
    required this.icon,
    required this.iconColor,
    required this.text,
    this.textColor,
    this.bold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: iconColor),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: bold ? FontWeight.w700 : FontWeight.w600,
              color: textColor ?? kTextPrimary,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}
