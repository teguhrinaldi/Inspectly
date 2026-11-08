import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get light => _build(AppPalette.light);
  static ThemeData get dark => _build(AppPalette.dark);

  static ThemeData _build(AppPalette p) {
    final scheme =
        (p.isDark ? const ColorScheme.dark() : const ColorScheme.light())
            .copyWith(
              primary: p.primary,
              onPrimary: AppColors.white,
              secondary: p.primary,
              onSecondary: AppColors.white,
              error: AppColors.red,
              onError: AppColors.white,
              surface: p.surface,
              onSurface: p.textPrimary,
              onSurfaceVariant: p.textSecondary,
              outline: p.border,
              outlineVariant: p.border,
              surfaceContainerHighest: p.surfaceAlt,
            );
    final radius12 = BorderRadius.circular(12);

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      brightness: scheme.brightness,
      fontFamily: 'Inter',
      extensions: [p],
      scaffoldBackgroundColor: p.background,
      canvasColor: p.surface,
      dividerColor: p.border,
      dividerTheme: DividerThemeData(color: p.border, thickness: 1, space: 1),
      splashFactory: InkRipple.splashFactory,
      textTheme: TextTheme(
        headlineSmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: p.textPrimary,
          letterSpacing: -0.3,
        ),
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: p.textPrimary,
          letterSpacing: -0.2,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: p.textPrimary,
        ),
        titleSmall: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: p.textPrimary,
        ),
        bodyLarge: TextStyle(fontSize: 15, color: p.textPrimary),
        bodyMedium: TextStyle(fontSize: 14, color: p.textPrimary),
        bodySmall: TextStyle(fontSize: 12.5, color: p.textSecondary),
        labelLarge: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: p.background,
        foregroundColor: p.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: 'Inter',
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: p.textPrimary,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: p.surface,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: p.border),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: p.surface,
        hintStyle: TextStyle(color: p.textMuted, fontSize: 14),
        labelStyle: TextStyle(color: p.textSecondary),
        prefixIconColor: p.textMuted,
        suffixIconColor: p.textMuted,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: radius12,
          borderSide: BorderSide(color: p.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: radius12,
          borderSide: BorderSide(color: p.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: radius12,
          borderSide: BorderSide(color: p.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: radius12,
          borderSide: const BorderSide(color: AppColors.red),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: p.primary,
          foregroundColor: AppColors.white,
          disabledBackgroundColor: p.primary.withValues(alpha: 0.35),
          disabledForegroundColor: AppColors.white.withValues(alpha: 0.9),
          elevation: 0,
          minimumSize: const Size(0, 52),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          shape: RoundedRectangleBorder(borderRadius: radius12),
          textStyle: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 15.5,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: p.primary,
          minimumSize: const Size(0, 52),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          side: BorderSide(color: p.primary),
          shape: RoundedRectangleBorder(borderRadius: radius12),
          textStyle: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 15.5,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: p.primary,
          textStyle: const TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: p.surface,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        dragHandleColor: p.border,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: p.surface,
        surfaceTintColor: Colors.transparent,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: p.primary,
        linearTrackColor: p.primarySoft,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: p.isDark ? AppColors.darkSurfaceAlt : AppColors.navy,
        contentTextStyle: const TextStyle(color: AppColors.white),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: radius12),
      ),
    );
  }
}
