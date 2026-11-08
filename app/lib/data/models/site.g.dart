// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'site.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Site _$SiteFromJson(Map<String, dynamic> json) => _Site(
  id: json['id'] as String,
  customerId: json['customer_id'] as String,
  name: json['name'] as String,
  address: json['address'] as String?,
  latitude: (json['latitude'] as num?)?.toDouble(),
  longitude: (json['longitude'] as num?)?.toDouble(),
  qrCode: json['qr_code'] as String,
  status: json['status'] as String? ?? 'active',
  coverImageUrl: json['cover_image_url'] as String?,
  customerName: json['customer_name'] as String?,
);

Map<String, dynamic> _$SiteToJson(_Site instance) => <String, dynamic>{
  'id': instance.id,
  'customer_id': instance.customerId,
  'name': instance.name,
  'address': instance.address,
  'latitude': instance.latitude,
  'longitude': instance.longitude,
  'qr_code': instance.qrCode,
  'status': instance.status,
  'cover_image_url': instance.coverImageUrl,
  'customer_name': instance.customerName,
};
