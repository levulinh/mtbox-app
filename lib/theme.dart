import 'package:flutter/material.dart';

const kBlue = Color(0xFF1E50FF);
const kBackground = Color(0xFFFAFAFA);
const kBlack = Color(0xFF000000);
const kWhite = Color(0xFFFFFFFF);
const kBorderWidth = 2.0;
const kShadowOffset = 2.0;

final kBrutalistTheme = ThemeData(
  scaffoldBackgroundColor: kBackground,
  colorScheme: const ColorScheme.light(
    primary: kBlue,
    surface: kWhite,
    onPrimary: kWhite,
    onSurface: kBlack,
  ),
  fontFamily: 'monospace',
  textTheme: const TextTheme(
    headlineLarge: TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.w700,
      color: kBlack,
      letterSpacing: 1.2,
    ),
    headlineMedium: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w700,
      color: kBlack,
      letterSpacing: 0.8,
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      color: kBlack,
    ),
    labelSmall: TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w700,
      color: kBlack,
      letterSpacing: 1.0,
    ),
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: kBackground,
    foregroundColor: kBlack,
    elevation: 0,
    titleTextStyle: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w700,
      color: kBlack,
      letterSpacing: 1.0,
    ),
  ),
  useMaterial3: false,
);

BoxDecoration brutalistBox({Color? color, bool filled = false}) {
  return BoxDecoration(
    color: filled ? kBlue : (color ?? kWhite),
    border: Border.all(color: kBlack, width: kBorderWidth),
    boxShadow: const [
      BoxShadow(
        color: kBlack,
        offset: Offset(kShadowOffset, kShadowOffset),
        blurRadius: 0,
      ),
    ],
  );
}
