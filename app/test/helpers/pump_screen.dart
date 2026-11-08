import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:inspectly/app/theme/app_theme.dart';

bool _fontsLoaded = false;

/// Loads the bundled Inter font so text in widget tests has real widths
/// (the default test font draws every glyph as a 1em square, which makes
/// layout checks meaningless).
Future<void> loadAppFonts() async {
  if (_fontsLoaded) return;
  final inter = FontLoader('Inter');
  for (final w in ['Regular', 'Medium', 'SemiBold', 'Bold', 'ExtraBold']) {
    inter.addFont(rootBundle.load('assets/fonts/Inter-$w.ttf'));
  }
  await inter.load();
  _fontsLoaded = true;
}

/// Renders a single screen inside the app theme with a minimal router (so
/// `context.go/push` work) and the given provider overrides.
Future<GoRouter> pumpScreen(
  WidgetTester tester,
  Widget screen, {
  List overrides = const [],
  Size size = const Size(390, 844),
  double textScale = 1.0,
  ThemeMode themeMode = ThemeMode.light,
}) async {
  await tester.runAsync(loadAppFonts);
  tester.view.physicalSize = size * 3;
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  final router = GoRouter(
    routes: [
      GoRoute(path: '/', builder: (_, _) => screen),
      GoRoute(
        path: '/:rest(.*)',
        builder: (_, s) => Scaffold(body: Text('route ${s.uri}')),
      ),
    ],
  );
  addTearDown(router.dispose);
  await tester.pumpWidget(
    ProviderScope(
      // No automatic retries: tests drive retries explicitly.
      retry: (_, _) => null,
      overrides: [...overrides],
      child: MaterialApp.router(
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: themeMode,
        routerConfig: router,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: TextScaler.linear(textScale)),
          child: child!,
        ),
      ),
    ),
  );
  return router;
}
