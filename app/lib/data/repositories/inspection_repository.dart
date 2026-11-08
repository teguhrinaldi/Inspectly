import '../../core/utils/result.dart';
import '../models/activity_entry.dart';
import '../models/enums.dart';
import '../models/finding.dart';
import '../models/inspection.dart';

class InspectionListFilter {
  const InspectionListFilter({
    this.status,
    this.search,
    this.siteId,
    this.inspectorId,
  });
  final InspectionStatus? status;
  final String? search;
  final String? siteId;
  final String? inspectorId;

  // Value equality: this is a Riverpod family key, so a fresh-but-equal
  // filter built on every rebuild must resolve to the same provider.
  @override
  bool operator ==(Object other) =>
      other is InspectionListFilter &&
      other.status == status &&
      other.search == search &&
      other.siteId == siteId &&
      other.inspectorId == inspectorId;

  @override
  int get hashCode => Object.hash(status, search, siteId, inspectorId);
}

abstract interface class InspectionRepository {
  Future<Result<List<Inspection>>> list([
    InspectionListFilter filter = const InspectionListFilter(),
  ]);
  Future<Result<Inspection>> getById(String id);

  /// Creates a new DRAFT inspection for [siteId] from [templateId] (the QR
  /// scan → template picker flow, spec §9.11). The checklist is generated
  /// immediately from the template's current sections/items.
  Future<Result<Inspection>> create({
    required String templateId,
    required String siteId,
    required String customerId,
    required String inspectorId,
    required RecurrenceType recurrence,
    DateTime? scheduledAt,
  });

  /// [locationLat]/[locationLng] are the device's current position, captured
  /// by the caller via `LocationService` right before calling this (spec
  /// §9.10) — omitted entirely when the device denies location permission,
  /// never blocking the inspection from starting.
  Future<Result<Inspection>> start(
    String id, {
    double? locationLat,
    double? locationLng,
  });
  Future<Result<Inspection>> updateChecklistItem({
    required String inspectionId,
    required String itemId,
    ChecklistResult? result,
    String? note,
  });
  Future<Result<Inspection>> complete(String id);
  Future<Result<Finding>> addFinding(Finding finding);
  Future<Result<Finding>> updateFinding(Finding finding);
  Future<Result<List<ActivityEntry>>> activities(String inspectionId);
}
