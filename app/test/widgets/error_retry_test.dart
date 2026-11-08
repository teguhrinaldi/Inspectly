import 'package:flutter_test/flutter_test.dart';
import 'package:inspectly/app/providers/repository_providers.dart';
import 'package:inspectly/core/errors/failure.dart';
import 'package:inspectly/core/utils/result.dart';
import 'package:inspectly/data/models/inspection.dart';
import 'package:inspectly/data/repositories/inspection_repository.dart';
import 'package:inspectly/data/repositories/mock/mock_inspection_repository.dart';
import 'package:inspectly/features/inspections/inspection_list_screen.dart';
import 'package:inspectly/features/reports/reports_screen.dart';

import '../helpers/pump_screen.dart';

/// QC-011: every data screen offers a way out of its error state.
class _FlakyRepo implements InspectionRepository {
  bool failing = true;
  final _real = MockInspectionRepository();

  @override
  Future<Result<List<Inspection>>> list([
    InspectionListFilter filter = const InspectionListFilter(),
  ]) async => failing ? const Failed(NetworkFailure()) : _real.list(filter);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  for (final entry in {
    'Inspections': const InspectionListScreen(),
    'Reports': const ReportsScreen(),
  }.entries) {
    testWidgets('${entry.key}: error state has a working Try again', (
      tester,
    ) async {
      final repo = _FlakyRepo();
      await pumpScreen(
        tester,
        entry.value,
        overrides: [inspectionRepositoryProvider.overrideWithValue(repo)],
      );
      await tester.pumpAndSettle();
      expect(find.text(const NetworkFailure().message), findsOneWidget);

      repo.failing = false;
      await tester.tap(find.text('Try again'));
      await tester.pumpAndSettle();

      expect(find.text(const NetworkFailure().message), findsNothing);
    });
  }
}
