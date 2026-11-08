import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inspectly/app/providers/repository_providers.dart';
import 'package:inspectly/data/datasources/demo/demo_data_store.dart';
import 'package:inspectly/data/models/enums.dart';
import 'package:inspectly/features/checklist/checklist_screen.dart';

import '../helpers/fake_auth.dart';
import '../helpers/pump_screen.dart';

/// QC-062: turning a failed item into Pass asks whether its open finding
/// should be closed, and closes it when the inspector agrees.
void main() {
  testWidgets('Fail → Pass offers to close the item\'s finding', (tester) async {
    final store = DemoDataStore.instance;
    final inspection = store.inspections.firstWhere(
      (i) =>
          i.status == InspectionStatus.inProgress &&
          i.items.any(
            (item) =>
                item.result == ChecklistResult.fail &&
                i.findings.any(
                  (f) =>
                      f.inspectionItemId == item.id &&
                      f.status == FindingStatus.open,
                ),
          ),
    );
    final item = inspection.items.firstWhere(
      (it) =>
          it.result == ChecklistResult.fail &&
          inspection.findings.any(
            (f) => f.inspectionItemId == it.id && f.status == FindingStatus.open,
          ),
    );
    final finding = inspection.findings.firstWhere(
      (f) => f.inspectionItemId == item.id && f.status == FindingStatus.open,
    );

    await pumpScreen(
      tester,
      ChecklistScreen(inspectionId: inspection.id),
      overrides: [
        authRepositoryProvider.overrideWithValue(
          SignedInAs(inspection.inspectorId),
        ),
      ],
    );
    await tester.pumpAndSettle();
    // Go to the failed item using the "n / N" counter.
    final ordered = [...inspection.items]
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    final target = ordered.indexWhere((it) => it.id == item.id) + 1;
    int current() => int.parse(
      tester
          .widgetList<Text>(find.byType(Text))
          .map((t) => t.data ?? '')
          .firstWhere((d) => RegExp(r'^\d+ / \d+$').hasMatch(d))
          .split(' / ')
          .first,
    );
    while (current() != target) {
      await tester.tap(find.text(current() < target ? 'Next' : 'Previous'));
      await tester.pumpAndSettle();
    }

    await tester.tap(find.text('Pass'));
    await tester.pumpAndSettle();
    expect(find.text('Close the finding?'), findsOneWidget);

    await tester.tap(find.text('Close finding'));
    await tester.pumpAndSettle();

    final saved = store
        .findInspection(inspection.id)!
        .findings
        .firstWhere((f) => f.id == finding.id);
    expect(saved.status, FindingStatus.resolved);
  });
}
