// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'evidence.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Evidence {

 String get id; String get inspectionId; String? get inspectionItemId; String? get findingId; String get filePath; String? get watermarkedPath; String? get fileUrl; double? get latitude; double? get longitude; DateTime? get capturedAt;
/// Create a copy of Evidence
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EvidenceCopyWith<Evidence> get copyWith => _$EvidenceCopyWithImpl<Evidence>(this as Evidence, _$identity);

  /// Serializes this Evidence to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Evidence;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Evidence&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.inspectionId, _this.inspectionId) || other.inspectionId == _this.inspectionId)&&(identical(other.inspectionItemId, _this.inspectionItemId) || other.inspectionItemId == _this.inspectionItemId)&&(identical(other.findingId, _this.findingId) || other.findingId == _this.findingId)&&(identical(other.filePath, _this.filePath) || other.filePath == _this.filePath)&&(identical(other.watermarkedPath, _this.watermarkedPath) || other.watermarkedPath == _this.watermarkedPath)&&(identical(other.fileUrl, _this.fileUrl) || other.fileUrl == _this.fileUrl)&&(identical(other.latitude, _this.latitude) || other.latitude == _this.latitude)&&(identical(other.longitude, _this.longitude) || other.longitude == _this.longitude)&&(identical(other.capturedAt, _this.capturedAt) || other.capturedAt == _this.capturedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Evidence;
  return Object.hash(runtimeType,_this.id,_this.inspectionId,_this.inspectionItemId,_this.findingId,_this.filePath,_this.watermarkedPath,_this.fileUrl,_this.latitude,_this.longitude,_this.capturedAt);
}

@override
String toString() {
  final _this = this as Evidence;
  return 'Evidence(id: ${_this.id}, inspectionId: ${_this.inspectionId}, inspectionItemId: ${_this.inspectionItemId}, findingId: ${_this.findingId}, filePath: ${_this.filePath}, watermarkedPath: ${_this.watermarkedPath}, fileUrl: ${_this.fileUrl}, latitude: ${_this.latitude}, longitude: ${_this.longitude}, capturedAt: ${_this.capturedAt})';
}


}

/// @nodoc
abstract mixin class $EvidenceCopyWith<$Res>  {
  factory $EvidenceCopyWith(Evidence value, $Res Function(Evidence) _then) = _$EvidenceCopyWithImpl;
@useResult
$Res call({
 String id, String inspectionId, String? inspectionItemId, String? findingId, String filePath, String? watermarkedPath, String? fileUrl, double? latitude, double? longitude, DateTime? capturedAt
});




}
/// @nodoc
class _$EvidenceCopyWithImpl<$Res>
    implements $EvidenceCopyWith<$Res> {
  _$EvidenceCopyWithImpl(this._self, this._then);

  final Evidence _self;
  final $Res Function(Evidence) _then;

/// Create a copy of Evidence
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? inspectionId = null,Object? inspectionItemId = freezed,Object? findingId = freezed,Object? filePath = null,Object? watermarkedPath = freezed,Object? fileUrl = freezed,Object? latitude = freezed,Object? longitude = freezed,Object? capturedAt = freezed,}) {
  return _then(Evidence(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,inspectionId: null == inspectionId ? _self.inspectionId : inspectionId // ignore: cast_nullable_to_non_nullable
as String,inspectionItemId: freezed == inspectionItemId ? _self.inspectionItemId : inspectionItemId // ignore: cast_nullable_to_non_nullable
as String?,findingId: freezed == findingId ? _self.findingId : findingId // ignore: cast_nullable_to_non_nullable
as String?,filePath: null == filePath ? _self.filePath : filePath // ignore: cast_nullable_to_non_nullable
as String,watermarkedPath: freezed == watermarkedPath ? _self.watermarkedPath : watermarkedPath // ignore: cast_nullable_to_non_nullable
as String?,fileUrl: freezed == fileUrl ? _self.fileUrl : fileUrl // ignore: cast_nullable_to_non_nullable
as String?,latitude: freezed == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double?,longitude: freezed == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double?,capturedAt: freezed == capturedAt ? _self.capturedAt : capturedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [Evidence].
extension EvidencePatterns on Evidence {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Evidence value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Evidence() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Evidence value)  $default,){
final _that = this;
switch (_that) {
case _Evidence():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Evidence value)?  $default,){
final _that = this;
switch (_that) {
case _Evidence() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String inspectionId,  String? inspectionItemId,  String? findingId,  String filePath,  String? watermarkedPath,  String? fileUrl,  double? latitude,  double? longitude,  DateTime? capturedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Evidence() when $default != null:
return $default(_that.id,_that.inspectionId,_that.inspectionItemId,_that.findingId,_that.filePath,_that.watermarkedPath,_that.fileUrl,_that.latitude,_that.longitude,_that.capturedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String inspectionId,  String? inspectionItemId,  String? findingId,  String filePath,  String? watermarkedPath,  String? fileUrl,  double? latitude,  double? longitude,  DateTime? capturedAt)  $default,) {final _that = this;
switch (_that) {
case _Evidence():
return $default(_that.id,_that.inspectionId,_that.inspectionItemId,_that.findingId,_that.filePath,_that.watermarkedPath,_that.fileUrl,_that.latitude,_that.longitude,_that.capturedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String inspectionId,  String? inspectionItemId,  String? findingId,  String filePath,  String? watermarkedPath,  String? fileUrl,  double? latitude,  double? longitude,  DateTime? capturedAt)?  $default,) {final _that = this;
switch (_that) {
case _Evidence() when $default != null:
return $default(_that.id,_that.inspectionId,_that.inspectionItemId,_that.findingId,_that.filePath,_that.watermarkedPath,_that.fileUrl,_that.latitude,_that.longitude,_that.capturedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Evidence implements Evidence {
  const _Evidence({required this.id, required this.inspectionId, this.inspectionItemId, this.findingId, required this.filePath, this.watermarkedPath, this.fileUrl, this.latitude, this.longitude, this.capturedAt});
  factory _Evidence.fromJson(Map<String, dynamic> json) => _$EvidenceFromJson(json);

@override final  String id;
@override final  String inspectionId;
@override final  String? inspectionItemId;
@override final  String? findingId;
@override final  String filePath;
@override final  String? watermarkedPath;
@override final  String? fileUrl;
@override final  double? latitude;
@override final  double? longitude;
@override final  DateTime? capturedAt;

/// Create a copy of Evidence
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EvidenceCopyWith<_Evidence> get copyWith => __$EvidenceCopyWithImpl<_Evidence>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$EvidenceToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Evidence&&(identical(other.id, id) || other.id == id)&&(identical(other.inspectionId, inspectionId) || other.inspectionId == inspectionId)&&(identical(other.inspectionItemId, inspectionItemId) || other.inspectionItemId == inspectionItemId)&&(identical(other.findingId, findingId) || other.findingId == findingId)&&(identical(other.filePath, filePath) || other.filePath == filePath)&&(identical(other.watermarkedPath, watermarkedPath) || other.watermarkedPath == watermarkedPath)&&(identical(other.fileUrl, fileUrl) || other.fileUrl == fileUrl)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.capturedAt, capturedAt) || other.capturedAt == capturedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,inspectionId,inspectionItemId,findingId,filePath,watermarkedPath,fileUrl,latitude,longitude,capturedAt);
}

@override
String toString() {
    return 'Evidence(id: $id, inspectionId: $inspectionId, inspectionItemId: $inspectionItemId, findingId: $findingId, filePath: $filePath, watermarkedPath: $watermarkedPath, fileUrl: $fileUrl, latitude: $latitude, longitude: $longitude, capturedAt: $capturedAt)';
}


}

/// @nodoc
abstract mixin class _$EvidenceCopyWith<$Res> implements $EvidenceCopyWith<$Res> {
  factory _$EvidenceCopyWith(_Evidence value, $Res Function(_Evidence) _then) = __$EvidenceCopyWithImpl;
@override @useResult
$Res call({
 String id, String inspectionId, String? inspectionItemId, String? findingId, String filePath, String? watermarkedPath, String? fileUrl, double? latitude, double? longitude, DateTime? capturedAt
});




}
/// @nodoc
class __$EvidenceCopyWithImpl<$Res>
    implements _$EvidenceCopyWith<$Res> {
  __$EvidenceCopyWithImpl(this._self, this._then);

  final _Evidence _self;
  final $Res Function(_Evidence) _then;

/// Create a copy of Evidence
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? inspectionId = null,Object? inspectionItemId = freezed,Object? findingId = freezed,Object? filePath = null,Object? watermarkedPath = freezed,Object? fileUrl = freezed,Object? latitude = freezed,Object? longitude = freezed,Object? capturedAt = freezed,}) {
  return _then(_Evidence(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,inspectionId: null == inspectionId ? _self.inspectionId : inspectionId // ignore: cast_nullable_to_non_nullable
as String,inspectionItemId: freezed == inspectionItemId ? _self.inspectionItemId : inspectionItemId // ignore: cast_nullable_to_non_nullable
as String?,findingId: freezed == findingId ? _self.findingId : findingId // ignore: cast_nullable_to_non_nullable
as String?,filePath: null == filePath ? _self.filePath : filePath // ignore: cast_nullable_to_non_nullable
as String,watermarkedPath: freezed == watermarkedPath ? _self.watermarkedPath : watermarkedPath // ignore: cast_nullable_to_non_nullable
as String?,fileUrl: freezed == fileUrl ? _self.fileUrl : fileUrl // ignore: cast_nullable_to_non_nullable
as String?,latitude: freezed == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double?,longitude: freezed == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double?,capturedAt: freezed == capturedAt ? _self.capturedAt : capturedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
