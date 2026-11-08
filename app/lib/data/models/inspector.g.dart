// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inspector.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Inspector _$InspectorFromJson(Map<String, dynamic> json) => _Inspector(
  id: json['id'] as String,
  userId: json['user_id'] as String,
  name: json['name'] as String,
  email: json['email'] as String,
  phone: json['phone'] as String?,
  avatarUrl: json['avatar_url'] as String?,
  status: json['status'] as String? ?? 'active',
);

Map<String, dynamic> _$InspectorToJson(_Inspector instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'name': instance.name,
      'email': instance.email,
      'phone': instance.phone,
      'avatar_url': instance.avatarUrl,
      'status': instance.status,
    };
