import 'package:flutter/material.dart';

/// Raw color tokens sampled from docs/design/inspectly_master_mockup.png.
/// Widgets read theme-aware values through `context.palette` (see
/// [AppPalette]); only the theme and [AppPalette] reference these directly.
class AppColors {
  AppColors._();

  static const white = Color(0xFFFFFFFF);

  // Brand
  static const primary = Color(0xFF1677FF);
  static const primaryPressed = Color(0xFF0B63E5);
  static const navy = Color(0xFF16244A);
  static const sidebar = Color(0xFF0E1A33);

  // Light surfaces + text
  static const lightBackground = Color(0xFFF5F7FB);
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightSurfaceAlt = Color(0xFFF1F5FB);
  static const lightBorder = Color(0xFFE5EAF2);
  static const lightTextPrimary = Color(0xFF16244A);
  static const lightTextSecondary = Color(0xFF5E6E8E);
  static const lightTextMuted = Color(0xFF97A3BA);

  // Dark surfaces + text
  static const darkBackground = Color(0xFF0B1220);
  static const darkSurface = Color(0xFF131C2F);
  static const darkSurfaceAlt = Color(0xFF1B2640);
  static const darkBorder = Color(0xFF26324D);
  static const darkTextPrimary = Color(0xFFE9EEF8);
  static const darkTextSecondary = Color(0xFFA5B1C8);
  static const darkTextMuted = Color(0xFF6F7C96);
  static const darkPrimary = Color(0xFF3B8BFF);

  // Semantic hues + their light-mode tinted surfaces
  static const blue = Color(0xFF1677FF);
  static const blueSoft = Color(0xFFEAF2FF);
  static const green = Color(0xFF16A34A);
  static const greenSoft = Color(0xFFE7F7EE);
  static const teal = Color(0xFF0E9F6E);
  static const tealSoft = Color(0xFFE6F7F1);
  static const orange = Color(0xFFF07A12);
  static const orangeSoft = Color(0xFFFFF1E3);
  static const coral = Color(0xFFE4572E);
  static const coralSoft = Color(0xFFFDECE6);
  static const red = Color(0xFFE02D2D);
  static const redSoft = Color(0xFFFDEBEB);
  static const amber = Color(0xFFE5A000);
  static const amberSoft = Color(0xFFFFF7E0);
  static const slate = Color(0xFF64748B);
  static const slateSoft = Color(0xFFEEF2F7);
}

/// A foreground hue plus the tinted surface it sits on in light mode. In dark
/// mode the surface is derived from the hue so tiles stay readable.
class Tone {
  const Tone(this.fg, this.lightBg);
  final Color fg;
  final Color lightBg;

  static const blue = Tone(AppColors.blue, AppColors.blueSoft);
  static const green = Tone(AppColors.green, AppColors.greenSoft);
  static const teal = Tone(AppColors.teal, AppColors.tealSoft);
  static const orange = Tone(AppColors.orange, AppColors.orangeSoft);
  static const coral = Tone(AppColors.coral, AppColors.coralSoft);
  static const red = Tone(AppColors.red, AppColors.redSoft);
  static const amber = Tone(AppColors.amber, AppColors.amberSoft);
  static const slate = Tone(AppColors.slate, AppColors.slateSoft);
}

@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette({
    required this.isDark,
    required this.background,
    required this.surface,
    required this.surfaceAlt,
    required this.border,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.primary,
    required this.primarySoft,
  });

  final bool isDark;
  final Color background;
  final Color surface;
  final Color surfaceAlt;
  final Color border;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color primary;
  final Color primarySoft;

  Color tint(Tone tone) =>
      isDark ? tone.fg.withValues(alpha: 0.16) : tone.lightBg;

  Color fg(Tone tone) =>
      isDark ? Color.lerp(tone.fg, Colors.white, 0.18)! : tone.fg;

  static const light = AppPalette(
    isDark: false,
    background: AppColors.lightBackground,
    surface: AppColors.lightSurface,
    surfaceAlt: AppColors.lightSurfaceAlt,
    border: AppColors.lightBorder,
    textPrimary: AppColors.lightTextPrimary,
    textSecondary: AppColors.lightTextSecondary,
    textMuted: AppColors.lightTextMuted,
    primary: AppColors.primary,
    primarySoft: AppColors.blueSoft,
  );

  static const dark = AppPalette(
    isDark: true,
    background: AppColors.darkBackground,
    surface: AppColors.darkSurface,
    surfaceAlt: AppColors.darkSurfaceAlt,
    border: AppColors.darkBorder,
    textPrimary: AppColors.darkTextPrimary,
    textSecondary: AppColors.darkTextSecondary,
    textMuted: AppColors.darkTextMuted,
    primary: AppColors.darkPrimary,
    primarySoft: Color(0xFF16284A),
  );

  @override
  AppPalette copyWith() => this;

  @override
  AppPalette lerp(AppPalette? other, double t) =>
      t < 0.5 ? this : (other ?? this);
}

extension PaletteContext on BuildContext {
  AppPalette get palette => Theme.of(this).extension<AppPalette>()!;
}
