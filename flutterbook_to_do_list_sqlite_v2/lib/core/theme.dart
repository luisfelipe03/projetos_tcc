import 'package:flutter/material.dart';
import 'constants.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w400,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  static TextStyle get titleStyle => const TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  static TextStyle get subtitleStyle => const TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  static TextStyle get bodyStyle =>
      const TextStyle(fontSize: 16, color: AppColors.textPrimary);

  static TextStyle get bodySecondaryStyle =>
      const TextStyle(fontSize: 16, color: AppColors.textSecondary);

  static TextStyle get tabLabelStyle =>
      const TextStyle(fontSize: 12, color: AppColors.textSecondary);

  static TextStyle tabLabelSelectedStyle(Color color) =>
      TextStyle(fontSize: 12, color: color);

  static TextStyle get buttonStyle =>
      const TextStyle(fontSize: 18, color: AppColors.primary);
}
