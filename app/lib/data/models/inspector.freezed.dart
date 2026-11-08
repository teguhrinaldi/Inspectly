// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'inspector.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Inspector {

 String get id; String get userId; String get name; String get email; String? get phone; String? get avatarUrl; String get status;
/// Create a copy of Inspector
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InspectorCopyWith<Inspector> get copyWith => _$InspectorCopyWithImpl<Inspector>(this as Inspector, _$identity);

  /// Serializes this Inspector to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Inspector;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Inspector&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.userId, _this.userId) || other.userId == _this.userId)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.email, _this.email) || other.email == _this.email)&&(identical(other.phone, _this.phone) || other.phone == _this.phone)&&(identical(other.avatarUrl, _this.avatarUrl) || other.avatarUrl == _this.avatarUrl)&&(identical(other.status, _this.status) || other.status == _this.status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Inspector;
  return Object.hash(runtimeType,_this.id,_this.userId,_this.name,_this.email,_this.phone,_this.avatarUrl,_this.status);
}

@override
String toString() {
  final _this = this as Inspector;
  return 'Inspector(id: ${_this.id}, userId: ${_this.userId}, name: ${_this.name}, email: ${_this.email}, phone: ${_this.phone}, avatarUrl: ${_this.avatarUrl}, status: ${_this.status})';
}


}

/// @nodoc
abstract mixin class $InspectorCopyWith<$Res>  {
  factory $InspectorCopyWith(Inspector value, $Res Function(Inspector) _then) = _$InspectorCopyWithImpl;
@useResult
$Res call({
 String id, String userId, String name, String email, String? phone, String? avatarUrl, String status
});




}
/// @nodoc
class _$InspectorCopyWithImpl<$Res>
    implements $InspectorCopyWith<$Res> {
  _$InspectorCopyWithImpl(this._self, this._then);

  final Inspector _self;
  final $Res Function(Inspector) _then;

/// Create a copy of Inspector
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = null,Object? name = null,Object? email = null,Object? phone = freezed,Object? avatarUrl = freezed,Object? status = null,}) {
  return _then(Inspector(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [Inspector].
extension InspectorPatterns on Inspector {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Inspector value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Inspector() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Inspector value)  $default,){
final _that = this;
switch (_that) {
case _Inspector():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Inspector value)?  $default,){
final _that = this;
switch (_that) {
case _Inspector() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String userId,  String name,  String email,  String? phone,  String? avatarUrl,  String status)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Inspector() when $default != null:
return $default(_that.id,_that.userId,_that.name,_that.email,_that.phone,_that.avatarUrl,_that.status);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String userId,  String name,  String email,  String? phone,  String? avatarUrl,  String status)  $default,) {final _that = this;
switch (_that) {
case _Inspector():
return $default(_that.id,_that.userId,_that.name,_that.email,_that.phone,_that.avatarUrl,_that.status);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String userId,  String name,  String email,  String? phone,  String? avatarUrl,  String status)?  $default,) {final _that = this;
switch (_that) {
case _Inspector() when $default != null:
return $default(_that.id,_that.userId,_that.name,_that.email,_that.phone,_that.avatarUrl,_that.status);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Inspector implements Inspector {
  const _Inspector({required this.id, required this.userId, required this.name, required this.email, this.phone, this.avatarUrl, this.status = 'active'});
  factory _Inspector.fromJson(Map<String, dynamic> json) => _$InspectorFromJson(json);

@override final  String id;
@override final  String userId;
@override final  String name;
@override final  String email;
@override final  String? phone;
@override final  String? avatarUrl;
@override@JsonKey() final  String status;

/// Create a copy of Inspector
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InspectorCopyWith<_Inspector> get copyWith => __$InspectorCopyWithImpl<_Inspector>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$InspectorToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Inspector&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.name, name) || other.name == name)&&(identical(other.email, email) || other.email == email)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.status, status) || other.status == status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,userId,name,email,phone,avatarUrl,status);
}

@override
String toString() {
    return 'Inspector(id: $id, userId: $userId, name: $name, email: $email, phone: $phone, avatarUrl: $avatarUrl, status: $status)';
}


}

/// @nodoc
abstract mixin class _$InspectorCopyWith<$Res> implements $InspectorCopyWith<$Res> {
  factory _$InspectorCopyWith(_Inspector value, $Res Function(_Inspector) _then) = __$InspectorCopyWithImpl;
@override @useResult
$Res call({
 String id, String userId, String name, String email, String? phone, String? avatarUrl, String status
});




}
/// @nodoc
class __$InspectorCopyWithImpl<$Res>
    implements _$InspectorCopyWith<$Res> {
  __$InspectorCopyWithImpl(this._self, this._then);

  final _Inspector _self;
  final $Res Function(_Inspector) _then;

/// Create a copy of Inspector
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? name = null,Object? email = null,Object? phone = freezed,Object? avatarUrl = freezed,Object? status = null,}) {
  return _then(_Inspector(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
