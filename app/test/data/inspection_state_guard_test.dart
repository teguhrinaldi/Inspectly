import 'package:flutter_test/flutter_test.dart';
import 'package:inspectly/core/errors/failure.dart';
import 'package:inspectly/data/datasources/demo/demo_data_store.dart';
import 'package:inspectly/data/models/enums.dart';
import 'package:inspectly/data/repositories/mock/mock_inspection_repository.dart';

/// QC-007: Demo Mode follows the same start/complete rules as the API
/// (409 when re-starting a performed inspection, 422 when completing with
/// unanswered items, completing twice is a no-op).
void main() {
  final store = DemoDataStore.instance;
  final repo = MockInspectionRepository();

  test('a completed inspection cannot be started again', () async {
    final done = store.inspections.firstWhere(
      (i) => i.status == InspectionStatus.completed,
    );

    final result = await repo.start(done.id);

    result.when(
      success: (_) => fail('expected a conflict'),
      failure: (f) => expect(f, isA<ConflictFailure>()),
    );
    expect(store.findInspection(done.id)!.status, InspectionStatus.completed);
  });

  test('completing with unanswered items is rejected', () async {
    final open = store.inspections.firstWhere(
      (i) =>
          i.status == InspectionStatus.inProgress &&
          i.items.any((item) => item.result == null),
    );

    final result = await repo.complete(open.id);

    result.when(
      success: (_) => fail('expected a validation failure'),
      failure: (f) => expect(f, isA<ValidationFailure>()),
    );
    expect(store.findInspection(open.id)!.status, InspectionStatus.inProgress);
  });

  test('completing twice keeps the first completion', () async {
    final done = store.inspections.firstWhere(
      (i) => i.status == InspectionStatus.completed && i.completedAt != null,
    );

    final result = await repo.complete(done.id);

    expect(result.dataOrNull?.completedAt, done.completedAt);
  });
}
