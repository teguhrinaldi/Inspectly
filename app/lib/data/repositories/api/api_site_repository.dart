import '../../../core/errors/failure.dart';
import '../../../core/network/api_client.dart';
import '../../../core/utils/result.dart';
import '../../models/enums.dart';
import '../../models/inspection.dart';
import '../../models/site.dart';
import '../../models/site_history.dart';
import '../site_repository.dart';

class ApiSiteRepository implements SiteRepository {
  ApiSiteRepository({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  @override
  Future<Result<List<Site>>> list({String? customerId, String? search}) async {
    try {
      final items = await _client.guard(() async {
        final response = await _client.dio.get(
          '/sites',
          queryParameters: {'customer_id': ?customerId, 'search': ?search},
        );
        final data = response.data['data'] as List<dynamic>;
        return data
            .map((e) => Site.fromJson(e as Map<String, dynamic>))
            .toList();
      });
      return Success(items);
    } on Failure catch (f) {
      return Failed(f);
    }
  }

  @override
  Future<Result<Site>> getById(String id) async {
    try {
      final site = await _client.guard(() async {
        final response = await _client.dio.get('/sites/$id');
        return Site.fromJson(_client.unwrap(response));
      });
      return Success(site);
    } on Failure catch (f) {
      return Failed(f);
    }
  }

  @override
  Future<Result<Site>> findByQrCode(String qrCode) async {
    try {
      final items = await list();
      final matches = items.dataOrNull?.where((s) => s.qrCode == qrCode);
      if (matches == null || matches.isEmpty) {
        return const Failed(NotFoundFailure('No site matches this QR code.'));
      }
      return Success(matches.first);
    } on Failure catch (f) {
      return Failed(f);
    }
  }

  @override
  Future<Result<List<SiteHistoryEntry>>> history(String siteId) async {
    // The endpoint returns full (paginated) InspectionResource objects rather
    // than a bespoke shape — reuse Inspection.fromJson for robust parsing and
    // project down to the compact SiteHistoryEntry the UI actually needs.
    try {
      final items = await _client.guard(() async {
        final response = await _client.dio.get('/sites/$siteId/history');
        final data = response.data['data'] as List<dynamic>;
        return data.map((e) {
          final inspection = Inspection.fromJson(e as Map<String, dynamic>);
          return SiteHistoryEntry(
            inspectionId: inspection.id,
            templateName: inspection.templateName,
            status: inspection.status,
            completedAt: inspection.completedAt,
            passPercentage: inspection.passPercentage,
          );
        }).toList();
      });
      return Success(items);
    } on Failure catch (f) {
      return Failed(f);
    }
  }

  @override
  Future<Result<SiteComparisonResult?>> comparison(
    String siteId,
    String currentInspectionId,
  ) async {
    // The endpoint's shape (classification + nested finding/previous_finding
    // resources) doesn't match SiteComparisonResult one-to-one — translate it
    // here rather than expecting a generated fromJson to line up.
    try {
      final result = await _client.guard(() async {
        final response = await _client.dio.get(
          '/sites/$siteId/comparison',
          queryParameters: {'inspection_id': currentInspectionId},
        );
        final data = response.data as Map<String, dynamic>;
        if (data['has_previous'] != true) return null;

        final entries = (data['comparison'] as List<dynamic>).map((raw) {
          final row = raw as Map<String, dynamic>;
          final finding = row['finding'] as Map<String, dynamic>?;
          final previousFinding =
              row['previous_finding'] as Map<String, dynamic>?;
          final state = switch (row['classification']) {
            'STILL_OPEN' => ComparisonState.stillOpen,
            'NEW' => ComparisonState.newFinding,
            'RESOLVED' => ComparisonState.resolved,
            _ => ComparisonState.newFinding,
          };
          return ComparisonEntry(
            // Not returned directly by this endpoint; the finding/item id is
            // a stable-enough key for the UI's purposes (grouping, not display).
            templateChecklistItemId:
                (finding?['inspection_item_id'] ??
                        previousFinding?['inspection_item_id'] ??
                        finding?['id'] ??
                        previousFinding?['id'])
                    .toString(),
            label: (finding?['title'] ?? previousFinding?['title']) as String,
            state: state,
            previousFindingId: previousFinding?['id']?.toString(),
            previousDescription: previousFinding?['description'] as String?,
            currentFindingId: finding?['id']?.toString(),
            currentDescription: finding?['description'] as String?,
          );
        }).toList();

        return SiteComparisonResult(
          siteId: siteId,
          previousInspectionId: data['previous_inspection_id'].toString(),
          previousDate: DateTime.parse(data['previous_completed_at'] as String),
          currentInspectionId: currentInspectionId,
          // Not returned by this endpoint — the current inspection's own
          // completedAt is already known to the caller from the Inspection
          // it's viewing, so this is only a display fallback.
          currentDate: DateTime.now(),
          entries: entries,
        );
      });
      return Success(result);
    } on Failure catch (f) {
      return Failed(f);
    }
  }
}
