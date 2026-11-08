// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'site_history.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SiteHistoryEntry _$SiteHistoryEntryFromJson(Map<String, dynamic> json) =>
    _SiteHistoryEntry(
      inspectionId: json['inspection_id'] as String,
      templateName: json['template_name'] as String,
      status: $enumDecode(_$InspectionStatusEnumMap, json['status']),
      completedAt: json['completed_at'] == null
          ? null
          : DateTime.parse(json['completed_at'] as String),
      passPercentage: (json['pass_percentage'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$SiteHistoryEntryToJson(_SiteHistoryEntry instance) =>
    <String, dynamic>{
      'inspection_id': instance.inspectionId,
      'template_name': instance.templateName,
      'status': _$InspectionStatusEnumMap[instance.status]!,
      'completed_at': instance.completedAt?.toIso8601String(),
      'pass_percentage': instance.passPercentage,
    };

const _$InspectionStatusEnumMap = {
  InspectionStatus.draft: 'draft',
  InspectionStatus.scheduled: 'scheduled',
  InspectionStatus.inProgress: 'in_progress',
  InspectionStatus.review: 'review',
  InspectionStatus.completed: 'completed',
};

_ComparisonEntry _$ComparisonEntryFromJson(Map<String, dynamic> json) =>
    _ComparisonEntry(
      templateChecklistItemId: json['template_checklist_item_id'] as String,
      label: json['label'] as String,
      state: $enumDecode(_$ComparisonStateEnumMap, json['state']),
      previousFindingId: json['previous_finding_id'] as String?,
      previousDescription: json['previous_description'] as String?,
      previousDate: json['previous_date'] == null
          ? null
          : DateTime.parse(json['previous_date'] as String),
      currentFindingId: json['current_finding_id'] as String?,
      currentDescription: json['current_description'] as String?,
      currentDate: json['current_date'] == null
          ? null
          : DateTime.parse(json['current_date'] as String),
    );

Map<String, dynamic> _$ComparisonEntryToJson(_ComparisonEntry instance) =>
    <String, dynamic>{
      'template_checklist_item_id': instance.templateChecklistItemId,
      'label': instance.label,
      'state': _$ComparisonStateEnumMap[instance.state]!,
      'previous_finding_id': instance.previousFindingId,
      'previous_description': instance.previousDescription,
      'previous_date': instance.previousDate?.toIso8601String(),
      'current_finding_id': instance.currentFindingId,
      'current_description': instance.currentDescription,
      'current_date': instance.currentDate?.toIso8601String(),
    };

const _$ComparisonStateEnumMap = {
  ComparisonState.newFinding: 'newFinding',
  ComparisonState.stillOpen: 'stillOpen',
  ComparisonState.resolved: 'resolved',
};

_SiteComparisonResult _$SiteComparisonResultFromJson(
  Map<String, dynamic> json,
) => _SiteComparisonResult(
  siteId: json['site_id'] as String,
  previousInspectionId: json['previous_inspection_id'] as String,
  previousDate: DateTime.parse(json['previous_date'] as String),
  currentInspectionId: json['current_inspection_id'] as String,
  currentDate: DateTime.parse(json['current_date'] as String),
  entries:
      (json['entries'] as List<dynamic>?)
          ?.map((e) => ComparisonEntry.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <ComparisonEntry>[],
);

Map<String, dynamic> _$SiteComparisonResultToJson(
  _SiteComparisonResult instance,
) => <String, dynamic>{
  'site_id': instance.siteId,
  'previous_inspection_id': instance.previousInspectionId,
  'previous_date': instance.previousDate.toIso8601String(),
  'current_inspection_id': instance.currentInspectionId,
  'current_date': instance.currentDate.toIso8601String(),
  'entries': instance.entries,
};
