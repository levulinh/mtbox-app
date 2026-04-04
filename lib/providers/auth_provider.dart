import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/user_account.dart';

enum AuthError { invalidCredentials, emailAlreadyInUse }

class AuthState {
  final String? currentEmail;
  final AuthError? error;

  const AuthState({this.currentEmail, this.error});

  bool get isSignedIn => currentEmail != null;

  AuthState copyWith({String? currentEmail, AuthError? error, bool clearError = false}) {
    return AuthState(
      currentEmail: currentEmail ?? this.currentEmail,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class AuthNotifier extends Notifier<AuthState> {
  static const _usersBoxName = 'users';
  static const _currentUserKey = 'currentUser';

  Box<UserAccount> get _usersBox => Hive.box<UserAccount>(_usersBoxName);
  Box get _settingsBox => Hive.box('settings');

  @override
  AuthState build() {
    final currentEmail = _settingsBox.get(_currentUserKey) as String?;
    return AuthState(currentEmail: currentEmail);
  }

  Future<void> signIn(String email, String password) async {
    final normalizedEmail = email.trim().toLowerCase();
    final account = _usersBox.get(normalizedEmail);

    if (account == null || account.password != password) {
      state = AuthState(currentEmail: null, error: AuthError.invalidCredentials);
      return;
    }

    await _settingsBox.put(_currentUserKey, normalizedEmail);
    state = AuthState(currentEmail: normalizedEmail);
  }

  Future<void> register(String email, String password) async {
    final normalizedEmail = email.trim().toLowerCase();

    if (_usersBox.containsKey(normalizedEmail)) {
      state = AuthState(currentEmail: null, error: AuthError.emailAlreadyInUse);
      return;
    }

    final account = UserAccount(email: normalizedEmail, password: password);
    await _usersBox.put(normalizedEmail, account);
    await _settingsBox.put(_currentUserKey, normalizedEmail);
    state = AuthState(currentEmail: normalizedEmail);
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }

  Future<void> signOut() async {
    await _settingsBox.delete(_currentUserKey);
    state = const AuthState();
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);
