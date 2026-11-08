import 'package:freezed_annotation/freezed_annotation.dart';

import 'enums.dart';
import 'finding.dart';
import 'inspection_item.dart';
import 'signature.dart';

part 'inspection.freezed.dart';
part 'inspection.g.dart';

@freezed
abstract class Inspection with _$Inspection {
  const factory Inspection({
    required String id,
    required String templateId,
    required String templateName,
    required String customerId,
    required String customerName,
    required String siteId,
    required String siteName,
    String? siteAddress,
    String? siteCoverImageUrl,
    required String inspectorId,
    required String inspectorName,
    String? inspectorAvatarUrl,
    required InspectionStatus status,
    DateTime? scheduledAt,
    DateTime? startedAt,
    DateTime? completedAt,
    @Default(RecurrenceType.oneTime) RecurrenceType recurrence,
    DateTime? nextDueAt,
    double? locationLat,
    double? locationLng,
    DateTime? locationCapturedAt,
    double? passPercentage,
    @Default(<InspectionItem>[]) List<InspectionItem> items,
    @Default(<Finding>[]) List<Finding> findings,
    @Default(<InspectionSignature>[]) List<InspectionSignature> signatures,
    // Flutter-only: never serialized to/from the API.
    @JsonKey(includeFromJson: false, includeToJson: false)
    @Default(SyncState.synced)
    SyncState syncState,
  }) = _Inspection;

  const Inspection._();

  factory Inspection.fromJson(Map<String, dynamic> json) =>
      _$InspectionFromJson(json);

  /// Number of checklist items that already have a result recorded.
  int get completedItemCount => items.where((i) => i.result != null).length;

  /// Total checklist item count (denominator for progress display, e.g. "7 / 12").
  int get totalItemCount => items.length;

  int get passCount =>
      items.where((i) => i.result == ChecklistResult.pass).length;
  int get failCount =>
      items.where((i) => i.result == ChecklistResult.fail).length;
  int get naCount => items.where((i) => i.result == ChecklistResult.na).length;

  /// Deterministic risk summary, computed from actual recorded results —
  /// never estimated or AI-derived. Percentage excludes N/A items from the
  /// denominator since they represent items that don't apply to this site.
  double get computedPassPercentage {
    final scored = passCount + failCount;
    if (scored == 0) return 0;
    return (passCount / scored) * 100;
  }
}
