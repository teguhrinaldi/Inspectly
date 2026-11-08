import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inspectly/app/app.dart';
import 'package:inspectly/data/models/enums.dart';
import 'package:inspectly/data/models/inspection.dart';
import 'package:inspectly/features/dashboard/home_data.dart';

void main() {
  void landscapeTablet(WidgetTester tester) {
    // 1280 × 800 dp, like a 10" tablet in landscape.
    tester.view.physicalSize = const Size(2560, 1600);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
  }

  testWidgets('Tablet: two-column login, then Home with a sidebar', (
    tester,
  ) async {
    landscapeTablet(tester);
    await tester.pumpWidget(const ProviderScope(child: InspectlyApp()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();
    expect(find.text('Safer Sites.\nBetter Decisions.'), findsOneWidget);
    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text('Forgot password?'), findsOneWidget);

    await tester.tap(find.text('Continue with Demo Account'));
    await tester.pumpAndSettle();

    expect(find.text('Welcome back'), findsNothing, reason: 'still on login');
    expect(find.textContaining('Michael Carter'), findsWidgets);

    // Sidebar instead of the bottom bar.
    for (final item in [
      'Home',
      'Inspections',
      'New Inspection',
      'Templates',
      'Reports',
      'Profile',
    ]) {
      expect(find.bySemanticsLabel(item), findsWidgets);
    }
    expect(find.bySemanticsLabel('Create'), findsNothing);

    // Tablet Home composition, from the demo data (docs/demo-data.md).
    expect(find.text('Continue'), findsOneWidget);
    expect(find.text('Riverside Office Complex'), findsWidgets);
    expect(find.text('7 / 12 items'), findsWidgets);
    expect(find.bySemanticsLabel('3 Scheduled'), findsOneWidget);
    expect(find.bySemanticsLabel('2 In Progress'), findsOneWidget);
    expect(find.bySemanticsLabel('1 Needs Review'), findsOneWidget);
    expect(find.text("Today's Inspections"), findsOneWidget);
    expect(find.text('Quick Actions'), findsOneWidget);
    expect(find.text('Recent Reports'), findsOneWidget);
    expect(find.text('Upcoming Inspections'), findsNothing);
  });

  group('HomeData.today', () {
    final now = DateTime(2026, 9, 30, 10);
    Inspection make(
      String id,
      InspectionStatus status, {
      DateTime? scheduledAt,
      DateTime? completedAt,
      String inspector = 'me',
    }) => Inspection(
      id: id,
      templateId: 't',
      templateName: 'Safety Inspection',
      customerId: 'c',
      customerName: 'Customer',
      siteId: 's',
      siteName: 'Site $id',
      inspectorId: inspector,
      inspectorName: 'Inspector',
      status: status,
      scheduledAt: scheduledAt,
      completedAt: completedAt,
    );

    test(
      'open work due by today and today\'s completions, in progress first',
      () {
        final data = HomeData(
          [
            make(
              'later',
              InspectionStatus.scheduled,
              scheduledAt: DateTime(2026, 10, 2),
            ),
            make(
              'today',
              InspectionStatus.scheduled,
              scheduledAt: DateTime(2026, 9, 30, 14),
            ),
            make(
              'overdue',
              InspectionStatus.inProgress,
              scheduledAt: DateTime(2026, 9, 28),
            ),
            make(
              'done-today',
              InspectionStatus.completed,
              completedAt: DateTime(2026, 9, 30, 9),
            ),
            make(
              'done-before',
              InspectionStatus.completed,
              completedAt: DateTime(2026, 9, 27),
            ),
            make(
              'other',
              InspectionStatus.scheduled,
              scheduledAt: DateTime(2026, 9, 30),
              inspector: 'x',
            ),
          ],
          'me',
          now: now,
        );
        expect(data.today.map((i) => i.id), ['overdue', 'today', 'done-today']);
        expect(data.activeInspection?.id, 'overdue');
        expect(data.recentReports.map((i) => i.id), [
          'done-today',
          'done-before',
        ]);
      },
    );
  });
}
