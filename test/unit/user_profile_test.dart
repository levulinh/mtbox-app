import 'package:flutter_test/flutter_test.dart';
import '../../lib/providers/user_profile_provider.dart';

void main() {
  group('UserProfileState', () {
    test('initials - two words returns first letter of each', () {
      final state = const UserProfileState(
        displayName: 'John Doe',
        memberSince: 0,
      );
      expect(state.initials, 'JD');
    });

    test('initials - single word returns first two chars', () {
      final state = const UserProfileState(
        displayName: 'Alice',
        memberSince: 0,
      );
      expect(state.initials, 'AL');
    });

    test('initials - single letter returns that letter', () {
      final state = const UserProfileState(
        displayName: 'X',
        memberSince: 0,
      );
      expect(state.initials, 'X');
    });

    test('initials - empty string returns U', () {
      final state = const UserProfileState(
        displayName: '',
        memberSince: 0,
      );
      expect(state.initials, 'U');
    });

    test('initials - whitespace only returns U', () {
      final state = const UserProfileState(
        displayName: '   ',
        memberSince: 0,
      );
      expect(state.initials, 'U');
    });

    test('initials - multiple spaces returns correct initials', () {
      final state = const UserProfileState(
        displayName: 'Mary  Jane  Watson',
        memberSince: 0,
      );
      expect(state.initials, 'MJ');
    });

    test('initials - converts to uppercase', () {
      final state = const UserProfileState(
        displayName: 'john doe',
        memberSince: 0,
      );
      expect(state.initials, 'JD');
    });

    test('copyWith preserves memberSince', () {
      const original = UserProfileState(
        displayName: 'Original',
        avatarPath: '/path/to/avatar',
        memberSince: 1000,
      );
      final updated = original.copyWith(displayName: 'Updated');

      expect(updated.displayName, 'Updated');
      expect(updated.memberSince, 1000);
      expect(updated.avatarPath, '/path/to/avatar');
    });

    test('copyWith with clearAvatar removes avatar', () {
      const original = UserProfileState(
        displayName: 'Test',
        avatarPath: '/path/to/avatar',
        memberSince: 1000,
      );
      final updated = original.copyWith(clearAvatar: true);

      expect(updated.avatarPath, null);
      expect(updated.displayName, 'Test');
    });

    test('copyWith updates avatar path', () {
      const original = UserProfileState(
        displayName: 'Test',
        memberSince: 1000,
      );
      final updated = original.copyWith(avatarPath: '/new/path');

      expect(updated.avatarPath, '/new/path');
    });

    test('copyWith with null avatarPath preserves existing path', () {
      const original = UserProfileState(
        displayName: 'Test',
        avatarPath: '/existing/path',
        memberSince: 1000,
      );
      final updated = original.copyWith();

      expect(updated.avatarPath, '/existing/path');
    });
  });
}
