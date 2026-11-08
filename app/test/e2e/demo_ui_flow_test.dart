import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inspectly/app/app.dart';

import '../helpers/pump_screen.dart';

/// Demo Mode UI journey through the real app: sign in with the form, open
/// an inspection, log out from Profile, and sign in again.
void main() {
  testWidgets('login → inspection → logout → login again', (tester) async {
    await tester.runAsync(loadAppFonts);
    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 2.625;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const ProviderScope(child: InspectlyApp()));
    await tester.pumpAndSettle();

    Future<void> signIn() async {
      await tester.tap(find.text('Login'));
      await tester.pumpAndSettle();
      final fields = find.byType(TextFormField);
      await tester.enterText(fields.first, 'michael.carter@inspectly.test');
      await tester.enterText(fields.last, 'password');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
      await tester.pumpAndSettle();
      expect(find.text("Today's Inspections"), findsOneWidget);
    }

    await signIn();

    await tester.tap(find.bySemanticsLabel('Inspections').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Riverside Office Complex').first);
    await tester.pumpAndSettle();
    expect(find.text('Inspection Detail'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('Profile').last);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Log out'));
    await tester.tap(find.text('Log out'));
    await tester.pumpAndSettle();
    expect(find.text('Get Started'), findsOneWidget);

    await signIn();
  });
}
