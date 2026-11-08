// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'evidence.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Evidence _$EvidenceFromJson(Map<String, dynamic> json) => _Evidence(
  id: json['id'] as String,
  inspectionId: json['inspection_id'] as String,
  inspectionItemId: json['inspection_item_id'] as String?,
  findingId: json['finding_id'] as String?,
  filePath: json['file_path'] as String,
  watermarkedPath: json['watermarked_path'] as String?,
  fileUrl: json['file_url'] as String?,
  latitude: (json['latitude'] as num?)?.toDouble(),
  longitude: (json['longitude'] as num?)?.toDouble(),
  accuracy: (json['accuracy'] as num?)?.toDouble(),
  capturedAt: json['captured_at'] == null
      ? null
      : DateTime.parse(json['captured_at'] as String),
);

Map<String, dynamic> _$EvidenceToJson(_Evidence instance) => <String, dynamic>{
  'id': instance.id,
  'inspection_id': instance.inspectionId,
  'inspection_item_id': instance.inspectionItemId,
  'finding_id': instance.findingId,
  'file_path': instance.filePath,
  'watermarked_path': instance.watermarkedPath,
  'file_url': instance.fileUrl,
  'latitude': instance.latitude,
  'longitude': instance.longitude,
  'accuracy': instance.accuracy,
  'captured_at': instance.capturedAt?.toIso8601String(),
};
