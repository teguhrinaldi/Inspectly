// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'site_history.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SiteHistoryEntry {

 String get inspectionId; String get templateName; InspectionStatus get status; DateTime? get completedAt; double? get passPercentage;
/// Create a copy of SiteHistoryEntry
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SiteHistoryEntryCopyWith<SiteHistoryEntry> get copyWith => _$SiteHistoryEntryCopyWithImpl<SiteHistoryEntry>(this as SiteHistoryEntry, _$identity);

  /// Serializes this SiteHistoryEntry to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as SiteHistoryEntry;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SiteHistoryEntry&&(identical(other.inspectionId, _this.inspectionId) || other.inspectionId == _this.inspectionId)&&(identical(other.templateName, _this.templateName) || other.templateName == _this.templateName)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.completedAt, _this.completedAt) || other.completedAt == _this.completedAt)&&(identical(other.passPercentage, _this.passPercentage) || other.passPercentage == _this.passPercentage));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as SiteHistoryEntry;
  return Object.hash(runtimeType,_this.inspectionId,_this.templateName,_this.status,_this.completedAt,_this.passPercentage);
}

@override
String toString() {
  final _this = this as SiteHistoryEntry;
  return 'SiteHistoryEntry(inspectionId: ${_this.inspectionId}, templateName: ${_this.templateName}, status: ${_this.status}, completedAt: ${_this.completedAt}, passPercentage: ${_this.passPercentage})';
}


}

/// @nodoc
abstract mixin class $SiteHistoryEntryCopyWith<$Res>  {
  factory $SiteHistoryEntryCopyWith(SiteHistoryEntry value, $Res Function(SiteHistoryEntry) _then) = _$SiteHistoryEntryCopyWithImpl;
@useResult
$Res call({
 String inspectionId, String templateName, InspectionStatus status, DateTime? completedAt, double? passPercentage
});




}
/// @nodoc
class _$SiteHistoryEntryCopyWithImpl<$Res>
    implements $SiteHistoryEntryCopyWith<$Res> {
  _$SiteHistoryEntryCopyWithImpl(this._self, this._then);

  final SiteHistoryEntry _self;
  final $Res Function(SiteHistoryEntry) _then;

/// Create a copy of SiteHistoryEntry
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? inspectionId = null,Object? templateName = null,Object? status = null,Object? completedAt = freezed,Object? passPercentage = freezed,}) {
  return _then(SiteHistoryEntry(
inspectionId: null == inspectionId ? _self.inspectionId : inspectionId // ignore: cast_nullable_to_non_nullable
as String,templateName: null == templateName ? _self.templateName : templateName // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as InspectionStatus,completedAt: freezed == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,passPercentage: freezed == passPercentage ? _self.passPercentage : passPercentage // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}

}


/// Adds pattern-matching-related methods to [SiteHistoryEntry].
extension SiteHistoryEntryPatterns on SiteHistoryEntry {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SiteHistoryEntry value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SiteHistoryEntry() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SiteHistoryEntry value)  $default,){
final _that = this;
switch (_that) {
case _SiteHistoryEntry():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SiteHistoryEntry value)?  $default,){
final _that = this;
switch (_that) {
case _SiteHistoryEntry() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String inspectionId,  String templateName,  InspectionStatus status,  DateTime? completedAt,  double? passPercentage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SiteHistoryEntry() when $default != null:
return $default(_that.inspectionId,_that.templateName,_that.status,_that.completedAt,_that.passPercentage);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String inspectionId,  String templateName,  InspectionStatus status,  DateTime? completedAt,  double? passPercentage)  $default,) {final _that = this;
switch (_that) {
case _SiteHistoryEntry():
return $default(_that.inspectionId,_that.templateName,_that.status,_that.completedAt,_that.passPercentage);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String inspectionId,  String templateName,  InspectionStatus status,  DateTime? completedAt,  double? passPercentage)?  $default,) {final _that = this;
switch (_that) {
case _SiteHistoryEntry() when $default != null:
return $default(_that.inspectionId,_that.templateName,_that.status,_that.completedAt,_that.passPercentage);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SiteHistoryEntry implements SiteHistoryEntry {
  const _SiteHistoryEntry({required this.inspectionId, required this.templateName, required this.status, this.completedAt, this.passPercentage});
  factory _SiteHistoryEntry.fromJson(Map<String, dynamic> json) => _$SiteHistoryEntryFromJson(json);

@override final  String inspectionId;
@override final  String templateName;
@override final  InspectionStatus status;
@override final  DateTime? completedAt;
@override final  double? passPercentage;

/// Create a copy of SiteHistoryEntry
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SiteHistoryEntryCopyWith<_SiteHistoryEntry> get copyWith => __$SiteHistoryEntryCopyWithImpl<_SiteHistoryEntry>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SiteHistoryEntryToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SiteHistoryEntry&&(identical(other.inspectionId, inspectionId) || other.inspectionId == inspectionId)&&(identical(other.templateName, templateName) || other.templateName == templateName)&&(identical(other.status, status) || other.status == status)&&(identical(other.completedAt, completedAt) || other.completedAt == completedAt)&&(identical(other.passPercentage, passPercentage) || other.passPercentage == passPercentage));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,inspectionId,templateName,status,completedAt,passPercentage);
}

@override
String toString() {
    return 'SiteHistoryEntry(inspectionId: $inspectionId, templateName: $templateName, status: $status, completedAt: $completedAt, passPercentage: $passPercentage)';
}


}

/// @nodoc
abstract mixin class _$SiteHistoryEntryCopyWith<$Res> implements $SiteHistoryEntryCopyWith<$Res> {
  factory _$SiteHistoryEntryCopyWith(_SiteHistoryEntry value, $Res Function(_SiteHistoryEntry) _then) = __$SiteHistoryEntryCopyWithImpl;
@override @useResult
$Res call({
 String inspectionId, String templateName, InspectionStatus status, DateTime? completedAt, double? passPercentage
});




}
/// @nodoc
class __$SiteHistoryEntryCopyWithImpl<$Res>
    implements _$SiteHistoryEntryCopyWith<$Res> {
  __$SiteHistoryEntryCopyWithImpl(this._self, this._then);

  final _SiteHistoryEntry _self;
  final $Res Function(_SiteHistoryEntry) _then;

/// Create a copy of SiteHistoryEntry
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? inspectionId = null,Object? templateName = null,Object? status = null,Object? completedAt = freezed,Object? passPercentage = freezed,}) {
  return _then(_SiteHistoryEntry(
inspectionId: null == inspectionId ? _self.inspectionId : inspectionId // ignore: cast_nullable_to_non_nullable
as String,templateName: null == templateName ? _self.templateName : templateName // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as InspectionStatus,completedAt: freezed == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,passPercentage: freezed == passPercentage ? _self.passPercentage : passPercentage // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}


}


/// @nodoc
mixin _$ComparisonEntry {

 String get templateChecklistItemId; String get label; ComparisonState get state; String? get previousFindingId; String? get previousDescription; DateTime? get previousDate; String? get currentFindingId; String? get currentDescription; DateTime? get currentDate;
/// Create a copy of ComparisonEntry
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ComparisonEntryCopyWith<ComparisonEntry> get copyWith => _$ComparisonEntryCopyWithImpl<ComparisonEntry>(this as ComparisonEntry, _$identity);

  /// Serializes this ComparisonEntry to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ComparisonEntry;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ComparisonEntry&&(identical(other.templateChecklistItemId, _this.templateChecklistItemId) || other.templateChecklistItemId == _this.templateChecklistItemId)&&(identical(other.label, _this.label) || other.label == _this.label)&&(identical(other.state, _this.state) || other.state == _this.state)&&(identical(other.previousFindingId, _this.previousFindingId) || other.previousFindingId == _this.previousFindingId)&&(identical(other.previousDescription, _this.previousDescription) || other.previousDescription == _this.previousDescription)&&(identical(other.previousDate, _this.previousDate) || other.previousDate == _this.previousDate)&&(identical(other.currentFindingId, _this.currentFindingId) || other.currentFindingId == _this.currentFindingId)&&(identical(other.currentDescription, _this.currentDescription) || other.currentDescription == _this.currentDescription)&&(identical(other.currentDate, _this.currentDate) || other.currentDate == _this.currentDate));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ComparisonEntry;
  return Object.hash(runtimeType,_this.templateChecklistItemId,_this.label,_this.state,_this.previousFindingId,_this.previousDescription,_this.previousDate,_this.currentFindingId,_this.currentDescription,_this.currentDate);
}

@override
String toString() {
  final _this = this as ComparisonEntry;
  return 'ComparisonEntry(templateChecklistItemId: ${_this.templateChecklistItemId}, label: ${_this.label}, state: ${_this.state}, previousFindingId: ${_this.previousFindingId}, previousDescription: ${_this.previousDescription}, previousDate: ${_this.previousDate}, currentFindingId: ${_this.currentFindingId}, currentDescription: ${_this.currentDescription}, currentDate: ${_this.currentDate})';
}


}

/// @nodoc
abstract mixin class $ComparisonEntryCopyWith<$Res>  {
  factory $ComparisonEntryCopyWith(ComparisonEntry value, $Res Function(ComparisonEntry) _then) = _$ComparisonEntryCopyWithImpl;
@useResult
$Res call({
 String templateChecklistItemId, String label, ComparisonState state, String? previousFindingId, String? previousDescription, DateTime? previousDate, String? currentFindingId, String? currentDescription, DateTime? currentDate
});




}
/// @nodoc
class _$ComparisonEntryCopyWithImpl<$Res>
    implements $ComparisonEntryCopyWith<$Res> {
  _$ComparisonEntryCopyWithImpl(this._self, this._then);

  final ComparisonEntry _self;
  final $Res Function(ComparisonEntry) _then;

/// Create a copy of ComparisonEntry
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? templateChecklistItemId = null,Object? label = null,Object? state = null,Object? previousFindingId = freezed,Object? previousDescription = freezed,Object? previousDate = freezed,Object? currentFindingId = freezed,Object? currentDescription = freezed,Object? currentDate = freezed,}) {
  return _then(ComparisonEntry(
templateChecklistItemId: null == templateChecklistItemId ? _self.templateChecklistItemId : templateChecklistItemId // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as ComparisonState,previousFindingId: freezed == previousFindingId ? _self.previousFindingId : previousFindingId // ignore: cast_nullable_to_non_nullable
as String?,previousDescription: freezed == previousDescription ? _self.previousDescription : previousDescription // ignore: cast_nullable_to_non_nullable
as String?,previousDate: freezed == previousDate ? _self.previousDate : previousDate // ignore: cast_nullable_to_non_nullable
as DateTime?,currentFindingId: freezed == currentFindingId ? _self.currentFindingId : currentFindingId // ignore: cast_nullable_to_non_nullable
as String?,currentDescription: freezed == currentDescription ? _self.currentDescription : currentDescription // ignore: cast_nullable_to_non_nullable
as String?,currentDate: freezed == currentDate ? _self.currentDate : currentDate // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [ComparisonEntry].
extension ComparisonEntryPatterns on ComparisonEntry {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ComparisonEntry value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ComparisonEntry() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ComparisonEntry value)  $default,){
final _that = this;
switch (_that) {
case _ComparisonEntry():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ComparisonEntry value)?  $default,){
final _that = this;
switch (_that) {
case _ComparisonEntry() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String templateChecklistItemId,  String label,  ComparisonState state,  String? previousFindingId,  String? previousDescription,  DateTime? previousDate,  String? currentFindingId,  String? currentDescription,  DateTime? currentDate)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ComparisonEntry() when $default != null:
return $default(_that.templateChecklistItemId,_that.label,_that.state,_that.previousFindingId,_that.previousDescription,_that.previousDate,_that.currentFindingId,_that.currentDescription,_that.currentDate);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String templateChecklistItemId,  String label,  ComparisonState state,  String? previousFindingId,  String? previousDescription,  DateTime? previousDate,  String? currentFindingId,  String? currentDescription,  DateTime? currentDate)  $default,) {final _that = this;
switch (_that) {
case _ComparisonEntry():
return $default(_that.templateChecklistItemId,_that.label,_that.state,_that.previousFindingId,_that.previousDescription,_that.previousDate,_that.currentFindingId,_that.currentDescription,_that.currentDate);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String templateChecklistItemId,  String label,  ComparisonState state,  String? previousFindingId,  String? previousDescription,  DateTime? previousDate,  String? currentFindingId,  String? currentDescription,  DateTime? currentDate)?  $default,) {final _that = this;
switch (_that) {
case _ComparisonEntry() when $default != null:
return $default(_that.templateChecklistItemId,_that.label,_that.state,_that.previousFindingId,_that.previousDescription,_that.previousDate,_that.currentFindingId,_that.currentDescription,_that.currentDate);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ComparisonEntry implements ComparisonEntry {
  const _ComparisonEntry({required this.templateChecklistItemId, required this.label, required this.state, this.previousFindingId, this.previousDescription, this.previousDate, this.currentFindingId, this.currentDescription, this.currentDate});
  factory _ComparisonEntry.fromJson(Map<String, dynamic> json) => _$ComparisonEntryFromJson(json);

@override final  String templateChecklistItemId;
@override final  String label;
@override final  ComparisonState state;
@override final  String? previousFindingId;
@override final  String? previousDescription;
@override final  DateTime? previousDate;
@override final  String? currentFindingId;
@override final  String? currentDescription;
@override final  DateTime? currentDate;

/// Create a copy of ComparisonEntry
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ComparisonEntryCopyWith<_ComparisonEntry> get copyWith => __$ComparisonEntryCopyWithImpl<_ComparisonEntry>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ComparisonEntryToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ComparisonEntry&&(identical(other.templateChecklistItemId, templateChecklistItemId) || other.templateChecklistItemId == templateChecklistItemId)&&(identical(other.label, label) || other.label == label)&&(identical(other.state, state) || other.state == state)&&(identical(other.previousFindingId, previousFindingId) || other.previousFindingId == previousFindingId)&&(identical(other.previousDescription, previousDescription) || other.previousDescription == previousDescription)&&(identical(other.previousDate, previousDate) || other.previousDate == previousDate)&&(identical(other.currentFindingId, currentFindingId) || other.currentFindingId == currentFindingId)&&(identical(other.currentDescription, currentDescription) || other.currentDescription == currentDescription)&&(identical(other.currentDate, currentDate) || other.currentDate == currentDate));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,templateChecklistItemId,label,state,previousFindingId,previousDescription,previousDate,currentFindingId,currentDescription,currentDate);
}

@override
String toString() {
    return 'ComparisonEntry(templateChecklistItemId: $templateChecklistItemId, label: $label, state: $state, previousFindingId: $previousFindingId, previousDescription: $previousDescription, previousDate: $previousDate, currentFindingId: $currentFindingId, currentDescription: $currentDescription, currentDate: $currentDate)';
}


}

/// @nodoc
abstract mixin class _$ComparisonEntryCopyWith<$Res> implements $ComparisonEntryCopyWith<$Res> {
  factory _$ComparisonEntryCopyWith(_ComparisonEntry value, $Res Function(_ComparisonEntry) _then) = __$ComparisonEntryCopyWithImpl;
@override @useResult
$Res call({
 String templateChecklistItemId, String label, ComparisonState state, String? previousFindingId, String? previousDescription, DateTime? previousDate, String? currentFindingId, String? currentDescription, DateTime? currentDate
});




}
/// @nodoc
class __$ComparisonEntryCopyWithImpl<$Res>
    implements _$ComparisonEntryCopyWith<$Res> {
  __$ComparisonEntryCopyWithImpl(this._self, this._then);

  final _ComparisonEntry _self;
  final $Res Function(_ComparisonEntry) _then;

/// Create a copy of ComparisonEntry
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? templateChecklistItemId = null,Object? label = null,Object? state = null,Object? previousFindingId = freezed,Object? previousDescription = freezed,Object? previousDate = freezed,Object? currentFindingId = freezed,Object? currentDescription = freezed,Object? currentDate = freezed,}) {
  return _then(_ComparisonEntry(
templateChecklistItemId: null == templateChecklistItemId ? _self.templateChecklistItemId : templateChecklistItemId // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as ComparisonState,previousFindingId: freezed == previousFindingId ? _self.previousFindingId : previousFindingId // ignore: cast_nullable_to_non_nullable
as String?,previousDescription: freezed == previousDescription ? _self.previousDescription : previousDescription // ignore: cast_nullable_to_non_nullable
as String?,previousDate: freezed == previousDate ? _self.previousDate : previousDate // ignore: cast_nullable_to_non_nullable
as DateTime?,currentFindingId: freezed == currentFindingId ? _self.currentFindingId : currentFindingId // ignore: cast_nullable_to_non_nullable
as String?,currentDescription: freezed == currentDescription ? _self.currentDescription : currentDescription // ignore: cast_nullable_to_non_nullable
as String?,currentDate: freezed == currentDate ? _self.currentDate : currentDate // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$SiteComparisonResult {

 String get siteId; String get previousInspectionId; DateTime get previousDate; String get currentInspectionId; DateTime get currentDate; List<ComparisonEntry> get entries;
/// Create a copy of SiteComparisonResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SiteComparisonResultCopyWith<SiteComparisonResult> get copyWith => _$SiteComparisonResultCopyWithImpl<SiteComparisonResult>(this as SiteComparisonResult, _$identity);

  /// Serializes this SiteComparisonResult to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as SiteComparisonResult;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SiteComparisonResult&&(identical(other.siteId, _this.siteId) || other.siteId == _this.siteId)&&(identical(other.previousInspectionId, _this.previousInspectionId) || other.previousInspectionId == _this.previousInspectionId)&&(identical(other.previousDate, _this.previousDate) || other.previousDate == _this.previousDate)&&(identical(other.currentInspectionId, _this.currentInspectionId) || other.currentInspectionId == _this.currentInspectionId)&&(identical(other.currentDate, _this.currentDate) || other.currentDate == _this.currentDate)&&const DeepCollectionEquality().equals(other.entries, _this.entries));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as SiteComparisonResult;
  return Object.hash(runtimeType,_this.siteId,_this.previousInspectionId,_this.previousDate,_this.currentInspectionId,_this.currentDate,const DeepCollectionEquality().hash(_this.entries));
}

@override
String toString() {
  final _this = this as SiteComparisonResult;
  return 'SiteComparisonResult(siteId: ${_this.siteId}, previousInspectionId: ${_this.previousInspectionId}, previousDate: ${_this.previousDate}, currentInspectionId: ${_this.currentInspectionId}, currentDate: ${_this.currentDate}, entries: ${_this.entries})';
}


}

/// @nodoc
abstract mixin class $SiteComparisonResultCopyWith<$Res>  {
  factory $SiteComparisonResultCopyWith(SiteComparisonResult value, $Res Function(SiteComparisonResult) _then) = _$SiteComparisonResultCopyWithImpl;
@useResult
$Res call({
 String siteId, String previousInspectionId, DateTime previousDate, String currentInspectionId, DateTime currentDate, List<ComparisonEntry> entries
});




}
/// @nodoc
class _$SiteComparisonResultCopyWithImpl<$Res>
    implements $SiteComparisonResultCopyWith<$Res> {
  _$SiteComparisonResultCopyWithImpl(this._self, this._then);

  final SiteComparisonResult _self;
  final $Res Function(SiteComparisonResult) _then;

/// Create a copy of SiteComparisonResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? siteId = null,Object? previousInspectionId = null,Object? previousDate = null,Object? currentInspectionId = null,Object? currentDate = null,Object? entries = null,}) {
  return _then(SiteComparisonResult(
siteId: null == siteId ? _self.siteId : siteId // ignore: cast_nullable_to_non_nullable
as String,previousInspectionId: null == previousInspectionId ? _self.previousInspectionId : previousInspectionId // ignore: cast_nullable_to_non_nullable
as String,previousDate: null == previousDate ? _self.previousDate : previousDate // ignore: cast_nullable_to_non_nullable
as DateTime,currentInspectionId: null == currentInspectionId ? _self.currentInspectionId : currentInspectionId // ignore: cast_nullable_to_non_nullable
as String,currentDate: null == currentDate ? _self.currentDate : currentDate // ignore: cast_nullable_to_non_nullable
as DateTime,entries: null == entries ? _self.entries : entries // ignore: cast_nullable_to_non_nullable
as List<ComparisonEntry>,
  ));
}

}


/// Adds pattern-matching-related methods to [SiteComparisonResult].
extension SiteComparisonResultPatterns on SiteComparisonResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SiteComparisonResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SiteComparisonResult() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SiteComparisonResult value)  $default,){
final _that = this;
switch (_that) {
case _SiteComparisonResult():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SiteComparisonResult value)?  $default,){
final _that = this;
switch (_that) {
case _SiteComparisonResult() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String siteId,  String previousInspectionId,  DateTime previousDate,  String currentInspectionId,  DateTime currentDate,  List<ComparisonEntry> entries)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SiteComparisonResult() when $default != null:
return $default(_that.siteId,_that.previousInspectionId,_that.previousDate,_that.currentInspectionId,_that.currentDate,_that.entries);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String siteId,  String previousInspectionId,  DateTime previousDate,  String currentInspectionId,  DateTime currentDate,  List<ComparisonEntry> entries)  $default,) {final _that = this;
switch (_that) {
case _SiteComparisonResult():
return $default(_that.siteId,_that.previousInspectionId,_that.previousDate,_that.currentInspectionId,_that.currentDate,_that.entries);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String siteId,  String previousInspectionId,  DateTime previousDate,  String currentInspectionId,  DateTime currentDate,  List<ComparisonEntry> entries)?  $default,) {final _that = this;
switch (_that) {
case _SiteComparisonResult() when $default != null:
return $default(_that.siteId,_that.previousInspectionId,_that.previousDate,_that.currentInspectionId,_that.currentDate,_that.entries);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SiteComparisonResult implements SiteComparisonResult {
  const _SiteComparisonResult({required this.siteId, required this.previousInspectionId, required this.previousDate, required this.currentInspectionId, required this.currentDate,  List<ComparisonEntry> entries = const <ComparisonEntry>[]}): _entries = entries;
  factory _SiteComparisonResult.fromJson(Map<String, dynamic> json) => _$SiteComparisonResultFromJson(json);

@override final  String siteId;
@override final  String previousInspectionId;
@override final  DateTime previousDate;
@override final  String currentInspectionId;
@override final  DateTime currentDate;
 final  List<ComparisonEntry> _entries;
@override@JsonKey() List<ComparisonEntry> get entries {
  if (_entries is EqualUnmodifiableListView) return _entries;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_entries);
}


/// Create a copy of SiteComparisonResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SiteComparisonResultCopyWith<_SiteComparisonResult> get copyWith => __$SiteComparisonResultCopyWithImpl<_SiteComparisonResult>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SiteComparisonResultToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SiteComparisonResult&&(identical(other.siteId, siteId) || other.siteId == siteId)&&(identical(other.previousInspectionId, previousInspectionId) || other.previousInspectionId == previousInspectionId)&&(identical(other.previousDate, previousDate) || other.previousDate == previousDate)&&(identical(other.currentInspectionId, currentInspectionId) || other.currentInspectionId == currentInspectionId)&&(identical(other.currentDate, currentDate) || other.currentDate == currentDate)&&const DeepCollectionEquality().equals(other.entries, _entries));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,siteId,previousInspectionId,previousDate,currentInspectionId,currentDate,const DeepCollectionEquality().hash(_entries));
}

@override
String toString() {
    return 'SiteComparisonResult(siteId: $siteId, previousInspectionId: $previousInspectionId, previousDate: $previousDate, currentInspectionId: $currentInspectionId, currentDate: $currentDate, entries: $entries)';
}


}

/// @nodoc
abstract mixin class _$SiteComparisonResultCopyWith<$Res> implements $SiteComparisonResultCopyWith<$Res> {
  factory _$SiteComparisonResultCopyWith(_SiteComparisonResult value, $Res Function(_SiteComparisonResult) _then) = __$SiteComparisonResultCopyWithImpl;
@override @useResult
$Res call({
 String siteId, String previousInspectionId, DateTime previousDate, String currentInspectionId, DateTime currentDate, List<ComparisonEntry> entries
});




}
/// @nodoc
class __$SiteComparisonResultCopyWithImpl<$Res>
    implements _$SiteComparisonResultCopyWith<$Res> {
  __$SiteComparisonResultCopyWithImpl(this._self, this._then);

  final _SiteComparisonResult _self;
  final $Res Function(_SiteComparisonResult) _then;

/// Create a copy of SiteComparisonResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? siteId = null,Object? previousInspectionId = null,Object? previousDate = null,Object? currentInspectionId = null,Object? currentDate = null,Object? entries = null,}) {
  return _then(_SiteComparisonResult(
siteId: null == siteId ? _self.siteId : siteId // ignore: cast_nullable_to_non_nullable
as String,previousInspectionId: null == previousInspectionId ? _self.previousInspectionId : previousInspectionId // ignore: cast_nullable_to_non_nullable
as String,previousDate: null == previousDate ? _self.previousDate : previousDate // ignore: cast_nullable_to_non_nullable
as DateTime,currentInspectionId: null == currentInspectionId ? _self.currentInspectionId : currentInspectionId // ignore: cast_nullable_to_non_nullable
as String,currentDate: null == currentDate ? _self.currentDate : currentDate // ignore: cast_nullable_to_non_nullable
as DateTime,entries: null == entries ? _self._entries : entries // ignore: cast_nullable_to_non_nullable
as List<ComparisonEntry>,
  ));
}


}

// dart format on
