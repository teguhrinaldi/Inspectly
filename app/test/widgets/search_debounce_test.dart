import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inspectly/app/providers/repository_providers.dart';
import 'package:inspectly/core/utils/result.dart';
import 'package:inspectly/data/models/inspection.dart';
import 'package:inspectly/data/repositories/inspection_repository.dart';
import 'package:inspectly/data/repositories/mock/mock_inspection_repository.dart';
import 'package:inspectly/features/inspections/inspection_list_screen.dart';

import '../helpers/pump_screen.dart';

/// QC-041: typing a search term sends one request (not one per letter)
/// and the list doesn't flash back to a spinner on every keystroke.
class _Counting implements InspectionRepository {
  final _real = MockInspectionRepository();
  final searches = <String?>[];

  @override
  Future<Result<List<Inspection>>> list([
    InspectionListFilter filter = const InspectionListFilter(),
  ]) async {
    searches.add(filter.search);
    await Future<void>.delayed(const Duration(milliseconds: 100));
    return _real.list(filter);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  testWidgets('typing searches once and keeps the list visible', (
    tester,
  ) async {
    final repo = _Counting();
    await pumpScreen(
      tester,
      const InspectionListScreen(),
      overrides: [inspectionRepositoryProvider.overrideWithValue(repo)],
    );
    await tester.pumpAndSettle();
    repo.searches.clear();

    var spinnerSeen = false;
    const term = 'warehouse';
    for (var i = 1; i <= term.length; i++) {
      await tester.enterText(find.byType(TextField), term.substring(0, i));
      await tester.pump(const Duration(milliseconds: 60));
      spinnerSeen |= find
          .byType(CircularProgressIndicator)
          .evaluate()
          .isNotEmpty;
    }
    await tester.pump(const Duration(milliseconds: 400)); // debounce
    await tester.pump(const Duration(milliseconds: 200)); // request
    await tester.pumpAndSettle();

    expect(repo.searches, ['warehouse']);
    expect(spinnerSeen, isFalse);
    await tester.pump(const Duration(seconds: 1));
  });
}
