import 'package:flutter/material.dart';
import '../theme.dart';

const kAuthRed = Color(0xFFC0392B);
const _kRedLight = Color(0xFFFDF3F2);

class AuthFieldLabel extends StatelessWidget {
  final String text;
  const AuthFieldLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w900,
        color: kTextPrimary,
        letterSpacing: 1.0,
      ),
    );
  }
}

class AuthField extends StatelessWidget {
  final TextEditingController controller;
  final bool hasError;
  final IconData suffixIcon;
  final bool obscureText;
  final TextInputType keyboardType;
  final VoidCallback? onSuffixTap;
  final ValueChanged<String>? onChanged;

  const AuthField({
    super.key,
    required this.controller,
    required this.hasError,
    required this.suffixIcon,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.onSuffixTap,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: hasError ? _kRedLight : kWhite,
        border: Border.all(
          color: hasError ? kAuthRed : kSoftBorderColor,
          width: hasError ? 2.0 : kSoftBorderWidth,
        ),
        boxShadow: [
          BoxShadow(
            color: hasError ? kAuthRed.withAlpha(102) : kSoftShadowColor,
            offset: const Offset(kShadowOffset, kShadowOffset),
            blurRadius: 0,
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              obscureText: obscureText,
              keyboardType: keyboardType,
              onChanged: onChanged,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: kTextPrimary,
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 14),
                isDense: true,
              ),
            ),
          ),
          GestureDetector(
            onTap: onSuffixTap,
            child: Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Icon(
                suffixIcon,
                size: 18,
                color: hasError ? kAuthRed : kTextSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Widget authFieldError(String message) {
  return Padding(
    padding: const EdgeInsets.only(top: 4),
    child: Row(
      children: [
        const Icon(Icons.cancel, size: 11, color: kAuthRed),
        const SizedBox(width: 3),
        Text(
          message.toUpperCase(),
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: kAuthRed,
            letterSpacing: 0.5,
          ),
        ),
      ],
    ),
  );
}

class AuthErrorBanner extends StatelessWidget {
  final String message;
  const AuthErrorBanner({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: kAuthRed,
        border: Border.all(color: kSoftBorderColor, width: kSoftBorderWidth),
        boxShadow: const [
          BoxShadow(
            color: kSoftShadowColor,
            offset: Offset(kShadowOffset, kShadowOffset),
            blurRadius: 0,
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          const Icon(Icons.error_outline, size: 18, color: kWhite),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message.toUpperCase(),
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: kWhite,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AuthOrDivider extends StatelessWidget {
  final String label;
  const AuthOrDivider({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1.5,
            color: kSoftBorderColor.withAlpha(102),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              color: kTextSecondary,
              letterSpacing: 1.0,
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 1.5,
            color: kSoftBorderColor.withAlpha(102),
          ),
        ),
      ],
    );
  }
}

class AuthSecurityNote extends StatelessWidget {
  final IconData icon;
  final String message;
  const AuthSecurityNote({super.key, required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFEEF2F8),
        border: Border.all(color: kBlue, width: kSoftBorderWidth),
        boxShadow: [
          BoxShadow(
            color: kBlue.withAlpha(77),
            offset: const Offset(kShadowOffset, kShadowOffset),
            blurRadius: 0,
          ),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: kBlue),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: kBlue,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
