import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inspectly/data/models/evidence.dart';
import 'package:inspectly/features/findings/widgets/finding_widgets.dart';

import '../helpers/pump_screen.dart';

/// QC-046: the "n / total" title follows the photo being viewed.
void main() {
  testWidgets('title updates when swiping between photos', (tester) async {
    final items = [
      for (var i = 0; i < 3; i++)
        Evidence(id: 'e$i', inspectionId: '1', filePath: 'missing_$i.jpg'),
    ];
    await pumpScreen(tester, EvidenceViewer(items: items, index: 0));
    await tester.pumpAndSettle();
    expect(find.text('1 / 3'), findsOneWidget);

    await tester.fling(find.byType(PageView), const Offset(-400, 0), 1500);
    await tester.pumpAndSettle();

    expect(find.text('2 / 3'), findsOneWidget);
  });
}
