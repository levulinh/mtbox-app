import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

class UserProfileState {
  final String displayName;
  final String? avatarPath; // file path to saved avatar image
  final int memberSince; // epoch millis

  const UserProfileState({
    required this.displayName,
    this.avatarPath,
    required this.memberSince,
  });

  /// Two-character uppercase initials derived from displayName.
  String get initials {
    final trimmed = displayName.trim();
    if (trimmed.isEmpty) return 'U';
    final parts = trimmed.split(RegExp(r'\s+'));
    if (parts.length >= 2 && parts[0].isNotEmpty && parts[1].isNotEmpty) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    if (trimmed.length >= 2) return trimmed.substring(0, 2).toUpperCase();
    return trimmed[0].toUpperCase();
  }

  UserProfileState copyWith({
    String? displayName,
    String? avatarPath,
    bool clearAvatar = false,
  }) {
    return UserProfileState(
      displayName: displayName ?? this.displayName,
      avatarPath: clearAvatar ? null : (avatarPath ?? this.avatarPath),
      memberSince: memberSince,
    );
  }
}

class UserProfileNotifier extends Notifier<UserProfileState> {
  @override
  UserProfileState build() {
    final settings = Hive.box('settings');
    final savedPath = settings.get('avatarPath') as String?;
    return UserProfileState(
      displayName: settings.get('displayName', defaultValue: '') as String,
      avatarPath:
          (savedPath != null && savedPath.isNotEmpty) ? savedPath : null,
      memberSince: settings.get(
        'memberSince',
        defaultValue: DateTime.now().millisecondsSinceEpoch,
      ) as int,
    );
  }

  void updateDisplayName(String name) {
    final trimmed = name.trim();
    Hive.box('settings').put('displayName', trimmed);
    state = state.copyWith(displayName: trimmed);
  }

  void updateAvatarPath(String? path) {
    Hive.box('settings').put('avatarPath', path ?? '');
    state = path != null
        ? state.copyWith(avatarPath: path)
        : state.copyWith(clearAvatar: true);
  }
}

final userProfileProvider =
    NotifierProvider<UserProfileNotifier, UserProfileState>(
  UserProfileNotifier.new,
);
