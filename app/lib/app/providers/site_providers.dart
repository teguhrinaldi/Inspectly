import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/site.dart';
import '../../data/models/site_history.dart';
import 'repository_providers.dart';

final siteByIdProvider = FutureProvider.family<Site, String>((ref, id) async {
  final repo = ref.watch(siteRepositoryProvider);
  final result = await repo.getById(id);
  return result.when(success: (data) => data, failure: (f) => throw f);
});

final siteHistoryProvider =
    FutureProvider.family<List<SiteHistoryEntry>, String>((ref, siteId) async {
      final repo = ref.watch(siteRepositoryProvider);
      final result = await repo.history(siteId);
      return result.when(success: (data) => data, failure: (f) => throw f);
    });

typedef ComparisonKey = ({String siteId, String inspectionId});

final siteComparisonProvider =
    FutureProvider.family<SiteComparisonResult?, ComparisonKey>((
      ref,
      key,
    ) async {
      final repo = ref.watch(siteRepositoryProvider);
      final result = await repo.comparison(key.siteId, key.inspectionId);
      return result.when(success: (data) => data, failure: (f) => throw f);
    });

final siteListProvider = FutureProvider<List<Site>>((ref) async {
  final repo = ref.watch(siteRepositoryProvider);
  final result = await repo.list();
  return result.when(success: (data) => data, failure: (f) => throw f);
});
