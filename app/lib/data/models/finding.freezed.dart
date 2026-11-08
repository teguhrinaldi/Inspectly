// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'finding.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Finding {

 String get id; String get inspectionId; String? get inspectionItemId; String get title; String get description; FindingSeverity get severity; String? get recommendation; String? get location; FindingStatus get status; List<Evidence> get evidence;
/// Create a copy of Finding
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FindingCopyWith<Finding> get copyWith => _$FindingCopyWithImpl<Finding>(this as Finding, _$identity);

  /// Serializes this Finding to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Finding;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Finding&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.inspectionId, _this.inspectionId) || other.inspectionId == _this.inspectionId)&&(identical(other.inspectionItemId, _this.inspectionItemId) || other.inspectionItemId == _this.inspectionItemId)&&(identical(other.title, _this.title) || other.title == _this.title)&&(identical(other.description, _this.description) || other.description == _this.description)&&(identical(other.severity, _this.severity) || other.severity == _this.severity)&&(identical(other.recommendation, _this.recommendation) || other.recommendation == _this.recommendation)&&(identical(other.location, _this.location) || other.location == _this.location)&&(identical(other.status, _this.status) || other.status == _this.status)&&const DeepCollectionEquality().equals(other.evidence, _this.evidence));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Finding;
  return Object.hash(runtimeType,_this.id,_this.inspectionId,_this.inspectionItemId,_this.title,_this.description,_this.severity,_this.recommendation,_this.location,_this.status,const DeepCollectionEquality().hash(_this.evidence));
}

@override
String toString() {
  final _this = this as Finding;
  return 'Finding(id: ${_this.id}, inspectionId: ${_this.inspectionId}, inspectionItemId: ${_this.inspectionItemId}, title: ${_this.title}, description: ${_this.description}, severity: ${_this.severity}, recommendation: ${_this.recommendation}, location: ${_this.location}, status: ${_this.status}, evidence: ${_this.evidence})';
}


}

/// @nodoc
abstract mixin class $FindingCopyWith<$Res>  {
  factory $FindingCopyWith(Finding value, $Res Function(Finding) _then) = _$FindingCopyWithImpl;
@useResult
$Res call({
 String id, String inspectionId, String? inspectionItemId, String title, String description, FindingSeverity severity, String? recommendation, String? location, FindingStatus status, List<Evidence> evidence
});




}
/// @nodoc
class _$FindingCopyWithImpl<$Res>
    implements $FindingCopyWith<$Res> {
  _$FindingCopyWithImpl(this._self, this._then);

  final Finding _self;
  final $Res Function(Finding) _then;

/// Create a copy of Finding
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? inspectionId = null,Object? inspectionItemId = freezed,Object? title = null,Object? description = null,Object? severity = null,Object? recommendation = freezed,Object? location = freezed,Object? status = null,Object? evidence = null,}) {
  return _then(Finding(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,inspectionId: null == inspectionId ? _self.inspectionId : inspectionId // ignore: cast_nullable_to_non_nullable
as String,inspectionItemId: freezed == inspectionItemId ? _self.inspectionItemId : inspectionItemId // ignore: cast_nullable_to_non_nullable
as String?,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,severity: null == severity ? _self.severity : severity // ignore: cast_nullable_to_non_nullable
as FindingSeverity,recommendation: freezed == recommendation ? _self.recommendation : recommendation // ignore: cast_nullable_to_non_nullable
as String?,location: freezed == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as FindingStatus,evidence: null == evidence ? _self.evidence : evidence // ignore: cast_nullable_to_non_nullable
as List<Evidence>,
  ));
}

}


/// Adds pattern-matching-related methods to [Finding].
extension FindingPatterns on Finding {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Finding value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Finding() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Finding value)  $default,){
final _that = this;
switch (_that) {
case _Finding():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Finding value)?  $default,){
final _that = this;
switch (_that) {
case _Finding() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String inspectionId,  String? inspectionItemId,  String title,  String description,  FindingSeverity severity,  String? recommendation,  String? location,  FindingStatus status,  List<Evidence> evidence)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Finding() when $default != null:
return $default(_that.id,_that.inspectionId,_that.inspectionItemId,_that.title,_that.description,_that.severity,_that.recommendation,_that.location,_that.status,_that.evidence);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String inspectionId,  String? inspectionItemId,  String title,  String description,  FindingSeverity severity,  String? recommendation,  String? location,  FindingStatus status,  List<Evidence> evidence)  $default,) {final _that = this;
switch (_that) {
case _Finding():
return $default(_that.id,_that.inspectionId,_that.inspectionItemId,_that.title,_that.description,_that.severity,_that.recommendation,_that.location,_that.status,_that.evidence);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String inspectionId,  String? inspectionItemId,  String title,  String description,  FindingSeverity severity,  String? recommendation,  String? location,  FindingStatus status,  List<Evidence> evidence)?  $default,) {final _that = this;
switch (_that) {
case _Finding() when $default != null:
return $default(_that.id,_that.inspectionId,_that.inspectionItemId,_that.title,_that.description,_that.severity,_that.recommendation,_that.location,_that.status,_that.evidence);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Finding implements Finding {
  const _Finding({required this.id, required this.inspectionId, this.inspectionItemId, required this.title, this.description = '', required this.severity, this.recommendation, this.location, this.status = FindingStatus.open,  List<Evidence> evidence = const <Evidence>[]}): _evidence = evidence;
  factory _Finding.fromJson(Map<String, dynamic> json) => _$FindingFromJson(json);

@override final  String id;
@override final  String inspectionId;
@override final  String? inspectionItemId;
@override final  String title;
@override@JsonKey() final  String description;
@override final  FindingSeverity severity;
@override final  String? recommendation;
@override final  String? location;
@override@JsonKey() final  FindingStatus status;
 final  List<Evidence> _evidence;
@override@JsonKey() List<Evidence> get evidence {
  if (_evidence is EqualUnmodifiableListView) return _evidence;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_evidence);
}


/// Create a copy of Finding
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FindingCopyWith<_Finding> get copyWith => __$FindingCopyWithImpl<_Finding>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FindingToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Finding&&(identical(other.id, id) || other.id == id)&&(identical(other.inspectionId, inspectionId) || other.inspectionId == inspectionId)&&(identical(other.inspectionItemId, inspectionItemId) || other.inspectionItemId == inspectionItemId)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.severity, severity) || other.severity == severity)&&(identical(other.recommendation, recommendation) || other.recommendation == recommendation)&&(identical(other.location, location) || other.location == location)&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other.evidence, _evidence));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,inspectionId,inspectionItemId,title,description,severity,recommendation,location,status,const DeepCollectionEquality().hash(_evidence));
}

@override
String toString() {
    return 'Finding(id: $id, inspectionId: $inspectionId, inspectionItemId: $inspectionItemId, title: $title, description: $description, severity: $severity, recommendation: $recommendation, location: $location, status: $status, evidence: $evidence)';
}


}

/// @nodoc
abstract mixin class _$FindingCopyWith<$Res> implements $FindingCopyWith<$Res> {
  factory _$FindingCopyWith(_Finding value, $Res Function(_Finding) _then) = __$FindingCopyWithImpl;
@override @useResult
$Res call({
 String id, String inspectionId, String? inspectionItemId, String title, String description, FindingSeverity severity, String? recommendation, String? location, FindingStatus status, List<Evidence> evidence
});




}
/// @nodoc
class __$FindingCopyWithImpl<$Res>
    implements _$FindingCopyWith<$Res> {
  __$FindingCopyWithImpl(this._self, this._then);

  final _Finding _self;
  final $Res Function(_Finding) _then;

/// Create a copy of Finding
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? inspectionId = null,Object? inspectionItemId = freezed,Object? title = null,Object? description = null,Object? severity = null,Object? recommendation = freezed,Object? location = freezed,Object? status = null,Object? evidence = null,}) {
  return _then(_Finding(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,inspectionId: null == inspectionId ? _self.inspectionId : inspectionId // ignore: cast_nullable_to_non_nullable
as String,inspectionItemId: freezed == inspectionItemId ? _self.inspectionItemId : inspectionItemId // ignore: cast_nullable_to_non_nullable
as String?,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,severity: null == severity ? _self.severity : severity // ignore: cast_nullable_to_non_nullable
as FindingSeverity,recommendation: freezed == recommendation ? _self.recommendation : recommendation // ignore: cast_nullable_to_non_nullable
as String?,location: freezed == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as FindingStatus,evidence: null == evidence ? _self._evidence : evidence // ignore: cast_nullable_to_non_nullable
as List<Evidence>,
  ));
}


}

// dart format on
