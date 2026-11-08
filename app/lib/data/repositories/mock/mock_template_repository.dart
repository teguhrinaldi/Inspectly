import 'package:collection/collection.dart';

import '../../../core/errors/failure.dart';
import '../../../core/utils/result.dart';
import '../../datasources/demo/demo_data_store.dart';
import '../../models/inspection_template.dart';
import '../template_repository.dart';

class MockTemplateRepository implements TemplateRepository {
  final DemoDataStore _store = DemoDataStore.instance;
  final List<InspectionTemplate> _templates = [];

  List<InspectionTemplate> get _all {
    if (_templates.isEmpty) _templates.addAll(_store.templates);
    return _templates;
  }

  @override
  Future<Result<List<InspectionTemplate>>> list({
    bool activeOnly = false,
  }) async {
    final items = activeOnly ? _all.where((t) => t.isActive).toList() : _all;
    return Success(items);
  }

  @override
  Future<Result<InspectionTemplate>> getById(String id) async {
    final template = _all.firstWhereOrNull((t) => t.id == id);
    if (template == null) return const Failed(NotFoundFailure());
    return Success(template);
  }

  @override
  Future<Result<InspectionTemplate>> create(InspectionTemplate template) async {
    _all.add(template);
    return Success(template);
  }

  @override
  Future<Result<InspectionTemplate>> update(InspectionTemplate template) async {
    final index = _all.indexWhere((t) => t.id == template.id);
    if (index == -1) return const Failed(NotFoundFailure());
    _all[index] = template;
    return Success(template);
  }

  @override
  Future<Result<void>> delete(String id) async {
    _all.removeWhere((t) => t.id == id);
    return const Success(null);
  }
}
