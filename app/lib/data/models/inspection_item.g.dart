// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inspection_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_InspectionItem _$InspectionItemFromJson(Map<String, dynamic> json) =>
    _InspectionItem(
      id: json['id'] as String,
      inspectionId: json['inspection_id'] as String,
      templateChecklistItemId:
          json['template_checklist_item_id'] as String? ?? '',
      label: json['label'] as String,
      helpText: json['help_text'] as String?,
      result: $enumDecodeNullable(_$ChecklistResultEnumMap, json['result']),
      note: json['note'] as String?,
      sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
      evidence:
          (json['evidence'] as List<dynamic>?)
              ?.map((e) => Evidence.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <Evidence>[],
    );

Map<String, dynamic> _$InspectionItemToJson(_InspectionItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'inspection_id': instance.inspectionId,
      'template_checklist_item_id': instance.templateChecklistItemId,
      'label': instance.label,
      'help_text': instance.helpText,
      'result': _$ChecklistResultEnumMap[instance.result],
      'note': instance.note,
      'sort_order': instance.sortOrder,
      'evidence': instance.evidence,
    };

const _$ChecklistResultEnumMap = {
  ChecklistResult.pass: 'pass',
  ChecklistResult.fail: 'fail',
  ChecklistResult.na: 'na',
};
