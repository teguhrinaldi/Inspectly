import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inspectly/app/providers/theme_providers.dart';
import 'package:inspectly/core/widgets/app_image.dart';

import '../helpers/pump_screen.dart';

void main() {
  /// QC-060: an empty avatar URL shows initials, not a broken image icon.
  testWidgets('empty avatar url falls back to initials', (tester) async {
    await pumpScreen(
      tester,
      const Scaffold(body: AppAvatar(url: '', name: 'Michael Carter')),
    );
    await tester.pumpAndSettle();
    expect(find.text('MC'), findsOneWidget);
  });

  /// QC-061: the saved theme is known before the first frame (no flash of
  /// the system theme on a cold start).
  test('saved theme mode is used from the very first read', () {
    final c = ProviderContainer(
      overrides: [
        initialThemeModeProvider.overrideWithValue(ThemeMode.dark),
      ],
    );
    addTearDown(c.dispose);
    expect(c.read(themeModeProvider), ThemeMode.dark);
  });
}
