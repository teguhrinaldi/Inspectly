import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _themeModePrefKey = 'inspectly.theme_mode';

class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    // Known before the first frame when main() preloaded it, so a saved
    // dark/light choice doesn't flash the system theme first (QC-061).
    final initial = ref.read(initialThemeModeProvider);
    if (initial != null) return initial;
    _restore();
    return ThemeMode.system;
  }

  Future<void> _restore() async {
    state = await loadSavedThemeMode();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeModePrefKey, mode.name);
  }
}

final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(
  ThemeModeNotifier.new,
);

/// Theme mode read from preferences before the first frame (see main.dart).
final initialThemeModeProvider = Provider<ThemeMode?>((ref) => null);

Future<ThemeMode> loadSavedThemeMode() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    return switch (prefs.getString(_themeModePrefKey)) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  } catch (_) {
    return ThemeMode.system;
  }
}
