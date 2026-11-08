// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inspection.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Inspection _$InspectionFromJson(Map<String, dynamic> json) => _Inspection(
  id: json['id'] as String,
  templateId: json['template_id'] as String,
  templateName: json['template_name'] as String,
  customerId: json['customer_id'] as String,
  customerName: json['customer_name'] as String,
  siteId: json['site_id'] as String,
  siteName: json['site_name'] as String,
  siteAddress: json['site_address'] as String?,
  siteCoverImageUrl: json['site_cover_image_url'] as String?,
  inspectorId: json['inspector_id'] as String,
  inspectorName: json['inspector_name'] as String,
  inspectorAvatarUrl: json['inspector_avatar_url'] as String?,
  status: $enumDecode(_$InspectionStatusEnumMap, json['status']),
  scheduledAt: json['scheduled_at'] == null
      ? null
      : DateTime.parse(json['scheduled_at'] as String),
  startedAt: json['started_at'] == null
      ? null
      : DateTime.parse(json['started_at'] as String),
  completedAt: json['completed_at'] == null
      ? null
      : DateTime.parse(json['completed_at'] as String),
  recurrence:
      $enumDecodeNullable(_$RecurrenceTypeEnumMap, json['recurrence']) ??
      RecurrenceType.oneTime,
  nextDueAt: json['next_due_at'] == null
      ? null
      : DateTime.parse(json['next_due_at'] as String),
  locationLat: (json['location_lat'] as num?)?.toDouble(),
  locationLng: (json['location_lng'] as num?)?.toDouble(),
  locationCapturedAt: json['location_captured_at'] == null
      ? null
      : DateTime.parse(json['location_captured_at'] as String),
  passPercentage: (json['pass_percentage'] as num?)?.toDouble(),
  items:
      (json['items'] as List<dynamic>?)
          ?.map((e) => InspectionItem.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <InspectionItem>[],
  findings:
      (json['findings'] as List<dynamic>?)
          ?.map((e) => Finding.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <Finding>[],
  signatures:
      (json['signatures'] as List<dynamic>?)
          ?.map((e) => InspectionSignature.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <InspectionSignature>[],
);

Map<String, dynamic> _$InspectionToJson(_Inspection instance) =>
    <String, dynamic>{
      'id': instance.id,
      'template_id': instance.templateId,
      'template_name': instance.templateName,
      'customer_id': instance.customerId,
      'customer_name': instance.customerName,
      'site_id': instance.siteId,
      'site_name': instance.siteName,
      'site_address': instance.siteAddress,
      'site_cover_image_url': instance.siteCoverImageUrl,
      'inspector_id': instance.inspectorId,
      'inspector_name': instance.inspectorName,
      'inspector_avatar_url': instance.inspectorAvatarUrl,
      'status': _$InspectionStatusEnumMap[instance.status]!,
      'scheduled_at': instance.scheduledAt?.toIso8601String(),
      'started_at': instance.startedAt?.toIso8601String(),
      'completed_at': instance.completedAt?.toIso8601String(),
      'recurrence': _$RecurrenceTypeEnumMap[instance.recurrence]!,
      'next_due_at': instance.nextDueAt?.toIso8601String(),
      'location_lat': instance.locationLat,
      'location_lng': instance.locationLng,
      'location_captured_at': instance.locationCapturedAt?.toIso8601String(),
      'pass_percentage': instance.passPercentage,
      'items': instance.items,
      'findings': instance.findings,
      'signatures': instance.signatures,
    };

const _$InspectionStatusEnumMap = {
  InspectionStatus.draft: 'draft',
  InspectionStatus.scheduled: 'scheduled',
  InspectionStatus.inProgress: 'in_progress',
  InspectionStatus.review: 'review',
  InspectionStatus.completed: 'completed',
};

const _$RecurrenceTypeEnumMap = {
  RecurrenceType.oneTime: 'one_time',
  RecurrenceType.weekly: 'weekly',
  RecurrenceType.monthly: 'monthly',
  RecurrenceType.quarterly: 'quarterly',
};
