import 'package:collection/collection.dart';

import '../../../core/errors/failure.dart';
import '../../../core/utils/result.dart';
import '../../datasources/demo/demo_data_store.dart';
import '../../models/inspector.dart';
import '../inspector_repository.dart';

class MockInspectorRepository implements InspectorRepository {
  final DemoDataStore _store = DemoDataStore.instance;

  @override
  Future<Result<List<Inspector>>> list({String? search}) async {
    var items = _store.inspectors;
    if (search != null && search.trim().isNotEmpty) {
      final q = search.toLowerCase();
      items = items.where((i) => i.name.toLowerCase().contains(q)).toList();
    }
    return Success(items);
  }

  @override
  Future<Result<Inspector>> getById(String id) async {
    final inspector = _store.inspectors.firstWhereOrNull((i) => i.id == id);
    if (inspector == null) return const Failed(NotFoundFailure());
    return Success(inspector);
  }
}
