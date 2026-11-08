// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'finding.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Finding _$FindingFromJson(Map<String, dynamic> json) => _Finding(
  id: json['id'] as String,
  inspectionId: json['inspection_id'] as String,
  inspectionItemId: json['inspection_item_id'] as String?,
  title: json['title'] as String,
  description: json['description'] as String? ?? '',
  severity: $enumDecode(_$FindingSeverityEnumMap, json['severity']),
  recommendation: json['recommendation'] as String?,
  location: json['location'] as String?,
  status:
      $enumDecodeNullable(_$FindingStatusEnumMap, json['status']) ??
      FindingStatus.open,
  evidence:
      (json['evidence'] as List<dynamic>?)
          ?.map((e) => Evidence.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <Evidence>[],
);

Map<String, dynamic> _$FindingToJson(_Finding instance) => <String, dynamic>{
  'id': instance.id,
  'inspection_id': instance.inspectionId,
  'inspection_item_id': instance.inspectionItemId,
  'title': instance.title,
  'description': instance.description,
  'severity': _$FindingSeverityEnumMap[instance.severity]!,
  'recommendation': instance.recommendation,
  'location': instance.location,
  'status': _$FindingStatusEnumMap[instance.status]!,
  'evidence': instance.evidence,
};

const _$FindingSeverityEnumMap = {
  FindingSeverity.critical: 'critical',
  FindingSeverity.high: 'high',
  FindingSeverity.medium: 'medium',
  FindingSeverity.low: 'low',
};

const _$FindingStatusEnumMap = {
  FindingStatus.open: 'open',
  FindingStatus.resolved: 'resolved',
};
