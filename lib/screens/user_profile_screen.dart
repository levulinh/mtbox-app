import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../providers/auth_provider.dart';
import '../providers/user_profile_provider.dart';
import '../theme.dart';

// ─── Internal types ───────────────────────────────────────────────────────────

enum _EditMode { none, editName, uploadAvatar }

class _DeviceInfo {
  final IconData icon;
  final String name;
  final String meta;
  final bool isCurrent;
  final String badge;

  const _DeviceInfo({
    required this.icon,
    required this.name,
    required this.meta,
    required this.isCurrent,
    required this.badge,
  });
}

const _kDevices = [
  _DeviceInfo(
    icon: Icons.phone_iphone,
    name: 'iPhone 15 Pro',
    meta: 'Today · iOS 18.3',
    isCurrent: true,
    badge: 'This device',
  ),
  _DeviceInfo(
    icon: Icons.laptop_mac,
    name: 'MacBook Pro',
    meta: 'Apr 3, 2026 · macOS 15.3',
    isCurrent: false,
    badge: '2 days ago',
  ),
];

String _formatDate(int epochMs) {
  final dt = DateTime.fromMillisecondsSinceEpoch(epochMs);
  const months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];
  return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
}

// ─── Screen ───────────────────────────────────────────────────────────────────

class UserProfileScreen extends ConsumerStatefulWidget {
  const UserProfileScreen({super.key});

  @override
  ConsumerState<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends ConsumerState<UserProfileScreen> {
  _EditMode _mode = _EditMode.none;
  final _nameController = TextEditingController();
  String? _toastMessage;
  Timer? _toastTimer;
  bool _initialized = false;

  @override
  void dispose() {
    _nameController.dispose();
    _toastTimer?.cancel();
    super.dispose();
  }

  void _showToast(String message) {
    _toastTimer?.cancel();
    setState(() => _toastMessage = message);
    _toastTimer = Timer(const Duration(milliseconds: 2500), () {
      if (mounted) setState(() => _toastMessage = null);
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final xFile = await ImagePicker().pickImage(
        source: source,
        imageQuality: 80,
      );
      if (xFile != null) {
        ref.read(userProfileProvider.notifier).updateAvatarPath(xFile.path);
      }
    } catch (_) {
      // Permission denied or unavailable — fall back silently
    }
    if (mounted) {
      setState(() => _mode = _EditMode.none);
      _showToast('AVATAR UPDATED SUCCESSFULLY');
    }
  }

  void _useInitials() {
    ref.read(userProfileProvider.notifier).updateAvatarPath(null);
    setState(() => _mode = _EditMode.none);
    _showToast('AVATAR UPDATED SUCCESSFULLY');
  }

  void _saveName() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;
    ref.read(userProfileProvider.notifier).updateDisplayName(name);
    setState(() => _mode = _EditMode.none);
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(userProfileProvider);
    final auth = ref.watch(authProvider);
    final email = auth.currentEmail ?? '';

    if (!_initialized) {
      _nameController.text = profile.displayName;
      _initialized = true;
    }

    return Scaffold(
      backgroundColor: kBackground,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context),
            if (_toastMessage != null) _buildToast(_toastMessage!),
            Expanded(
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: _buildAvatarSection(profile, email),
                  ),
                  if (_mode == _EditMode.editName)
                    SliverToBoxAdapter(child: _buildEditForm()),
                  if (_mode == _EditMode.uploadAvatar)
                    SliverToBoxAdapter(child: _buildUploadPicker()),
                  if (_mode == _EditMode.none)
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          _buildSectionHeader('Account'),
                          _buildInfoRow(
                            icon: Icons.alternate_email,
                            label: 'Email',
                            value: email.isNotEmpty ? email : '—',
                          ),
                          const SizedBox(height: 8),
                          _buildInfoRow(
                            icon: Icons.calendar_today,
                            label: 'Member Since',
                            value: _formatDate(profile.memberSince),
                          ),
                          _buildSectionHeader('Last Signed In'),
                          ..._kDevices.map(_buildDeviceCard),
                          const SizedBox(height: 24),
                        ]),
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

  // ─── App bar ──────────────────────────────────────────────────────────────

  Widget _buildAppBar(BuildContext context) {
    return Container(
      height: 56,
      decoration: const BoxDecoration(
        color: kBlue,
        border: Border(
          bottom: BorderSide(color: kBlack, width: kBorderWidth),
        ),
        boxShadow: [
          BoxShadow(
            color: kBlack,
            offset: Offset(0, kBorderWidth),
            blurRadius: 0,
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back, color: kWhite, size: 24),
          ),
          const Text(
            'MY PROFILE',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: kWhite,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Toast ────────────────────────────────────────────────────────────────

  Widget _buildToast(String message) {
    return Container(
      color: kTextPrimary,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: kBlue, size: 18),
          const SizedBox(width: 10),
          Text(
            message,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: kWhite,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Avatar section ───────────────────────────────────────────────────────

  Widget _buildAvatarSection(UserProfileState profile, String email) {
    final isUploadMode = _mode == _EditMode.uploadAvatar;
    final isEditMode = _mode == _EditMode.editName;

    return Opacity(
      opacity: isEditMode ? 0.6 : 1.0,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 20),
        decoration: const BoxDecoration(
          color: kWhite,
          border: Border(
            bottom: BorderSide(color: kSoftBorderColor, width: kSoftBorderWidth),
          ),
          boxShadow: [
            BoxShadow(
              color: kSoftShadowColor,
              offset: Offset(0, kShadowOffset),
              blurRadius: 0,
            ),
          ],
        ),
        child: Column(
          children: [
            GestureDetector(
              onTap: isEditMode
                  ? null
                  : () => setState(() => _mode = _EditMode.uploadAvatar),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 88,
                    height: 88,
                    decoration: const BoxDecoration(
                      color: kBlue,
                      border: Border.fromBorderSide(
                        BorderSide(color: kBlack, width: kBorderWidth),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: kSoftShadowColor,
                          offset: Offset(kShadowOffset, kShadowOffset),
                          blurRadius: 0,
                        ),
                      ],
                    ),
                    child: _buildAvatarContent(profile, isUploadMode),
                  ),
                  if (isUploadMode)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: kBlue.withAlpha(38),
                          border: Border.all(color: kBlue, width: kBorderWidth),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.photo_camera,
                            color: kBlue,
                            size: 32,
                          ),
                        ),
                      ),
                    ),
                  if (!isUploadMode)
                    Positioned(
                      bottom: -6,
                      right: -6,
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: const BoxDecoration(
                          color: kWhite,
                          border: Border.fromBorderSide(
                            BorderSide(color: kBlack, width: kBorderWidth),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: kSoftShadowColor,
                              offset: Offset(1, 1),
                              blurRadius: 0,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.photo_camera,
                          size: 14,
                          color: kTextPrimary,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Text(
              profile.displayName.isNotEmpty ? profile.displayName : 'Your Name',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: kTextPrimary,
                letterSpacing: -0.5,
              ),
            ),
            if (email.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(
                email.toUpperCase(),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: kTextSecondary,
                  letterSpacing: 0.3,
                ),
              ),
            ],
            if (isUploadMode) ...[
              const SizedBox(height: 8),
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.info, size: 13, color: kBlue),
                  SizedBox(width: 4),
                  Text(
                    'Tap to change your photo',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: kBlue,
                    ),
                  ),
                ],
              ),
            ],
            if (_mode == _EditMode.none) ...[
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () => setState(() {
                  _nameController.text = profile.displayName;
                  _mode = _EditMode.editName;
                }),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  decoration: const BoxDecoration(
                    color: kWhite,
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
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.edit, size: 14, color: kBlue),
                      SizedBox(width: 6),
                      Text(
                        'EDIT DISPLAY NAME',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.0,
                          color: kTextPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarContent(UserProfileState profile, bool isUploadMode) {
    if (profile.avatarPath != null && !isUploadMode) {
      return ClipRect(
        child: Image.file(
          File(profile.avatarPath!),
          width: 88,
          height: 88,
          fit: BoxFit.cover,
          errorBuilder: (ctx, err, stack) => _InitialsWidget(profile.initials),
        ),
      );
    }
    return Opacity(
      opacity: isUploadMode ? 0.5 : 1.0,
      child: _InitialsWidget(profile.initials),
    );
  }

  // ─── Edit name form ───────────────────────────────────────────────────────

  Widget _buildEditForm() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: kWhite,
        border: Border(
          bottom: BorderSide(color: kSoftBorderColor, width: kSoftBorderWidth),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'DISPLAY NAME',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: kTextPrimary,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _nameController,
            autofocus: true,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: kTextPrimary,
            ),
            decoration: const InputDecoration(
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.zero,
                borderSide: BorderSide(
                  color: kSoftBorderColor,
                  width: kSoftBorderWidth,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.zero,
                borderSide: BorderSide(color: kBlue, width: 2),
              ),
              filled: true,
              fillColor: kWhite,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'This name appears on your profile and shared content.',
            style: TextStyle(
              fontSize: 11,
              color: kTextSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _mode = _EditMode.none),
                  child: Container(
                    height: 44,
                    decoration: const BoxDecoration(
                      color: kWhite,
                      border: Border.fromBorderSide(
                        BorderSide(
                          color: kSoftBorderColor,
                          width: kSoftBorderWidth,
                        ),
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
                        Icon(Icons.close, size: 16, color: kTextPrimary),
                        SizedBox(width: 6),
                        Text(
                          'CANCEL',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.0,
                            color: kTextPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: GestureDetector(
                  onTap: _saveName,
                  child: Container(
                    height: 44,
                    decoration: const BoxDecoration(
                      color: kBlue,
                      border: Border.fromBorderSide(
                        BorderSide(color: kBlack, width: kBorderWidth),
                      ),
                      boxShadow: [
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
                        Icon(Icons.check, size: 16, color: kWhite),
                        SizedBox(width: 6),
                        Text(
                          'SAVE',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.0,
                            color: kWhite,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Upload picker ────────────────────────────────────────────────────────

  Widget _buildUploadPicker() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Row(
        children: [
          _UploadOption(
            icon: Icons.photo_library,
            label: 'GALLERY',
            onTap: () => _pickImage(ImageSource.gallery),
          ),
          const SizedBox(width: 8),
          _UploadOption(
            icon: Icons.photo_camera,
            label: 'CAMERA',
            onTap: () => _pickImage(ImageSource.camera),
          ),
          const SizedBox(width: 8),
          _UploadOption(
            icon: Icons.person,
            label: 'INITIALS',
            onTap: _useInitials,
          ),
        ],
      ),
    );
  }

  // ─── Account section ──────────────────────────────────────────────────────

  Widget _buildSectionHeader(String label) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 10),
      child: Container(
        padding: const EdgeInsets.only(left: 8),
        decoration: const BoxDecoration(
          border: Border(left: BorderSide(color: kBlue, width: 3)),
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

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: const BoxDecoration(
        color: kWhite,
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
          Icon(icon, size: 20, color: kBlue),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label.toUpperCase(),
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: kTextSecondary,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: kTextPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Device card ──────────────────────────────────────────────────────────

  Widget _buildDeviceCard(_DeviceInfo device) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        decoration: const BoxDecoration(
          color: kWhite,
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
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: kBackground,
                border: Border.fromBorderSide(
                  BorderSide(color: kSoftBorderColor, width: kSoftBorderWidth),
                ),
              ),
              child: Icon(device.icon, size: 20, color: kBlue),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    device.name,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: kTextPrimary,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    device.meta.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: kTextSecondary,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: device.isCurrent ? kBlue : kWhite,
                border: Border.all(
                  color: device.isCurrent ? kBlue : kSoftBorderColor,
                  width: device.isCurrent ? kBorderWidth : kSoftBorderWidth,
                ),
              ),
              child: Text(
                device.badge.toUpperCase(),
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  color: device.isCurrent ? kWhite : kTextSecondary,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Shared sub-widgets ───────────────────────────────────────────────────────

class _InitialsWidget extends StatelessWidget {
  final String initials;

  const _InitialsWidget(this.initials);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        initials,
        style: const TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w900,
          color: kWhite,
          letterSpacing: -1,
        ),
      ),
    );
  }
}

class _UploadOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _UploadOption({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 44,
          decoration: const BoxDecoration(
            color: kWhite,
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: kBlue),
              const SizedBox(height: 2),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.8,
                  color: kTextPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
