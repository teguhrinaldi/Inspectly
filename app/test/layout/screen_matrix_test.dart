import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inspectly/app/app.dart';
import 'package:inspectly/app/providers/repository_providers.dart';
import 'package:inspectly/app/router/app_router.dart';

import '../helpers/pump_screen.dart';
import 'extreme_data.dart';

/// Renders every main screen of the real app (router, phone shell / tablet
/// sidebar) at several sizes and text scales with worst-case data, and
/// fails on ANY FlutterError (RenderFlex overflow, unbounded constraints,
/// exceptions during build/layout/paint).
const sizes = <String, Size>{
  'phone 360x640': Size(360, 640),
  'phone 390x844': Size(390, 844),
  'tablet 768x1024': Size(768, 1024),
  'phone landscape 640x360': Size(640, 360),
  'phone landscape 844x390': Size(844, 390),
  'tablet landscape 1024x768': Size(1024, 768),
};
const textScales = [1.0, 1.5];

List<String> routesFor(LayoutDataset d) {
  final run = d.detailInProgress.id;
  final done = d.detailCompleted.id;
  return [
    '/home',
    '/inspections',
    '/inspections/$run',
    '/inspections/$done',
    '/inspections/$run/findings',
    '/inspections/$run/evidence',
    '/inspections/$run/signature',
    '/inspections/$done/summary',
    '/inspections/$done/comparison',
    '/checklist/$run',
    '/create',
    '/create?view=templates',
    '/reports',
    '/profile',
    '/qr-scanner',
    '/report/$done',
  ];
}

const signedOutRoutes = ['/welcome', '/login'];

/// Collects FlutterErrors with the app source location that caused them.
class _ErrorLog {
  final entries = <String>{};
  void Function(FlutterErrorDetails)? _previous;

  void start(String Function() where) {
    _previous = FlutterError.onError;
    FlutterError.onError = (details) {
      final text = details.toString().replaceAll('\\', '/');
      // The app file that created the failing widget, else the first
      // app frame mentioned anywhere in the report.
      final source =
          RegExp(
            r'error-causing widget was:\s*\n\s*(\S+)\s*\n\s*\S*?(lib/[\w/]+\.dart:\d+)',
          ).firstMatch(text)?.let((m) => '${m.group(1)} ${m.group(2)}') ??
          RegExp(r'inspectly/(lib/[\w/]+\.dart:\d+)')
              .firstMatch(text)
              ?.group(1);
      entries.add(
        '${where()}: ${details.exceptionAsString().split('\n').first}'
        '${source == null ? '' : '  [$source]'}',
      );
    };
  }

  void stop() => FlutterError.onError = _previous;
}

Future<void> _settle(WidgetTester tester) async {
  // Not pumpAndSettle: some screens show endless progress indicators.
  for (var i = 0; i < 6; i++) {
    await tester.pump(const Duration(milliseconds: 150));
  }
}

void main() {
  final runs = <(String, LayoutDataset, bool)>[
    ('extreme', extremeDataset(), true),
    ('empty', emptyDataset(), true),
    ('signed out', emptyDataset(), false),
  ];
  for (final (label, dataset, signedIn) in runs) {
    for (final size in sizes.entries) {
      for (final scale in textScales) {
        testWidgets('$label · ${size.key} · text ${scale}x', (tester) async {
          await tester.runAsync(loadAppFonts);
          tester.view.physicalSize = size.value * 2;
          tester.view.devicePixelRatio = 2;
          addTearDown(tester.view.reset);

          var where = 'startup';
          final log = _ErrorLog()..start(() => where);
          try {
            await tester.pumpWidget(
              ProviderScope(
                retry: (_, _) => null,
                overrides: [
                  authRepositoryProvider.overrideWithValue(
                    FakeAuth(signedIn: signedIn),
                  ),
                  inspectionRepositoryProvider.overrideWithValue(
                    FakeInspections(dataset),
                  ),
                  siteRepositoryProvider.overrideWithValue(FakeSites(dataset)),
                  templateRepositoryProvider.overrideWithValue(
                    FakeTemplates(dataset),
                  ),
                ],
                child: MediaQuery(
                  data: MediaQueryData(
                    size: size.value,
                    devicePixelRatio: 2,
                    textScaler: TextScaler.linear(scale),
                    padding: const EdgeInsets.only(top: 24, bottom: 16),
                    viewPadding: const EdgeInsets.only(top: 24, bottom: 16),
                  ),
                  child: const InspectlyApp(),
                ),
              ),
            );
            await _settle(tester);
            final container = ProviderScope.containerOf(
              tester.element(find.byType(InspectlyApp)),
            );
            for (final route
                in signedIn ? routesFor(dataset) : signedOutRoutes) {
              where = route;
              container.read(routerProvider).go(route);
              await _settle(tester);
              final e = tester.takeException();
              if (e != null) log.entries.add('$route: uncaught $e');
            }
          } finally {
            log.stop();
          }
          expect(log.entries, isEmpty, reason: log.entries.join('\n'));
        });
      }
    }
  }
}

extension<T> on T {
  R let<R>(R Function(T) f) => f(this);
}
