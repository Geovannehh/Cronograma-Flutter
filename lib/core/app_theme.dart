import 'package:flutter/material.dart';

class AppColors {
  static const bg = Color(0xFFF6F7FB);
  static const surface = Color(0xFFFFFFFF);
  static const ink = Color(0xFF1D2141);
  static const muted = Color(0xFF7C819B);
  static const indigo = Color(0xFF6557F5);
  static const softIndigo = Color(0xFFF0EEFF);
  static const cyan = Color(0xFF20BFC5);
  static const blue = Color(0xFF4387EC);
  static const orange = Color(0xFFFFA34A);
  static const pink = Color(0xFFE96CA9);
  static const green = Color(0xFF28B887);
  static const divider = Color(0xFFEDF0F6);
  static const sidebar = Color(0xFF171B38);
}

ThemeData buildAppTheme() {
  const seed = AppColors.indigo;
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.bg,
    colorScheme: ColorScheme.fromSeed(
      seedColor: seed,
      primary: seed,
      surface: AppColors.surface,
    ),
    fontFamily: 'Roboto',
    appBarTheme: const AppBarTheme(
      surfaceTintColor: Colors.transparent,
      backgroundColor: AppColors.bg,
      foregroundColor: AppColors.ink,
      elevation: 0,
    ),
    textTheme: const TextTheme(
      headlineMedium: TextStyle(fontSize: 29, fontWeight: FontWeight.w800, color: AppColors.ink, letterSpacing: -0.8),
      titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.ink),
      titleMedium: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.ink),
      bodyMedium: TextStyle(fontSize: 14, color: AppColors.ink),
      bodySmall: TextStyle(fontSize: 12, color: AppColors.muted),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.bg,
      contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
      hintStyle: const TextStyle(color: AppColors.muted),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(13), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(13), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(13), borderSide: const BorderSide(color: AppColors.indigo, width: 1.5)),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: AppColors.sidebar,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.indigo,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
      ),
    ),
  );
}
