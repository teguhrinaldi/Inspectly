// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AppUser _$AppUserFromJson(Map<String, dynamic> json) => _AppUser(
  id: json['id'] as String,
  name: json['name'] as String,
  email: json['email'] as String,
  role: $enumDecode(_$UserRoleEnumMap, json['role']),
  phone: json['phone'] as String?,
  avatarUrl: json['avatar_url'] as String?,
  status: json['status'] as String? ?? 'active',
);

Map<String, dynamic> _$AppUserToJson(_AppUser instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'email': instance.email,
  'role': _$UserRoleEnumMap[instance.role]!,
  'phone': instance.phone,
  'avatar_url': instance.avatarUrl,
  'status': instance.status,
};

const _$UserRoleEnumMap = {
  UserRole.inspector: 'inspector',
  UserRole.admin: 'admin',
};
