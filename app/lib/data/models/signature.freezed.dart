// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'signature.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$InspectionSignature {

 String get id; String get inspectionId; SignatureType get type; String get signerName; String get filePath; String? get fileUrl; DateTime get signedAt;
/// Create a copy of InspectionSignature
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InspectionSignatureCopyWith<InspectionSignature> get copyWith => _$InspectionSignatureCopyWithImpl<InspectionSignature>(this as InspectionSignature, _$identity);

  /// Serializes this InspectionSignature to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as InspectionSignature;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is InspectionSignature&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.inspectionId, _this.inspectionId) || other.inspectionId == _this.inspectionId)&&(identical(other.type, _this.type) || other.type == _this.type)&&(identical(other.signerName, _this.signerName) || other.signerName == _this.signerName)&&(identical(other.filePath, _this.filePath) || other.filePath == _this.filePath)&&(identical(other.fileUrl, _this.fileUrl) || other.fileUrl == _this.fileUrl)&&(identical(other.signedAt, _this.signedAt) || other.signedAt == _this.signedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as InspectionSignature;
  return Object.hash(runtimeType,_this.id,_this.inspectionId,_this.type,_this.signerName,_this.filePath,_this.fileUrl,_this.signedAt);
}

@override
String toString() {
  final _this = this as InspectionSignature;
  return 'InspectionSignature(id: ${_this.id}, inspectionId: ${_this.inspectionId}, type: ${_this.type}, signerName: ${_this.signerName}, filePath: ${_this.filePath}, fileUrl: ${_this.fileUrl}, signedAt: ${_this.signedAt})';
}


}

/// @nodoc
abstract mixin class $InspectionSignatureCopyWith<$Res>  {
  factory $InspectionSignatureCopyWith(InspectionSignature value, $Res Function(InspectionSignature) _then) = _$InspectionSignatureCopyWithImpl;
@useResult
$Res call({
 String id, String inspectionId, SignatureType type, String signerName, String filePath, String? fileUrl, DateTime signedAt
});




}
/// @nodoc
class _$InspectionSignatureCopyWithImpl<$Res>
    implements $InspectionSignatureCopyWith<$Res> {
  _$InspectionSignatureCopyWithImpl(this._self, this._then);

  final InspectionSignature _self;
  final $Res Function(InspectionSignature) _then;

/// Create a copy of InspectionSignature
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? inspectionId = null,Object? type = null,Object? signerName = null,Object? filePath = null,Object? fileUrl = freezed,Object? signedAt = null,}) {
  return _then(InspectionSignature(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,inspectionId: null == inspectionId ? _self.inspectionId : inspectionId // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as SignatureType,signerName: null == signerName ? _self.signerName : signerName // ignore: cast_nullable_to_non_nullable
as String,filePath: null == filePath ? _self.filePath : filePath // ignore: cast_nullable_to_non_nullable
as String,fileUrl: freezed == fileUrl ? _self.fileUrl : fileUrl // ignore: cast_nullable_to_non_nullable
as String?,signedAt: null == signedAt ? _self.signedAt : signedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [InspectionSignature].
extension InspectionSignaturePatterns on InspectionSignature {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _InspectionSignature value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _InspectionSignature() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _InspectionSignature value)  $default,){
final _that = this;
switch (_that) {
case _InspectionSignature():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _InspectionSignature value)?  $default,){
final _that = this;
switch (_that) {
case _InspectionSignature() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String inspectionId,  SignatureType type,  String signerName,  String filePath,  String? fileUrl,  DateTime signedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _InspectionSignature() when $default != null:
return $default(_that.id,_that.inspectionId,_that.type,_that.signerName,_that.filePath,_that.fileUrl,_that.signedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String inspectionId,  SignatureType type,  String signerName,  String filePath,  String? fileUrl,  DateTime signedAt)  $default,) {final _that = this;
switch (_that) {
case _InspectionSignature():
return $default(_that.id,_that.inspectionId,_that.type,_that.signerName,_that.filePath,_that.fileUrl,_that.signedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String inspectionId,  SignatureType type,  String signerName,  String filePath,  String? fileUrl,  DateTime signedAt)?  $default,) {final _that = this;
switch (_that) {
case _InspectionSignature() when $default != null:
return $default(_that.id,_that.inspectionId,_that.type,_that.signerName,_that.filePath,_that.fileUrl,_that.signedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _InspectionSignature implements InspectionSignature {
  const _InspectionSignature({required this.id, required this.inspectionId, required this.type, required this.signerName, required this.filePath, this.fileUrl, required this.signedAt});
  factory _InspectionSignature.fromJson(Map<String, dynamic> json) => _$InspectionSignatureFromJson(json);

@override final  String id;
@override final  String inspectionId;
@override final  SignatureType type;
@override final  String signerName;
@override final  String filePath;
@override final  String? fileUrl;
@override final  DateTime signedAt;

/// Create a copy of InspectionSignature
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InspectionSignatureCopyWith<_InspectionSignature> get copyWith => __$InspectionSignatureCopyWithImpl<_InspectionSignature>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$InspectionSignatureToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _InspectionSignature&&(identical(other.id, id) || other.id == id)&&(identical(other.inspectionId, inspectionId) || other.inspectionId == inspectionId)&&(identical(other.type, type) || other.type == type)&&(identical(other.signerName, signerName) || other.signerName == signerName)&&(identical(other.filePath, filePath) || other.filePath == filePath)&&(identical(other.fileUrl, fileUrl) || other.fileUrl == fileUrl)&&(identical(other.signedAt, signedAt) || other.signedAt == signedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,inspectionId,type,signerName,filePath,fileUrl,signedAt);
}

@override
String toString() {
    return 'InspectionSignature(id: $id, inspectionId: $inspectionId, type: $type, signerName: $signerName, filePath: $filePath, fileUrl: $fileUrl, signedAt: $signedAt)';
}


}

/// @nodoc
abstract mixin class _$InspectionSignatureCopyWith<$Res> implements $InspectionSignatureCopyWith<$Res> {
  factory _$InspectionSignatureCopyWith(_InspectionSignature value, $Res Function(_InspectionSignature) _then) = __$InspectionSignatureCopyWithImpl;
@override @useResult
$Res call({
 String id, String inspectionId, SignatureType type, String signerName, String filePath, String? fileUrl, DateTime signedAt
});




}
/// @nodoc
class __$InspectionSignatureCopyWithImpl<$Res>
    implements _$InspectionSignatureCopyWith<$Res> {
  __$InspectionSignatureCopyWithImpl(this._self, this._then);

  final _InspectionSignature _self;
  final $Res Function(_InspectionSignature) _then;

/// Create a copy of InspectionSignature
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? inspectionId = null,Object? type = null,Object? signerName = null,Object? filePath = null,Object? fileUrl = freezed,Object? signedAt = null,}) {
  return _then(_InspectionSignature(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,inspectionId: null == inspectionId ? _self.inspectionId : inspectionId // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as SignatureType,signerName: null == signerName ? _self.signerName : signerName // ignore: cast_nullable_to_non_nullable
as String,filePath: null == filePath ? _self.filePath : filePath // ignore: cast_nullable_to_non_nullable
as String,fileUrl: freezed == fileUrl ? _self.fileUrl : fileUrl // ignore: cast_nullable_to_non_nullable
as String?,signedAt: null == signedAt ? _self.signedAt : signedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
