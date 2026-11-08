import 'package:collection/collection.dart';

import '../../../core/errors/failure.dart';
import '../../../core/utils/result.dart';
import '../../datasources/demo/demo_data_store.dart';
import '../../models/site.dart';
import '../../models/site_history.dart';
import '../site_repository.dart';

class MockSiteRepository implements SiteRepository {
  final DemoDataStore _store = DemoDataStore.instance;

  @override
  Future<Result<List<Site>>> list({String? customerId, String? search}) async {
    var items = _store.sites;
    if (customerId != null) {
      items = items.where((s) => s.customerId == customerId).toList();
    }
    if (search != null && search.trim().isNotEmpty) {
      final q = search.toLowerCase();
      items = items.where((s) => s.name.toLowerCase().contains(q)).toList();
    }
    return Success(items);
  }

  @override
  Future<Result<Site>> getById(String id) async {
    final site = _store.sites.firstWhereOrNull((s) => s.id == id);
    if (site == null) return const Failed(NotFoundFailure());
    return Success(site);
  }

  @override
  Future<Result<Site>> findByQrCode(String qrCode) async {
    final site = _store.sites.firstWhereOrNull((s) => s.qrCode == qrCode);
    if (site == null) {
      return const Failed(NotFoundFailure('No site matches this QR code.'));
    }
    return Success(site);
  }

  @override
  Future<Result<List<SiteHistoryEntry>>> history(String siteId) async {
    return Success(_store.historyFor(siteId));
  }

  @override
  Future<Result<SiteComparisonResult?>> comparison(
    String siteId,
    String currentInspectionId,
  ) async {
    return Success(_store.comparisonFor(siteId, currentInspectionId));
  }
}
