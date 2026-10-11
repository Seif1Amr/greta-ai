import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData darkTheme({bool isArabic = false}) {
    final baseTextTheme = ThemeData.dark().textTheme;
    final textTheme = isArabic
        ? GoogleFonts.readexProTextTheme(baseTextTheme)
        : GoogleFonts.outfitTextTheme(baseTextTheme);

    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.backgroundBase,
      primaryColor: AppColors.cyanGlow,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.cyanGlow,
        secondary: AppColors.cyanSoft,
        surface: AppColors.surfaceElevated,
        error: AppColors.error,
        onPrimary: AppColors.backgroundBase,
        onSecondary: Colors.white,
        onSurface: AppColors.textHighEmphasis,
      ),
      textTheme: textTheme.copyWith(
        headlineLarge: textTheme.headlineLarge?.copyWith(
          color: AppColors.textHighEmphasis,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
        ),
        headlineMedium: textTheme.headlineMedium?.copyWith(
          color: AppColors.textHighEmphasis,
          fontWeight: FontWeight.w700,
        ),
        titleLarge: textTheme.titleLarge?.copyWith(
          color: AppColors.textHighEmphasis,
          fontWeight: FontWeight.w700,
        ),
        titleMedium: textTheme.titleMedium?.copyWith(
          color: AppColors.textHighEmphasis,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: textTheme.bodyLarge?.copyWith(
          color: AppColors.textHighEmphasis,
          height: 1.5,
        ),
        bodyMedium: textTheme.bodyMedium?.copyWith(
          color: AppColors.textMediumEmphasis,
          height: 1.4,
        ),
        bodySmall: textTheme.bodySmall?.copyWith(
          color: AppColors.textLowEmphasis,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: AppColors.textHighEmphasis),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surfaceElevated,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.borderSubtle, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.cyanGlow,
          foregroundColor: AppColors.backgroundBase,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.cyanGlow,
          side: const BorderSide(color: AppColors.cyanGlow, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surfaceBase,
        selectedItemColor: AppColors.cyanGlow,
        unselectedItemColor: AppColors.textLowEmphasis,
        type: BottomNavigationBarType.fixed,
        elevation: 16,
      ),
    );
  }
}
