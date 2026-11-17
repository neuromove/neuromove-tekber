import 'package:flutter/material.dart';

import 'app_colors.dart';

abstract final class AppTheme {
  static ThemeData get light => ThemeData(
    useMaterial3: true,
    fontFamily: 'Poppins',
    // Figma uses zero tracking; Material 3 body styles otherwise add 0.5px.
    textTheme: Typography.material2021().black
        .apply(
          fontFamily: 'Poppins',
          bodyColor: Colors.black,
          displayColor: Colors.black,
        )
        .copyWith(
          bodyLarge: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 16,
            letterSpacing: 0,
            color: Colors.black,
          ),
          bodyMedium: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14,
            letterSpacing: 0,
            color: Colors.black,
          ),
          bodySmall: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 12,
            letterSpacing: 0,
            color: Colors.black,
          ),
          labelLarge: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14,
            letterSpacing: 0,
            color: Colors.black,
          ),
        ),
    colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
    scaffoldBackgroundColor: Colors.white,
    inputDecorationTheme: InputDecorationTheme(
      isDense: true,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: AppColors.primary),
        borderRadius: BorderRadius.circular(9),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: AppColors.primary, width: 1.6),
        borderRadius: BorderRadius.circular(9),
      ),
    ),
  );
}
