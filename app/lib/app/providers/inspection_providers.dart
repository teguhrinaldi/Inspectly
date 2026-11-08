import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/activity_entry.dart';
import '../../data/models/inspection.dart';
import '../../data/repositories/inspection_repository.dart';
import 'repository_providers.dart';

final inspectionListProvider =
    FutureProvider.family<List<Inspection>, InspectionListFilter>((
      ref,
      filter,
    ) async {
      final repo = ref.watch(inspectionRepositoryProvider);
      final result = await repo.list(filter);
      return result.when(success: (data) => data, failure: (f) => throw f);
    });

final inspectionByIdProvider = FutureProvider.family<Inspection, String>((
  ref,
  id,
) async {
  final repo = ref.watch(inspectionRepositoryProvider);
  final result = await repo.getById(id);
  return result.when(success: (data) => data, failure: (f) => throw f);
});

/// Activity timeline of one inspection (Notes tab). A provider rather than a
/// FutureBuilder so it isn't refetched on every rebuild and has real
/// loading/error states.
final inspectionActivitiesProvider =
    FutureProvider.family<List<ActivityEntry>, String>((ref, id) async {
      final repo = ref.watch(inspectionRepositoryProvider);
      final result = await repo.activities(id);
      return result.when(success: (data) => data, failure: (f) => throw f);
    });

/// Every screen that mutates an inspection (start/checklist/finding/
/// signature/complete) must invalidate BOTH of these — the detail view reads
/// `inspectionByIdProvider`, but list/dashboard cards read
/// `inspectionListProvider`, and a status/progress change is visible on both.
/// Call this instead of invalidating either provider individually so that
/// pairing can't be forgotten at a call site (a real bug this project once
/// had: completing an inspection updated the detail screen but left
/// dashboard/list cards showing stale status).
extension InvalidateInspectionOnWidgetRef on WidgetRef {
  void invalidateInspection(String id) {
    invalidate(inspectionByIdProvider(id));
    invalidate(inspectionListProvider);
    invalidate(inspectionActivitiesProvider(id));
  }
}
