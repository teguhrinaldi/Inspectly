// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'activity_entry.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ActivityEntry {

 String get id; String get inspectionId; ActivityType get type; String get description; String? get actorName; DateTime get occurredAt;
/// Create a copy of ActivityEntry
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ActivityEntryCopyWith<ActivityEntry> get copyWith => _$ActivityEntryCopyWithImpl<ActivityEntry>(this as ActivityEntry, _$identity);

  /// Serializes this ActivityEntry to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ActivityEntry;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ActivityEntry&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.inspectionId, _this.inspectionId) || other.inspectionId == _this.inspectionId)&&(identical(other.type, _this.type) || other.type == _this.type)&&(identical(other.description, _this.description) || other.description == _this.description)&&(identical(other.actorName, _this.actorName) || other.actorName == _this.actorName)&&(identical(other.occurredAt, _this.occurredAt) || other.occurredAt == _this.occurredAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ActivityEntry;
  return Object.hash(runtimeType,_this.id,_this.inspectionId,_this.type,_this.description,_this.actorName,_this.occurredAt);
}

@override
String toString() {
  final _this = this as ActivityEntry;
  return 'ActivityEntry(id: ${_this.id}, inspectionId: ${_this.inspectionId}, type: ${_this.type}, description: ${_this.description}, actorName: ${_this.actorName}, occurredAt: ${_this.occurredAt})';
}


}

/// @nodoc
abstract mixin class $ActivityEntryCopyWith<$Res>  {
  factory $ActivityEntryCopyWith(ActivityEntry value, $Res Function(ActivityEntry) _then) = _$ActivityEntryCopyWithImpl;
@useResult
$Res call({
 String id, String inspectionId, ActivityType type, String description, String? actorName, DateTime occurredAt
});




}
/// @nodoc
class _$ActivityEntryCopyWithImpl<$Res>
    implements $ActivityEntryCopyWith<$Res> {
  _$ActivityEntryCopyWithImpl(this._self, this._then);

  final ActivityEntry _self;
  final $Res Function(ActivityEntry) _then;

/// Create a copy of ActivityEntry
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? inspectionId = null,Object? type = null,Object? description = null,Object? actorName = freezed,Object? occurredAt = null,}) {
  return _then(ActivityEntry(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,inspectionId: null == inspectionId ? _self.inspectionId : inspectionId // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as ActivityType,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,actorName: freezed == actorName ? _self.actorName : actorName // ignore: cast_nullable_to_non_nullable
as String?,occurredAt: null == occurredAt ? _self.occurredAt : occurredAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [ActivityEntry].
extension ActivityEntryPatterns on ActivityEntry {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ActivityEntry value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ActivityEntry() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ActivityEntry value)  $default,){
final _that = this;
switch (_that) {
case _ActivityEntry():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ActivityEntry value)?  $default,){
final _that = this;
switch (_that) {
case _ActivityEntry() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String inspectionId,  ActivityType type,  String description,  String? actorName,  DateTime occurredAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ActivityEntry() when $default != null:
return $default(_that.id,_that.inspectionId,_that.type,_that.description,_that.actorName,_that.occurredAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String inspectionId,  ActivityType type,  String description,  String? actorName,  DateTime occurredAt)  $default,) {final _that = this;
switch (_that) {
case _ActivityEntry():
return $default(_that.id,_that.inspectionId,_that.type,_that.description,_that.actorName,_that.occurredAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String inspectionId,  ActivityType type,  String description,  String? actorName,  DateTime occurredAt)?  $default,) {final _that = this;
switch (_that) {
case _ActivityEntry() when $default != null:
return $default(_that.id,_that.inspectionId,_that.type,_that.description,_that.actorName,_that.occurredAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ActivityEntry implements ActivityEntry {
  const _ActivityEntry({required this.id, required this.inspectionId, required this.type, this.description = '', this.actorName, required this.occurredAt});
  factory _ActivityEntry.fromJson(Map<String, dynamic> json) => _$ActivityEntryFromJson(json);

@override final  String id;
@override final  String inspectionId;
@override final  ActivityType type;
@override@JsonKey() final  String description;
@override final  String? actorName;
@override final  DateTime occurredAt;

/// Create a copy of ActivityEntry
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ActivityEntryCopyWith<_ActivityEntry> get copyWith => __$ActivityEntryCopyWithImpl<_ActivityEntry>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ActivityEntryToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ActivityEntry&&(identical(other.id, id) || other.id == id)&&(identical(other.inspectionId, inspectionId) || other.inspectionId == inspectionId)&&(identical(other.type, type) || other.type == type)&&(identical(other.description, description) || other.description == description)&&(identical(other.actorName, actorName) || other.actorName == actorName)&&(identical(other.occurredAt, occurredAt) || other.occurredAt == occurredAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,inspectionId,type,description,actorName,occurredAt);
}

@override
String toString() {
    return 'ActivityEntry(id: $id, inspectionId: $inspectionId, type: $type, description: $description, actorName: $actorName, occurredAt: $occurredAt)';
}


}

/// @nodoc
abstract mixin class _$ActivityEntryCopyWith<$Res> implements $ActivityEntryCopyWith<$Res> {
  factory _$ActivityEntryCopyWith(_ActivityEntry value, $Res Function(_ActivityEntry) _then) = __$ActivityEntryCopyWithImpl;
@override @useResult
$Res call({
 String id, String inspectionId, ActivityType type, String description, String? actorName, DateTime occurredAt
});




}
/// @nodoc
class __$ActivityEntryCopyWithImpl<$Res>
    implements _$ActivityEntryCopyWith<$Res> {
  __$ActivityEntryCopyWithImpl(this._self, this._then);

  final _ActivityEntry _self;
  final $Res Function(_ActivityEntry) _then;

/// Create a copy of ActivityEntry
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? inspectionId = null,Object? type = null,Object? description = null,Object? actorName = freezed,Object? occurredAt = null,}) {
  return _then(_ActivityEntry(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,inspectionId: null == inspectionId ? _self.inspectionId : inspectionId // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as ActivityType,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,actorName: freezed == actorName ? _self.actorName : actorName // ignore: cast_nullable_to_non_nullable
as String?,occurredAt: null == occurredAt ? _self.occurredAt : occurredAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
