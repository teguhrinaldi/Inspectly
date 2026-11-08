import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inspectly/app/app.dart';

void main() {
  testWidgets('Welcome → Get Started → Home with five-tab navigation', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 2.625;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const ProviderScope(child: InspectlyApp()));
    await tester.pumpAndSettle();

    expect(find.text('Inspectly'), findsOneWidget);
    expect(find.text('Inspect. Document. Report.'), findsOneWidget);
    expect(find.text('Get Started'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);

    await tester.tap(find.text('Get Started'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Michael Carter'), findsOneWidget);
    expect(find.text("Today's Inspections"), findsOneWidget);
    expect(find.text('Quick Actions'), findsOneWidget);
    expect(find.text('Upcoming Inspections'), findsOneWidget);
    for (final tab in ['Home', 'Inspections', 'Create', 'Reports', 'Profile']) {
      expect(find.bySemanticsLabel(tab), findsWidgets);
    }
  });

  testWidgets('Login button opens the sign-in form', (tester) async {
    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 2.625;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const ProviderScope(child: InspectlyApp()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();
    expect(find.text('Sign in to continue your inspections.'), findsOneWidget);

    await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
    await tester.pumpAndSettle();
    expect(find.text("Today's Inspections"), findsOneWidget);
  });
}
