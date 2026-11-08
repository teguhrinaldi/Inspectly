// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activity_entry.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ActivityEntry _$ActivityEntryFromJson(Map<String, dynamic> json) =>
    _ActivityEntry(
      id: json['id'] as String,
      inspectionId: json['inspection_id'] as String,
      type: $enumDecode(_$ActivityTypeEnumMap, json['type']),
      description: json['description'] as String? ?? '',
      actorName: json['actor_name'] as String?,
      occurredAt: DateTime.parse(json['occurred_at'] as String),
    );

Map<String, dynamic> _$ActivityEntryToJson(_ActivityEntry instance) =>
    <String, dynamic>{
      'id': instance.id,
      'inspection_id': instance.inspectionId,
      'type': _$ActivityTypeEnumMap[instance.type]!,
      'description': instance.description,
      'actor_name': instance.actorName,
      'occurred_at': instance.occurredAt.toIso8601String(),
    };

const _$ActivityTypeEnumMap = {
  ActivityType.started: 'started',
  ActivityType.checklistUpdated: 'checklist_updated',
  ActivityType.findingAdded: 'finding_added',
  ActivityType.photoAdded: 'photo_added',
  ActivityType.signatureCaptured: 'signature_captured',
  ActivityType.completed: 'completed',
  ActivityType.reportGenerated: 'report_generated',
};
