import 'package:flutter/material.dart';

/// Design tokens from design/DESIGN.md (palette P18 neon chartreuse).
abstract final class K {
  static const bg = Color(0xFFFAFCF4);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceAlt = Color(0xFFF1F5E4);
  static const neon = Color(0xFFCCFF00);
  static const neonPressed = Color(0xFFB8E600);
  static const accentFill = Color(0xFF647D00);
  static const accentTint = Color(0xFFF8FFDB);
  static const ink = Color(0xFF1C1F0C);
  static const text2 = Color(0xFF4B5034);
  static const text3 = Color(0xFF6A6F52);
  static const border = Color(0xFFE2E7D2);
  static const borderStrong = Color(0xFF92975F);
  static const pink = Color(0xFFFF9BD2);
  static const pinkStrong = Color(0xFFFF4BB2);
  static const success = Color(0xFF0E7C3A);
  static const successTint = Color(0xFFE3F4E9);
  static const warning = Color(0xFFA75906);
  static const warningTint = Color(0xFFFAEFE1);
  static const danger = Color(0xFFCE2020);
  static const onInkMuted = Color(0xFFB9BEA2);

  static const rCard = 20.0;
  static const rControl = 14.0;
  static const rInput = 12.0;
  static const pad = 20.0;

  static const sans = 'Inter';
  static const serif = 'InstrumentSerif';

  static const display = TextStyle(fontFamily: serif, fontSize: 32, height: 1.2, letterSpacing: -0.3, color: ink);
  static const title = TextStyle(fontFamily: sans, fontSize: 20, fontWeight: FontWeight.w600, height: 1.35, color: ink);
  static const body = TextStyle(fontFamily: sans, fontSize: 16, height: 1.5, color: ink);
  static const label = TextStyle(fontFamily: sans, fontSize: 14, fontWeight: FontWeight.w500, height: 1.4, color: ink);
  static const caption = TextStyle(fontFamily: sans, fontSize: 13, fontWeight: FontWeight.w500, height: 1.4, color: text2);
  static const stat = TextStyle(
    fontFamily: sans,
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 1.15,
    color: ink,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  static const shadow = [
    BoxShadow(color: Color(0x0A1C1F0C), blurRadius: 2, offset: Offset(0, 1)),
    BoxShadow(color: Color(0x0F1C1F0C), blurRadius: 24, offset: Offset(0, 8)),
  ];

  static ThemeData theme() => ThemeData(
        useMaterial3: true,
        fontFamily: sans,
        scaffoldBackgroundColor: bg,
        colorScheme: ColorScheme.fromSeed(
          seedColor: neon,
          primary: accentFill,
          onPrimary: Colors.white,
          surface: surface,
          onSurface: ink,
        ),
        splashFactory: InkSparkle.splashFactory,
        snackBarTheme: const SnackBarThemeData(
          backgroundColor: ink,
          contentTextStyle: TextStyle(fontFamily: sans, fontSize: 14, color: Colors.white),
          behavior: SnackBarBehavior.floating,
        ),
        switchTheme: SwitchThemeData(
          trackColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? accentFill : surfaceAlt),
          thumbColor: const WidgetStatePropertyAll(Colors.white),
          trackOutlineColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? accentFill : borderStrong),
        ),
      );
}
