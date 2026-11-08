import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/inspection_template.dart';
import 'repository_providers.dart';

final templateByIdProvider = FutureProvider.family<InspectionTemplate, String>((
  ref,
  id,
) async {
  final repo = ref.watch(templateRepositoryProvider);
  final result = await repo.getById(id);
  return result.when(success: (data) => data, failure: (f) => throw f);
});

final templateListProvider = FutureProvider<List<InspectionTemplate>>((
  ref,
) async {
  final repo = ref.watch(templateRepositoryProvider);
  final result = await repo.list(activeOnly: true);
  return result.when(success: (data) => data, failure: (f) => throw f);
});
