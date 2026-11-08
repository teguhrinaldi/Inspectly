// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'site.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Site {

 String get id; String get customerId; String get name; String? get address; double? get latitude; double? get longitude; String get qrCode; String get status; String? get coverImageUrl; String? get customerName;
/// Create a copy of Site
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SiteCopyWith<Site> get copyWith => _$SiteCopyWithImpl<Site>(this as Site, _$identity);

  /// Serializes this Site to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Site;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Site&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.customerId, _this.customerId) || other.customerId == _this.customerId)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.address, _this.address) || other.address == _this.address)&&(identical(other.latitude, _this.latitude) || other.latitude == _this.latitude)&&(identical(other.longitude, _this.longitude) || other.longitude == _this.longitude)&&(identical(other.qrCode, _this.qrCode) || other.qrCode == _this.qrCode)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.coverImageUrl, _this.coverImageUrl) || other.coverImageUrl == _this.coverImageUrl)&&(identical(other.customerName, _this.customerName) || other.customerName == _this.customerName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Site;
  return Object.hash(runtimeType,_this.id,_this.customerId,_this.name,_this.address,_this.latitude,_this.longitude,_this.qrCode,_this.status,_this.coverImageUrl,_this.customerName);
}

@override
String toString() {
  final _this = this as Site;
  return 'Site(id: ${_this.id}, customerId: ${_this.customerId}, name: ${_this.name}, address: ${_this.address}, latitude: ${_this.latitude}, longitude: ${_this.longitude}, qrCode: ${_this.qrCode}, status: ${_this.status}, coverImageUrl: ${_this.coverImageUrl}, customerName: ${_this.customerName})';
}


}

/// @nodoc
abstract mixin class $SiteCopyWith<$Res>  {
  factory $SiteCopyWith(Site value, $Res Function(Site) _then) = _$SiteCopyWithImpl;
@useResult
$Res call({
 String id, String customerId, String name, String? address, double? latitude, double? longitude, String qrCode, String status, String? coverImageUrl, String? customerName
});




}
/// @nodoc
class _$SiteCopyWithImpl<$Res>
    implements $SiteCopyWith<$Res> {
  _$SiteCopyWithImpl(this._self, this._then);

  final Site _self;
  final $Res Function(Site) _then;

/// Create a copy of Site
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? customerId = null,Object? name = null,Object? address = freezed,Object? latitude = freezed,Object? longitude = freezed,Object? qrCode = null,Object? status = null,Object? coverImageUrl = freezed,Object? customerName = freezed,}) {
  return _then(Site(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,customerId: null == customerId ? _self.customerId : customerId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String?,latitude: freezed == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double?,longitude: freezed == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double?,qrCode: null == qrCode ? _self.qrCode : qrCode // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,coverImageUrl: freezed == coverImageUrl ? _self.coverImageUrl : coverImageUrl // ignore: cast_nullable_to_non_nullable
as String?,customerName: freezed == customerName ? _self.customerName : customerName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [Site].
extension SitePatterns on Site {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Site value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Site() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Site value)  $default,){
final _that = this;
switch (_that) {
case _Site():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Site value)?  $default,){
final _that = this;
switch (_that) {
case _Site() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String customerId,  String name,  String? address,  double? latitude,  double? longitude,  String qrCode,  String status,  String? coverImageUrl,  String? customerName)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Site() when $default != null:
return $default(_that.id,_that.customerId,_that.name,_that.address,_that.latitude,_that.longitude,_that.qrCode,_that.status,_that.coverImageUrl,_that.customerName);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String customerId,  String name,  String? address,  double? latitude,  double? longitude,  String qrCode,  String status,  String? coverImageUrl,  String? customerName)  $default,) {final _that = this;
switch (_that) {
case _Site():
return $default(_that.id,_that.customerId,_that.name,_that.address,_that.latitude,_that.longitude,_that.qrCode,_that.status,_that.coverImageUrl,_that.customerName);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String customerId,  String name,  String? address,  double? latitude,  double? longitude,  String qrCode,  String status,  String? coverImageUrl,  String? customerName)?  $default,) {final _that = this;
switch (_that) {
case _Site() when $default != null:
return $default(_that.id,_that.customerId,_that.name,_that.address,_that.latitude,_that.longitude,_that.qrCode,_that.status,_that.coverImageUrl,_that.customerName);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Site implements Site {
  const _Site({required this.id, required this.customerId, required this.name, this.address, this.latitude, this.longitude, required this.qrCode, this.status = 'active', this.coverImageUrl, this.customerName});
  factory _Site.fromJson(Map<String, dynamic> json) => _$SiteFromJson(json);

@override final  String id;
@override final  String customerId;
@override final  String name;
@override final  String? address;
@override final  double? latitude;
@override final  double? longitude;
@override final  String qrCode;
@override@JsonKey() final  String status;
@override final  String? coverImageUrl;
@override final  String? customerName;

/// Create a copy of Site
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SiteCopyWith<_Site> get copyWith => __$SiteCopyWithImpl<_Site>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SiteToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Site&&(identical(other.id, id) || other.id == id)&&(identical(other.customerId, customerId) || other.customerId == customerId)&&(identical(other.name, name) || other.name == name)&&(identical(other.address, address) || other.address == address)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.qrCode, qrCode) || other.qrCode == qrCode)&&(identical(other.status, status) || other.status == status)&&(identical(other.coverImageUrl, coverImageUrl) || other.coverImageUrl == coverImageUrl)&&(identical(other.customerName, customerName) || other.customerName == customerName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,customerId,name,address,latitude,longitude,qrCode,status,coverImageUrl,customerName);
}

@override
String toString() {
    return 'Site(id: $id, customerId: $customerId, name: $name, address: $address, latitude: $latitude, longitude: $longitude, qrCode: $qrCode, status: $status, coverImageUrl: $coverImageUrl, customerName: $customerName)';
}


}

/// @nodoc
abstract mixin class _$SiteCopyWith<$Res> implements $SiteCopyWith<$Res> {
  factory _$SiteCopyWith(_Site value, $Res Function(_Site) _then) = __$SiteCopyWithImpl;
@override @useResult
$Res call({
 String id, String customerId, String name, String? address, double? latitude, double? longitude, String qrCode, String status, String? coverImageUrl, String? customerName
});




}
/// @nodoc
class __$SiteCopyWithImpl<$Res>
    implements _$SiteCopyWith<$Res> {
  __$SiteCopyWithImpl(this._self, this._then);

  final _Site _self;
  final $Res Function(_Site) _then;

/// Create a copy of Site
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? customerId = null,Object? name = null,Object? address = freezed,Object? latitude = freezed,Object? longitude = freezed,Object? qrCode = null,Object? status = null,Object? coverImageUrl = freezed,Object? customerName = freezed,}) {
  return _then(_Site(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,customerId: null == customerId ? _self.customerId : customerId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String?,latitude: freezed == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double?,longitude: freezed == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double?,qrCode: null == qrCode ? _self.qrCode : qrCode // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,coverImageUrl: freezed == coverImageUrl ? _self.coverImageUrl : coverImageUrl // ignore: cast_nullable_to_non_nullable
as String?,customerName: freezed == customerName ? _self.customerName : customerName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
