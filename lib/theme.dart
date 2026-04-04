import 'package:flutter/material.dart';

// Muted earthy brutalist palette (MTB-23)
const kBlue = Color(0xFF4C6EAD); // dusty slate (was saturated #1E50FF)
const kBackground = Color(0xFFF7F3EF); // warm off-white (was cold #FAFAFA)
const kBlack = Color(0xFF2C2C2C); // dark charcoal (was pure #000000)
const kWhite = Color(0xFFFFFDF9); // warm card white (was pure #FFFFFF)
const kTextPrimary = Color(0xFF1A1A1A); // warm near-black for text
const kTextSecondary = Color(0xFF6B6B6B); // warm medium grey for secondary text
const kTerracotta = Color(0xFFB5735A); // warm terracotta accent
const kBorderWidth = 2.0;
const kShadowOffset = 2.0;

final kBrutalistTheme = ThemeData(
  scaffoldBackgroundColor: kBackground,
  colorScheme: const ColorScheme.light(
    primary: kBlue,
    surface: kWhite,
    onPrimary: kWhite,
    onSurface: kTextPrimary,
  ),
  fontFamily: 'monospace',
  textTheme: const TextTheme(
    headlineLarge: TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.w700,
      color: kTextPrimary,
      letterSpacing: 1.2,
    ),
    headlineMedium: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w700,
      color: kTextPrimary,
      letterSpacing: 0.8,
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      color: kTextPrimary,
    ),
    labelSmall: TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w700,
      color: kTextPrimary,
      letterSpacing: 1.0,
    ),
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: kBackground,
    foregroundColor: kTextPrimary,
    elevation: 0,
    titleTextStyle: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w700,
      color: kTextPrimary,
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
