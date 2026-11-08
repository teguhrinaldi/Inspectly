import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inspectly/app/app.dart';
import 'package:inspectly/app/providers/repository_providers.dart';
import 'package:inspectly/app/router/app_router.dart';
import 'package:inspectly/data/datasources/demo/demo_data_store.dart';
import 'package:inspectly/data/models/enums.dart';
import 'package:signature/signature.dart';

import '../helpers/fake_auth.dart';
import '../helpers/pump_screen.dart';

/// QC-031: Android back on another tab returns to Home instead of closing
/// the app, and unsaved signatures / finding forms ask before discarding.
void main() {
  final store = DemoDataStore.instance;
  final running = store.inspections.firstWhere(
    (i) => i.status == InspectionStatus.inProgress && i.items.isNotEmpty,
  );

  Future<GoRouterLike> boot(WidgetTester tester) async {
    await tester.runAsync(loadAppFonts);
    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 2.625;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(
            SignedInAs(running.inspectorId),
          ),
        ],
        child: const InspectlyApp(),
      ),
    );
    await tester.pumpAndSettle();
    final c = ProviderScope.containerOf(
      tester.element(find.byType(InspectlyApp)),
    );
    return GoRouterLike((route) async {
      c.read(routerProvider).go(route);
      await tester.pumpAndSettle();
    });
  }

  testWidgets('back on the Reports tab goes to Home', (tester) async {
    final go = await boot(tester);
    await go('/reports');
    expect(find.text("Today's Inspections"), findsNothing);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(find.text("Today's Inspections"), findsOneWidget);
  });

  testWidgets('leaving an unsaved signature asks first', (tester) async {
    final go = await boot(tester);
    await go('/inspections/${running.id}');
    await go('/inspections/${running.id}/signature');
    final pad = find.byType(Signature).first;
    await tester.drag(pad, const Offset(120, 30));
    await tester.pumpAndSettle();

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(find.text('Discard changes?'), findsOneWidget);
    await tester.tap(find.text('Keep editing'));
    await tester.pumpAndSettle();
    expect(find.byType(Signature), findsWidgets);
  });

  testWidgets('closing a filled-in finding form asks first', (tester) async {
    final go = await boot(tester);
    await go('/checklist/${running.id}');
    await tester.tap(find.text('Fail').first);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).first, 'Loose cable');
    await tester.pumpAndSettle();

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(find.text('Discard changes?'), findsOneWidget);
  });
}

class GoRouterLike {
  GoRouterLike(this._go);
  final Future<void> Function(String) _go;
  Future<void> call(String route) => _go(route);
}
