import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inspectly/app/app.dart';

import '../helpers/pump_screen.dart';

/// QC-018: after leaving the dark Welcome screen, the light Home screen must
/// get dark status bar icons (they used to stay white on #F5F7FB).
void main() {
  testWidgets('Home uses dark status bar icons in light mode', (tester) async {
    await tester.runAsync(loadAppFonts);
    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 2.625;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const ProviderScope(child: InspectlyApp()));
    await tester.pumpAndSettle();
    expect(SystemChrome.latestStyle?.statusBarIconBrightness, Brightness.light);

    await tester.tap(find.text('Get Started'));
    await tester.pumpAndSettle();

    expect(find.text("Today's Inspections"), findsOneWidget);
    expect(SystemChrome.latestStyle?.statusBarIconBrightness, Brightness.dark);

    for (final tab in ['Inspections', 'Reports', 'Profile', 'Home']) {
      await tester.tap(find.bySemanticsLabel(tab).last);
      await tester.pumpAndSettle();
      expect(
        SystemChrome.latestStyle?.statusBarIconBrightness,
        Brightness.dark,
        reason: tab,
      );
    }
  });

  testWidgets('Home uses light status bar icons in dark mode', (tester) async {
    await tester.runAsync(loadAppFonts);
    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 2.625;
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);

    await tester.pumpWidget(const ProviderScope(child: InspectlyApp()));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Get Started'));
    await tester.pumpAndSettle();

    for (final tab in ['Home', 'Inspections', 'Reports', 'Profile']) {
      await tester.tap(find.bySemanticsLabel(tab).last);
      await tester.pumpAndSettle();
      expect(
        SystemChrome.latestStyle?.statusBarIconBrightness,
        Brightness.light,
        reason: tab,
      );
    }
  });
}
