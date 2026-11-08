import 'package:freezed_annotation/freezed_annotation.dart';

import 'enums.dart';

part 'site_history.freezed.dart';
part 'site_history.g.dart';

/// One row in a Site's inspection history list (§9.18).
@freezed
abstract class SiteHistoryEntry with _$SiteHistoryEntry {
  const factory SiteHistoryEntry({
    required String inspectionId,
    required String templateName,
    required InspectionStatus status,
    DateTime? completedAt,
    double? passPercentage,
  }) = _SiteHistoryEntry;

  factory SiteHistoryEntry.fromJson(Map<String, dynamic> json) =>
      _$SiteHistoryEntryFromJson(json);
}

/// One matched finding pair in a previous-vs-current comparison (§9.17, §29).
@freezed
abstract class ComparisonEntry with _$ComparisonEntry {
  const factory ComparisonEntry({
    required String templateChecklistItemId,
    required String label,
    required ComparisonState state,
    String? previousFindingId,
    String? previousDescription,
    DateTime? previousDate,
    String? currentFindingId,
    String? currentDescription,
    DateTime? currentDate,
  }) = _ComparisonEntry;

  factory ComparisonEntry.fromJson(Map<String, dynamic> json) =>
      _$ComparisonEntryFromJson(json);
}

@freezed
abstract class SiteComparisonResult with _$SiteComparisonResult {
  const factory SiteComparisonResult({
    required String siteId,
    required String previousInspectionId,
    required DateTime previousDate,
    required String currentInspectionId,
    required DateTime currentDate,
    @Default(<ComparisonEntry>[]) List<ComparisonEntry> entries,
  }) = _SiteComparisonResult;

  factory SiteComparisonResult.fromJson(Map<String, dynamic> json) =>
      _$SiteComparisonResultFromJson(json);
}
