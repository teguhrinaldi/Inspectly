// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'inspection_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$InspectionItem {

 String get id; String get inspectionId; String get templateChecklistItemId; String get label; String? get helpText; ChecklistResult? get result; String? get note; int get sortOrder; List<Evidence> get evidence;
/// Create a copy of InspectionItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InspectionItemCopyWith<InspectionItem> get copyWith => _$InspectionItemCopyWithImpl<InspectionItem>(this as InspectionItem, _$identity);

  /// Serializes this InspectionItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as InspectionItem;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is InspectionItem&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.inspectionId, _this.inspectionId) || other.inspectionId == _this.inspectionId)&&(identical(other.templateChecklistItemId, _this.templateChecklistItemId) || other.templateChecklistItemId == _this.templateChecklistItemId)&&(identical(other.label, _this.label) || other.label == _this.label)&&(identical(other.helpText, _this.helpText) || other.helpText == _this.helpText)&&(identical(other.result, _this.result) || other.result == _this.result)&&(identical(other.note, _this.note) || other.note == _this.note)&&(identical(other.sortOrder, _this.sortOrder) || other.sortOrder == _this.sortOrder)&&const DeepCollectionEquality().equals(other.evidence, _this.evidence));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as InspectionItem;
  return Object.hash(runtimeType,_this.id,_this.inspectionId,_this.templateChecklistItemId,_this.label,_this.helpText,_this.result,_this.note,_this.sortOrder,const DeepCollectionEquality().hash(_this.evidence));
}

@override
String toString() {
  final _this = this as InspectionItem;
  return 'InspectionItem(id: ${_this.id}, inspectionId: ${_this.inspectionId}, templateChecklistItemId: ${_this.templateChecklistItemId}, label: ${_this.label}, helpText: ${_this.helpText}, result: ${_this.result}, note: ${_this.note}, sortOrder: ${_this.sortOrder}, evidence: ${_this.evidence})';
}


}

/// @nodoc
abstract mixin class $InspectionItemCopyWith<$Res>  {
  factory $InspectionItemCopyWith(InspectionItem value, $Res Function(InspectionItem) _then) = _$InspectionItemCopyWithImpl;
@useResult
$Res call({
 String id, String inspectionId, String templateChecklistItemId, String label, String? helpText, ChecklistResult? result, String? note, int sortOrder, List<Evidence> evidence
});




}
/// @nodoc
class _$InspectionItemCopyWithImpl<$Res>
    implements $InspectionItemCopyWith<$Res> {
  _$InspectionItemCopyWithImpl(this._self, this._then);

  final InspectionItem _self;
  final $Res Function(InspectionItem) _then;

/// Create a copy of InspectionItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? inspectionId = null,Object? templateChecklistItemId = null,Object? label = null,Object? helpText = freezed,Object? result = freezed,Object? note = freezed,Object? sortOrder = null,Object? evidence = null,}) {
  return _then(InspectionItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,inspectionId: null == inspectionId ? _self.inspectionId : inspectionId // ignore: cast_nullable_to_non_nullable
as String,templateChecklistItemId: null == templateChecklistItemId ? _self.templateChecklistItemId : templateChecklistItemId // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,helpText: freezed == helpText ? _self.helpText : helpText // ignore: cast_nullable_to_non_nullable
as String?,result: freezed == result ? _self.result : result // ignore: cast_nullable_to_non_nullable
as ChecklistResult?,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,evidence: null == evidence ? _self.evidence : evidence // ignore: cast_nullable_to_non_nullable
as List<Evidence>,
  ));
}

}


/// Adds pattern-matching-related methods to [InspectionItem].
extension InspectionItemPatterns on InspectionItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _InspectionItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _InspectionItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _InspectionItem value)  $default,){
final _that = this;
switch (_that) {
case _InspectionItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _InspectionItem value)?  $default,){
final _that = this;
switch (_that) {
case _InspectionItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String inspectionId,  String templateChecklistItemId,  String label,  String? helpText,  ChecklistResult? result,  String? note,  int sortOrder,  List<Evidence> evidence)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _InspectionItem() when $default != null:
return $default(_that.id,_that.inspectionId,_that.templateChecklistItemId,_that.label,_that.helpText,_that.result,_that.note,_that.sortOrder,_that.evidence);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String inspectionId,  String templateChecklistItemId,  String label,  String? helpText,  ChecklistResult? result,  String? note,  int sortOrder,  List<Evidence> evidence)  $default,) {final _that = this;
switch (_that) {
case _InspectionItem():
return $default(_that.id,_that.inspectionId,_that.templateChecklistItemId,_that.label,_that.helpText,_that.result,_that.note,_that.sortOrder,_that.evidence);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String inspectionId,  String templateChecklistItemId,  String label,  String? helpText,  ChecklistResult? result,  String? note,  int sortOrder,  List<Evidence> evidence)?  $default,) {final _that = this;
switch (_that) {
case _InspectionItem() when $default != null:
return $default(_that.id,_that.inspectionId,_that.templateChecklistItemId,_that.label,_that.helpText,_that.result,_that.note,_that.sortOrder,_that.evidence);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _InspectionItem implements InspectionItem {
  const _InspectionItem({required this.id, required this.inspectionId, required this.templateChecklistItemId, required this.label, this.helpText, this.result, this.note, this.sortOrder = 0,  List<Evidence> evidence = const <Evidence>[]}): _evidence = evidence;
  factory _InspectionItem.fromJson(Map<String, dynamic> json) => _$InspectionItemFromJson(json);

@override final  String id;
@override final  String inspectionId;
@override final  String templateChecklistItemId;
@override final  String label;
@override final  String? helpText;
@override final  ChecklistResult? result;
@override final  String? note;
@override@JsonKey() final  int sortOrder;
 final  List<Evidence> _evidence;
@override@JsonKey() List<Evidence> get evidence {
  if (_evidence is EqualUnmodifiableListView) return _evidence;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_evidence);
}


/// Create a copy of InspectionItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InspectionItemCopyWith<_InspectionItem> get copyWith => __$InspectionItemCopyWithImpl<_InspectionItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$InspectionItemToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _InspectionItem&&(identical(other.id, id) || other.id == id)&&(identical(other.inspectionId, inspectionId) || other.inspectionId == inspectionId)&&(identical(other.templateChecklistItemId, templateChecklistItemId) || other.templateChecklistItemId == templateChecklistItemId)&&(identical(other.label, label) || other.label == label)&&(identical(other.helpText, helpText) || other.helpText == helpText)&&(identical(other.result, result) || other.result == result)&&(identical(other.note, note) || other.note == note)&&(identical(other.sortOrder, sortOrder) || other.sortOrder == sortOrder)&&const DeepCollectionEquality().equals(other.evidence, _evidence));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,inspectionId,templateChecklistItemId,label,helpText,result,note,sortOrder,const DeepCollectionEquality().hash(_evidence));
}

@override
String toString() {
    return 'InspectionItem(id: $id, inspectionId: $inspectionId, templateChecklistItemId: $templateChecklistItemId, label: $label, helpText: $helpText, result: $result, note: $note, sortOrder: $sortOrder, evidence: $evidence)';
}


}

/// @nodoc
abstract mixin class _$InspectionItemCopyWith<$Res> implements $InspectionItemCopyWith<$Res> {
  factory _$InspectionItemCopyWith(_InspectionItem value, $Res Function(_InspectionItem) _then) = __$InspectionItemCopyWithImpl;
@override @useResult
$Res call({
 String id, String inspectionId, String templateChecklistItemId, String label, String? helpText, ChecklistResult? result, String? note, int sortOrder, List<Evidence> evidence
});




}
/// @nodoc
class __$InspectionItemCopyWithImpl<$Res>
    implements _$InspectionItemCopyWith<$Res> {
  __$InspectionItemCopyWithImpl(this._self, this._then);

  final _InspectionItem _self;
  final $Res Function(_InspectionItem) _then;

/// Create a copy of InspectionItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? inspectionId = null,Object? templateChecklistItemId = null,Object? label = null,Object? helpText = freezed,Object? result = freezed,Object? note = freezed,Object? sortOrder = null,Object? evidence = null,}) {
  return _then(_InspectionItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,inspectionId: null == inspectionId ? _self.inspectionId : inspectionId // ignore: cast_nullable_to_non_nullable
as String,templateChecklistItemId: null == templateChecklistItemId ? _self.templateChecklistItemId : templateChecklistItemId // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,helpText: freezed == helpText ? _self.helpText : helpText // ignore: cast_nullable_to_non_nullable
as String?,result: freezed == result ? _self.result : result // ignore: cast_nullable_to_non_nullable
as ChecklistResult?,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,evidence: null == evidence ? _self._evidence : evidence // ignore: cast_nullable_to_non_nullable
as List<Evidence>,
  ));
}


}

// dart format on
