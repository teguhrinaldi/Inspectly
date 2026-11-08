// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'signature.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_InspectionSignature _$InspectionSignatureFromJson(Map<String, dynamic> json) =>
    _InspectionSignature(
      id: json['id'] as String,
      inspectionId: json['inspection_id'] as String,
      type: $enumDecode(_$SignatureTypeEnumMap, json['type']),
      signerName: json['signer_name'] as String,
      filePath: json['file_path'] as String,
      fileUrl: json['file_url'] as String?,
      signedAt: DateTime.parse(json['signed_at'] as String),
    );

Map<String, dynamic> _$InspectionSignatureToJson(
  _InspectionSignature instance,
) => <String, dynamic>{
  'id': instance.id,
  'inspection_id': instance.inspectionId,
  'type': _$SignatureTypeEnumMap[instance.type]!,
  'signer_name': instance.signerName,
  'file_path': instance.filePath,
  'file_url': instance.fileUrl,
  'signed_at': instance.signedAt.toIso8601String(),
};

const _$SignatureTypeEnumMap = {
  SignatureType.inspector: 'inspector',
  SignatureType.customer: 'customer',
};
