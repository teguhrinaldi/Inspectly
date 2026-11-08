import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:inspectly/app/theme/app_theme.dart';

/// Renders a single screen inside the app theme with a minimal router (so
/// `context.go/push` work) and the given provider overrides.
Future<void> pumpScreen(
  WidgetTester tester,
  Widget screen, {
  List overrides = const [],
  Size size = const Size(390, 844),
  double textScale = 1.0,
  ThemeMode themeMode = ThemeMode.light,
}) async {
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
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(textScale)),
          child: child!,
        ),
      ),
    ),
  );
}
