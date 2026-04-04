import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../theme.dart';
import '../widgets/auth_widgets.dart';

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _submitted = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool get _emailValid => _emailController.text.trim().isNotEmpty;
  bool get _passwordValid => _passwordController.text.isNotEmpty;

  Future<void> _submit() async {
    setState(() => _submitted = true);
    if (!_emailValid || !_passwordValid) return;

    ref.read(authProvider.notifier).clearError();
    await ref.read(authProvider.notifier).signIn(
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
        (hasError && auth.error == AuthError.invalidCredentials);
    final passwordHasError = (_submitted && !_passwordValid) ||
        (hasError && auth.error == AuthError.invalidCredentials);

    return Scaffold(
      backgroundColor: kBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Logo block
              const SizedBox(height: 48),
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: kBlue,
                        border: Border.all(color: kBlack, width: kBorderWidth),
                        boxShadow: const [
                          BoxShadow(
                            color: kSoftShadowColor,
                            offset: Offset(kShadowOffset, kShadowOffset),
                            blurRadius: 0,
                          ),
                        ],
                      ),
                      child: const Icon(Icons.menu_book, size: 40, color: kWhite),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'MTBOX',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: kTextPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const Text(
                      'CAMPAIGN TRACKER',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: kTextSecondary,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // Heading
              const Text(
                'Welcome Back',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: kTextPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Sign in to continue your campaigns',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: kTextSecondary,
                ),
              ),
              const SizedBox(height: 28),

              // Error banner
              if (hasError) ...[
                AuthErrorBanner(
                  message: auth.error == AuthError.emailAlreadyInUse
                      ? 'This email is already in use. Sign in instead.'
                      : 'Invalid email or password. Please try again.',
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
              if (hasError && auth.error == AuthError.invalidCredentials)
                authFieldError('No account found for this email'),
              const SizedBox(height: 16),

              // Password field
              AuthFieldLabel('Password'),
              const SizedBox(height: 6),
              AuthField(
                controller: _passwordController,
                hasError: passwordHasError,
                obscureText: _obscurePassword,
                suffixIcon: _obscurePassword ? Icons.visibility_off : Icons.visibility,
                onSuffixTap: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
                onChanged: (_) {
                  if (hasError) ref.read(authProvider.notifier).clearError();
                  setState(() {});
                },
              ),
              const SizedBox(height: 6),

              // Forgot password
              const Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'FORGOT PASSWORD?',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: kBlue,
                    letterSpacing: 0.5,
                    decoration: TextDecoration.underline,
                    decorationColor: kBlue,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Sign In / Try Again button
              GestureDetector(
                onTap: _submit,
                child: Container(
                  width: double.infinity,
                  height: 52,
                  decoration: BoxDecoration(
                    color: hasError ? kAuthRed : kBlue,
                    border: Border.all(
                      color: kSoftBorderColor,
                      width: kSoftBorderWidth,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: hasError
                            ? kAuthRed.withAlpha(128)
                            : kSoftShadowColor,
                        offset: const Offset(kShadowOffset, kShadowOffset),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.login, size: 20, color: kWhite),
                      const SizedBox(width: 8),
                      Text(
                        hasError ? 'TRY AGAIN' : 'SIGN IN',
                        style: const TextStyle(
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
              const SizedBox(height: 20),

              // OR divider
              const AuthOrDivider(label: 'or'),
              const SizedBox(height: 20),

              // Create Account button
              GestureDetector(
                onTap: () => context.push('/register'),
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
                      Icon(Icons.person_add, size: 20, color: kTextPrimary),
                      SizedBox(width: 8),
                      Text(
                        'CREATE ACCOUNT',
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

              // Security note
              const AuthSecurityNote(
                icon: Icons.lock,
                message:
                    'Your data is encrypted and synced securely. Your campaigns are backed up to the cloud.',
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
