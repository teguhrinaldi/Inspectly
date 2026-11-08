import '../../../core/errors/failure.dart';
import '../../../core/utils/result.dart';
import '../../datasources/demo/demo_data_store.dart';
import '../../models/activity_entry.dart';
import '../../models/enums.dart';
import '../../models/finding.dart';
import '../../models/inspection.dart';
import '../inspection_repository.dart';
import '../../../core/utils/completion_rules.dart';

class MockInspectionRepository implements InspectionRepository {
  final DemoDataStore _store = DemoDataStore.instance;

  @override
  Future<Result<List<Inspection>>> list([
    InspectionListFilter filter = const InspectionListFilter(),
  ]) async {
    await Future.delayed(const Duration(milliseconds: 250));
    var items = _store.inspections;
    if (filter.status != null) {
      items = items.where((i) => i.status == filter.status).toList();
    }
    if (filter.siteId != null) {
      items = items.where((i) => i.siteId == filter.siteId).toList();
    }
    if (filter.inspectorId != null) {
      items = items.where((i) => i.inspectorId == filter.inspectorId).toList();
    }
    if (filter.search != null && filter.search!.trim().isNotEmpty) {
      final q = filter.search!.toLowerCase();
      items = items
          .where(
            (i) =>
                i.siteName.toLowerCase().contains(q) ||
                i.customerName.toLowerCase().contains(q) ||
                i.templateName.toLowerCase().contains(q),
          )
          .toList();
    }
    return Success(items);
  }

  @override
  Future<Result<Inspection>> getById(String id) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final inspection = _store.findInspection(id);
    if (inspection == null) return const Failed(NotFoundFailure());
    return Success(inspection);
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
    // customerId is not needed here — the store derives it from the site
    // itself, which is the single source of truth in Demo Mode. It's part of
    // the interface because the real API requires it explicitly.
    try {
      return Success(
        _store.createFromTemplate(
          templateId: templateId,
          siteId: siteId,
          inspectorUserId: inspectorId,
          recurrence: recurrence,
          scheduledAt: scheduledAt,
        ),
      );
    } catch (_) {
      return const Failed(NotFoundFailure());
    }
  }

  @override
  Future<Result<Inspection>> start(
    String id, {
    double? locationLat,
    double? locationLng,
  }) async {
    final current = _store.findInspection(id);
    if (current == null) return const Failed(NotFoundFailure());
    if (!_store.mayWrite(id)) {
      return const Failed(
        ForbiddenFailure(
          'Only the assigned inspector can change this inspection.',
        ),
      );
    }
    // Same rules as POST /inspections/{id}/start (QC-007).
    if (current.status == InspectionStatus.completed) {
      return const Failed(
        ConflictFailure(
          'This inspection has already been performed and cannot be started again.',
        ),
      );
    }
    if (current.status == InspectionStatus.inProgress) return Success(current);
    try {
      return Success(_store.start(id, lat: locationLat, lng: locationLng));
    } catch (_) {
      return const Failed(NotFoundFailure());
    }
  }

  @override
  Future<Result<Inspection>> updateChecklistItem({
    required String inspectionId,
    required String itemId,
    ChecklistResult? result,
    String? note,
  }) async {
    if (!_store.mayWrite(inspectionId)) {
      return const Failed(
        ForbiddenFailure(
          'Only the assigned inspector can change this inspection.',
        ),
      );
    }
    try {
      return Success(
        _store.updateChecklistItem(
          inspectionId: inspectionId,
          itemId: itemId,
          result: result,
          note: note,
        ),
      );
    } catch (_) {
      return const Failed(NotFoundFailure());
    }
  }

  @override
  Future<Result<Inspection>> complete(String id) async {
    final current = _store.findInspection(id);
    if (current == null) return const Failed(NotFoundFailure());
    if (!_store.mayWrite(id)) {
      return const Failed(
        ForbiddenFailure(
          'Only the assigned inspector can change this inspection.',
        ),
      );
    }
    // Same rules as POST /inspections/{id}/complete (QC-007).
    if (current.status == InspectionStatus.completed) return Success(current);
    if (current.status != InspectionStatus.inProgress) {
      return const Failed(
        ConflictFailure(
          'Only an inspection in progress can be completed. Start it first.',
        ),
      );
    }
    final missing = itemsMissingEvidence(
      current,
      _store.templates.where((t) => t.id == current.templateId).firstOrNull,
    );
    if (missing.isNotEmpty) {
      final message =
          'These items need at least one photo: ${missing.join(', ')}.';
      return Failed(
        ValidationFailure({
          'items': [message],
        }, message),
      );
    }
    if (current.items.any((item) => item.result == null)) {
      return const Failed(
        ValidationFailure(
          {
            'items': [
              'Every checklist item needs a result before the inspection can be completed.',
            ],
          },
          'Every checklist item needs a result before the inspection can be completed.',
        ),
      );
    }
    try {
      return Success(_store.complete(id));
    } catch (_) {
      return const Failed(NotFoundFailure());
    }
  }

  @override
  Future<Result<Finding>> addFinding(Finding finding) async {
    if (!_store.mayWrite(finding.inspectionId)) {
      return const Failed(
        ForbiddenFailure(
          'Only the assigned inspector can change this inspection.',
        ),
      );
    }
    try {
      final updated = _store.addFinding(finding);
      final saved = updated.findings.firstWhere((f) => f.id == finding.id);
      return Success(saved);
    } catch (_) {
      return const Failed(NotFoundFailure());
    }
  }

  @override
  Future<Result<Finding>> updateFinding(Finding finding) async {
    if (!_store.mayWrite(finding.inspectionId)) {
      return const Failed(
        ForbiddenFailure(
          'Only the assigned inspector can change this inspection.',
        ),
      );
    }
    try {
      final updated = _store.updateFinding(finding);
      final saved = updated.findings.firstWhere((f) => f.id == finding.id);
      return Success(saved);
    } catch (_) {
      return const Failed(NotFoundFailure());
    }
  }

  @override
  Future<Result<List<ActivityEntry>>> activities(String inspectionId) async {
    return Success(_store.activitiesFor(inspectionId));
  }
}
