import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:mtbox_app/models/user_account.dart';
import 'package:mtbox_app/models/user_account_adapter.dart';
import 'package:mtbox_app/providers/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  group('AuthState', () {
    test('isSignedIn is true when currentEmail is not null', () {
      const state = AuthState(currentEmail: 'user@example.com');
      expect(state.isSignedIn, true);
    });

    test('isSignedIn is false when currentEmail is null', () {
      const state = AuthState();
      expect(state.isSignedIn, false);
    });

    test('copyWith preserves currentEmail when not provided', () {
      const state = AuthState(currentEmail: 'user@example.com');
      final updated = state.copyWith(error: AuthError.invalidCredentials);
      expect(updated.currentEmail, 'user@example.com');
      expect(updated.error, AuthError.invalidCredentials);
    });

    test('copyWith clears error when clearError is true', () {
      const state = AuthState(
        currentEmail: 'user@example.com',
        error: AuthError.invalidCredentials,
      );
      final updated = state.copyWith(clearError: true);
      expect(updated.error, null);
      expect(updated.currentEmail, 'user@example.com');
    });

    test('copyWith updates currentEmail when provided', () {
      const state = AuthState(currentEmail: 'old@example.com');
      final updated = state.copyWith(currentEmail: 'new@example.com');
      expect(updated.currentEmail, 'new@example.com');
    });
  });

  group('AuthNotifier', () {
    test('AuthError.invalidCredentials is defined', () {
      expect(AuthError.invalidCredentials, isNotNull);
    });

    test('AuthError.emailAlreadyInUse is defined', () {
      expect(AuthError.emailAlreadyInUse, isNotNull);
    });
  });
}
