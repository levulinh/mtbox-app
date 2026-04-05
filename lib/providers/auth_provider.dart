import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/campaign.dart';
import '../services/supabase_service.dart';

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
  SupabaseClient get _supabase => SupabaseService.client;

  @override
  AuthState build() {
    return AuthState(currentEmail: _supabase.auth.currentUser?.email);
  }

  Future<void> signIn(String email, String password) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );
      state = AuthState(currentEmail: response.user?.email);
    } on AuthException {
      state = const AuthState(error: AuthError.invalidCredentials);
    } catch (_) {
      state = const AuthState(error: AuthError.invalidCredentials);
    }
  }

  Future<void> register(String email, String password) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email.trim(),
        password: password,
      );
      if (response.user == null) {
        // Email confirmation required — user exists but session not started
        state = const AuthState(error: AuthError.emailAlreadyInUse);
        return;
      }
      state = AuthState(currentEmail: response.user!.email);
    } on AuthException catch (e) {
      final msg = e.message.toLowerCase();
      if (msg.contains('already') || msg.contains('registered') || msg.contains('taken')) {
        state = const AuthState(error: AuthError.emailAlreadyInUse);
      } else {
        state = const AuthState(error: AuthError.invalidCredentials);
      }
    } catch (_) {
      state = const AuthState(error: AuthError.invalidCredentials);
    }
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
    state = const AuthState();
  }

  Future<void> clearLocalData() async {
    await Hive.box<Campaign>('campaigns').clear();
    final settings = Hive.box('settings');
    await settings.delete('onboardingDone');
    await settings.delete('cloudSyncDone');
    await settings.delete('hasSampleData');
  }

  Future<void> deleteAccount() async {
    // Clear all local data and sign out. Full server-side account deletion
    // requires a Supabase Edge Function with the service role key.
    await Hive.box<Campaign>('campaigns').clear();
    await Hive.box('settings').clear();
    await _supabase.auth.signOut();
    state = const AuthState();
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);
