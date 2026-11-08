import '../../../core/errors/failure.dart';
import '../../../core/network/api_client.dart';
import '../../../core/utils/enum_codecs.dart';
import '../../../core/utils/result.dart';
import '../../models/activity_entry.dart';
import '../../models/enums.dart';
import '../../models/finding.dart';
import '../../models/inspection.dart';
import '../inspection_repository.dart';

class ApiInspectionRepository implements InspectionRepository {
  ApiInspectionRepository({ApiClient? client})
    : _client = client ?? ApiClient();

  final ApiClient _client;

  @override
  Future<Result<List<Inspection>>> list([
    InspectionListFilter filter = const InspectionListFilter(),
  ]) async {
    try {
      final items = await _client.guard(() async {
        final data = await _client.getAllPages(
          '/inspections',
          queryParameters: {
            if (filter.status != null)
              'status': inspectionStatusToJson(filter.status!),
            if (filter.search != null) 'search': filter.search,
            if (filter.siteId != null) 'site_id': filter.siteId,
            if (filter.inspectorId != null) 'inspector_id': filter.inspectorId,
          },
        );
        return data
            .map((e) => Inspection.fromJson(e as Map<String, dynamic>))
            .toList();
      });
      return Success(items);
    } on Failure catch (f) {
      return Failed(f);
    }
  }

  @override
  Future<Result<Inspection>> getById(String id) async {
    try {
      final inspection = await _client.guard(() async {
        final response = await _client.dio.get('/inspections/$id');
        return Inspection.fromJson(_client.unwrap(response));
      });
      return Success(inspection);
    } on Failure catch (f) {
      return Failed(f);
    }
  }

  @override
  Future<Result<Inspection>> create({
    required String templateId,
    required String siteId,
    required String customerId,
    required String inspectorId,
    required RecurrenceType recurrence,
    DateTime? scheduledAt,
  }) async {
    try {
      final inspection = await _client.guard(() async {
        final response = await _client.dio.post(
          '/inspections',
          data: {
            'template_id': templateId,
            'site_id': siteId,
            'customer_id': customerId,
            'inspector_id': inspectorId,
            'recurrence': recurrenceTypeToJson(recurrence),
            'status': inspectionStatusToJson(
              scheduledAt == null
                  ? InspectionStatus.draft
                  : InspectionStatus.scheduled,
            ),
            if (scheduledAt != null)
              'scheduled_at': scheduledAt.toUtc().toIso8601String(),
          },
        );
        return Inspection.fromJson(_client.unwrap(response));
      });
      return Success(inspection);
    } on Failure catch (f) {
      return Failed(f);
    }
  }

  @override
  Future<Result<Inspection>> start(
    String id, {
    double? locationLat,
    double? locationLng,
  }) async {
    try {
      final inspection = await _client.guard(() async {
        final response = await _client.dio.post(
          '/inspections/$id/start',
          data: {'location_lat': ?locationLat, 'location_lng': ?locationLng},
        );
        return Inspection.fromJson(_client.unwrap(response));
      });
      return Success(inspection);
    } on Failure catch (f) {
      return Failed(f);
    }
  }

  @override
  Future<Result<Inspection>> updateChecklistItem({
    required String inspectionId,
    required String itemId,
    ChecklistResult? result,
    String? note,
  }) async {
    // This endpoint returns only the updated InspectionItem, not the whole
    // Inspection (unlike start/complete) — refetch for a consistent return
    // value matching the interface. No current UI call site actually reads
    // the returned Inspection (it always invalidates + refetches anyway),
    // but the interface promises a consistent, up-to-date Inspection back.
    try {
      await _client.guard(
        () => _client.dio.put(
          '/inspections/$inspectionId/items/$itemId',
          data: {
            if (result != null) 'result': checklistResultToJson(result),
            'note': ?note,
          },
        ),
      );
      return await getById(inspectionId);
    } on Failure catch (f) {
      return Failed(f);
    }
  }

  @override
  Future<Result<Inspection>> complete(String id) async {
    try {
      final inspection = await _client.guard(() async {
        final response = await _client.dio.post('/inspections/$id/complete');
        return Inspection.fromJson(_client.unwrap(response));
      });
      return Success(inspection);
    } on Failure catch (f) {
      return Failed(f);
    }
  }

  @override
  Future<Result<Finding>> addFinding(Finding finding) async {
    try {
      final saved = await _client.guard(() async {
        final response = await _client.dio.post(
          '/findings',
          data: finding.toJson(),
        );
        return Finding.fromJson(_client.unwrap(response));
      });
      return Success(saved);
    } on Failure catch (f) {
      return Failed(f);
    }
  }

  @override
  Future<Result<Finding>> updateFinding(Finding finding) async {
    try {
      final saved = await _client.guard(() async {
        final response = await _client.dio.put(
          '/findings/${finding.id}',
          data: finding.toJson(),
        );
        return Finding.fromJson(_client.unwrap(response));
      });
      return Success(saved);
    } on Failure catch (f) {
      return Failed(f);
    }
  }

  @override
  Future<Result<List<ActivityEntry>>> activities(String inspectionId) async {
    try {
      final items = await _client.guard(() async {
        final data = await _client.getAllPages(
          '/activities',
          queryParameters: {'inspection_id': inspectionId},
        );
        return data
            .map((e) => ActivityEntry.fromJson(e as Map<String, dynamic>))
            .toList();
      });
      return Success(items);
    } on Failure catch (f) {
      return Failed(f);
    }
  }
}
