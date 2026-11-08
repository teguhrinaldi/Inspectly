import '../../core/utils/result.dart';
import '../models/site.dart';
import '../models/site_history.dart';

abstract interface class SiteRepository {
  Future<Result<List<Site>>> list({String? customerId, String? search});
  Future<Result<Site>> getById(String id);
  Future<Result<Site>> findByQrCode(String qrCode);
  Future<Result<List<SiteHistoryEntry>>> history(String siteId);
  Future<Result<SiteComparisonResult?>> comparison(
    String siteId,
    String currentInspectionId,
  );
}
