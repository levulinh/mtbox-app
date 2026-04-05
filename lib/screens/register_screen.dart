import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../theme.dart';
import '../widgets/auth_widgets.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _submitted = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  bool get _emailValid => _emailController.text.trim().isNotEmpty;
  bool get _passwordValid => _passwordController.text.length >= 6;
  bool get _passwordsMatch =>
      _passwordController.text == _confirmController.text;

  int get _strengthScore {
    final p = _passwordController.text;
    if (p.isEmpty) return 0;
    int score = 0;
    if (p.length >= 6) score++;
    if (p.contains(RegExp(r'[A-Z]'))) score++;
    if (p.contains(RegExp(r'[0-9]'))) score++;
    if (p.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]'))) score++;
    return score;
  }

  String get _strengthLabel => switch (_strengthScore) {
    0 => '',
    1 => 'Weak Password',
    2 => 'Fair Password',
    3 => 'Good Password',
    _ => 'Strong Password',
  };

  Future<void> _submit() async {
    setState(() => _submitted = true);
    if (!_emailValid || !_passwordValid || !_passwordsMatch) return;

    ref.read(authProvider.notifier).clearError();
    await ref.read(authProvider.notifier).register(
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (!mounted) return;
    final auth = ref.read(authProvider);
    if (auth.isSignedIn) {
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    final hasError = auth.error != null;

    final emailHasError = (_submitted && !_emailValid) ||
        (hasError && auth.error == AuthError.emailAlreadyInUse);

    return Scaffold(
      backgroundColor: kBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Compact inline logo
              const SizedBox(height: 40),
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: kBlue,
                      border: Border.all(color: kBlack, width: kSoftBorderWidth),
                      boxShadow: const [
                        BoxShadow(
                          color: kSoftShadowColor,
                          offset: Offset(kShadowOffset, kShadowOffset),
                          blurRadius: 0,
                        ),
                      ],
                    ),
                    child: const Icon(Icons.menu_book, size: 24, color: kWhite),
                  ),
                  const SizedBox(width: 10),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'MTBOX',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: kTextPrimary,
                          letterSpacing: 1.0,
                        ),
                      ),
                      Text(
                        'CAMPAIGN TRACKER',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: kTextSecondary,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Heading
              const Text(
                'Create Account',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: kTextPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Start tracking your campaigns today',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: kTextSecondary,
                ),
              ),
              const SizedBox(height: 20),

              // Error banner
              if (hasError) ...[
                AuthErrorBanner(
                  message: auth.error == AuthError.emailAlreadyInUse
                      ? 'This email is already in use. Sign in instead.'
                      : 'Something went wrong. Please try again.',
                ),
                const SizedBox(height: 20),
              ],

              // Email field
              AuthFieldLabel('Email'),
              const SizedBox(height: 6),
              AuthField(
                controller: _emailController,
                hasError: emailHasError,
                suffixIcon: Icons.mail_outline,
                keyboardType: TextInputType.emailAddress,
                onChanged: (_) {
                  if (hasError) ref.read(authProvider.notifier).clearError();
                  setState(() {});
                },
              ),
              if (_submitted && !_emailValid) authFieldError('Email is required'),
              if (hasError && auth.error == AuthError.emailAlreadyInUse)
                authFieldError('Email already registered'),
              const SizedBox(height: 16),

              // Password field
              AuthFieldLabel('Password'),
              const SizedBox(height: 6),
              AuthField(
                controller: _passwordController,
                hasError: _submitted && !_passwordValid,
                obscureText: _obscurePassword,
                suffixIcon:
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                onSuffixTap: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
                onChanged: (_) => setState(() {}),
              ),
              if (_submitted && !_passwordValid)
                authFieldError('Password must be at least 6 characters'),
              const SizedBox(height: 16),

              // Confirm password field
              AuthFieldLabel('Confirm Password'),
              const SizedBox(height: 6),
              AuthField(
                controller: _confirmController,
                hasError: _submitted && !_passwordsMatch,
                obscureText: _obscureConfirm,
                suffixIcon:
                    _obscureConfirm ? Icons.visibility_off : Icons.visibility,
                onSuffixTap: () =>
                    setState(() => _obscureConfirm = !_obscureConfirm),
                onChanged: (_) => setState(() {}),
              ),
              if (_submitted && !_passwordsMatch)
                authFieldError("Passwords don't match"),
              const SizedBox(height: 12),

              // Password strength bar
              if (_passwordController.text.isNotEmpty) ...[
                _PasswordStrengthBar(
                  score: _strengthScore,
                  label: _strengthLabel,
                ),
                const SizedBox(height: 16),
              ] else
                const SizedBox(height: 16),

              // Create & Sign In button
              GestureDetector(
                onTap: _submit,
                child: Container(
                  width: double.infinity,
                  height: 52,
                  decoration: BoxDecoration(
                    color: kBlue,
                    border: Border.all(
                      color: kSoftBorderColor,
                      width: kSoftBorderWidth,
                    ),
                    boxShadow: const [
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
                      Icon(Icons.person_add, size: 20, color: kWhite),
                      SizedBox(width: 8),
                      Text(
                        'CREATE & SIGN IN',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          color: kWhite,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // OR divider
              const AuthOrDivider(label: 'already have one?'),
              const SizedBox(height: 18),

              // Sign In Instead button
              GestureDetector(
                onTap: () => context.pop(),
                child: Container(
                  width: double.infinity,
                  height: 52,
                  decoration: BoxDecoration(
                    color: kWhite,
                    border: Border.all(
                      color: kSoftBorderColor,
                      width: kSoftBorderWidth,
                    ),
                    boxShadow: const [
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
                      Icon(Icons.login, size: 20, color: kTextPrimary),
                      SizedBox(width: 8),
                      Text(
                        'SIGN IN INSTEAD',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          color: kTextPrimary,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Cloud persist note
              const AuthSecurityNote(
                icon: Icons.cloud_done,
                message:
                    'Your account persists across app restarts. Sign in on any device to access your campaigns.',
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _PasswordStrengthBar extends StatelessWidget {
  final int score;
  final String label;

  const _PasswordStrengthBar({required this.score, required this.label});

  Color get _segmentColor => switch (score) {
    1 => kAuthRed,
    2 => const Color(0xFFE67E22),
    3 => const Color(0xFF27AE60),
    _ => kBlue,
  };

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: List.generate(4, (i) {
            final filled = i < score;
            return Expanded(
              child: Container(
                height: 3,
                margin: EdgeInsets.only(right: i < 3 ? 3 : 0),
                decoration: BoxDecoration(
                  color: filled ? _segmentColor : const Color(0xFFE8E2DA),
                  border: Border.all(
                    color: filled
                        ? kSoftBorderColor
                        : const Color(0xFFB0A898),
                    width: 1,
                  ),
                ),
              ),
            );
          }),
        ),
        if (label.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: _segmentColor,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ],
    );
  }
}
