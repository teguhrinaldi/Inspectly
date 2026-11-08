import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inspectly/features/checklist/widgets/finding_form_sheet.dart';
import 'package:inspectly/features/findings/widgets/photo_capture.dart';

import '../helpers/pump_screen.dart';

/// QC-032: a double tap must not stack two copies of the same sheet.
void main() {
  Future<void> doubleTap(WidgetTester tester, Finder target) async {
    await tester.tap(target);
    await tester.tap(target); // second tap lands before the sheet is shown
    await tester.pumpAndSettle();
  }

  testWidgets('photo source sheet opens once on double tap', (tester) async {
    await pumpScreen(
      tester,
      Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            onPressed: () => capturePhoto(
              context,
              siteName: 'Riverside',
              inspectorName: 'Michael',
            ),
            child: const Text('Add photo'),
          ),
        ),
      ),
    );

    await doubleTap(tester, find.text('Add photo'));

    expect(find.text('Take photo'), findsOneWidget);
  });

  testWidgets('finding form opens once on double tap', (tester) async {
    await pumpScreen(
      tester,
      Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            onPressed: () => FindingFormSheet.show(
              context,
              itemLabel: 'Fire extinguisher',
              siteName: 'Riverside',
              inspectorName: 'Michael',
            ),
            child: const Text('Add finding'),
          ),
        ),
      ),
    );

    await doubleTap(tester, find.text('Add finding'));

    expect(find.byType(FindingFormSheet), findsOneWidget);
  });
}
