import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inspectly/app/providers/repository_providers.dart';
import 'package:inspectly/core/utils/result.dart';
import 'package:inspectly/data/datasources/demo/demo_data_store.dart';
import 'package:inspectly/data/models/enums.dart';
import 'package:inspectly/data/models/inspection.dart';
import 'package:inspectly/data/repositories/inspection_repository.dart';
import 'package:inspectly/data/repositories/mock/mock_inspection_repository.dart';
import 'package:inspectly/features/checklist/checklist_screen.dart';

import '../helpers/pump_screen.dart';

/// QC-013: a typed note survives leaving the checklist, also when saving
/// takes a while (API mode) and the screen is gone before it returns.
class _SlowNotes implements InspectionRepository {
  final _real = MockInspectionRepository();

  @override
  Future<Result<Inspection>> getById(String id) => _real.getById(id);

  @override
  Future<Result<Inspection>> updateChecklistItem({
    required String inspectionId,
    required String itemId,
    ChecklistResult? result,
    String? note,
  }) async {
    await Future<void>.delayed(const Duration(seconds: 1));
    return _real.updateChecklistItem(
      inspectionId: inspectionId,
      itemId: itemId,
      result: result,
      note: note,
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  testWidgets('note is saved when the checklist is left mid-save', (
    tester,
  ) async {
    final store = DemoDataStore.instance;
    final inspection = store.inspections.firstWhere(
      (i) => i.status == InspectionStatus.inProgress,
    );

    final router = await pumpScreen(
      tester,
      ChecklistScreen(inspectionId: inspection.id),
      overrides: [inspectionRepositoryProvider.overrideWithValue(_SlowNotes())],
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Door hinge squeaks');
    router.go('/inspections/${inspection.id}');
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 1));

    final notes = store
        .findInspection(inspection.id)!
        .items
        .map((i) => i.note)
        .toList();
    expect(notes, contains('Door hinge squeaks'));
    expect(tester.takeException(), isNull);
  });
}
