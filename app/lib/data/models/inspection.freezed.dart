// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'inspection.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Inspection {

 String get id; String get templateId; String get templateName; String get customerId; String get customerName; String get siteId; String get siteName; String? get siteAddress; String? get siteCoverImageUrl; String get inspectorId; String get inspectorName; String? get inspectorAvatarUrl; InspectionStatus get status; DateTime? get scheduledAt; DateTime? get startedAt; DateTime? get completedAt; RecurrenceType get recurrence; DateTime? get nextDueAt; double? get locationLat; double? get locationLng; DateTime? get locationCapturedAt; double? get passPercentage; List<InspectionItem> get items; List<Finding> get findings; List<InspectionSignature> get signatures;@JsonKey(includeFromJson: false, includeToJson: false) SyncState get syncState;
/// Create a copy of Inspection
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InspectionCopyWith<Inspection> get copyWith => _$InspectionCopyWithImpl<Inspection>(this as Inspection, _$identity);

  /// Serializes this Inspection to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Inspection;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Inspection&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.templateId, _this.templateId) || other.templateId == _this.templateId)&&(identical(other.templateName, _this.templateName) || other.templateName == _this.templateName)&&(identical(other.customerId, _this.customerId) || other.customerId == _this.customerId)&&(identical(other.customerName, _this.customerName) || other.customerName == _this.customerName)&&(identical(other.siteId, _this.siteId) || other.siteId == _this.siteId)&&(identical(other.siteName, _this.siteName) || other.siteName == _this.siteName)&&(identical(other.siteAddress, _this.siteAddress) || other.siteAddress == _this.siteAddress)&&(identical(other.siteCoverImageUrl, _this.siteCoverImageUrl) || other.siteCoverImageUrl == _this.siteCoverImageUrl)&&(identical(other.inspectorId, _this.inspectorId) || other.inspectorId == _this.inspectorId)&&(identical(other.inspectorName, _this.inspectorName) || other.inspectorName == _this.inspectorName)&&(identical(other.inspectorAvatarUrl, _this.inspectorAvatarUrl) || other.inspectorAvatarUrl == _this.inspectorAvatarUrl)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.scheduledAt, _this.scheduledAt) || other.scheduledAt == _this.scheduledAt)&&(identical(other.startedAt, _this.startedAt) || other.startedAt == _this.startedAt)&&(identical(other.completedAt, _this.completedAt) || other.completedAt == _this.completedAt)&&(identical(other.recurrence, _this.recurrence) || other.recurrence == _this.recurrence)&&(identical(other.nextDueAt, _this.nextDueAt) || other.nextDueAt == _this.nextDueAt)&&(identical(other.locationLat, _this.locationLat) || other.locationLat == _this.locationLat)&&(identical(other.locationLng, _this.locationLng) || other.locationLng == _this.locationLng)&&(identical(other.locationCapturedAt, _this.locationCapturedAt) || other.locationCapturedAt == _this.locationCapturedAt)&&(identical(other.passPercentage, _this.passPercentage) || other.passPercentage == _this.passPercentage)&&const DeepCollectionEquality().equals(other.items, _this.items)&&const DeepCollectionEquality().equals(other.findings, _this.findings)&&const DeepCollectionEquality().equals(other.signatures, _this.signatures)&&(identical(other.syncState, _this.syncState) || other.syncState == _this.syncState));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Inspection;
  return Object.hashAll([runtimeType,_this.id,_this.templateId,_this.templateName,_this.customerId,_this.customerName,_this.siteId,_this.siteName,_this.siteAddress,_this.siteCoverImageUrl,_this.inspectorId,_this.inspectorName,_this.inspectorAvatarUrl,_this.status,_this.scheduledAt,_this.startedAt,_this.completedAt,_this.recurrence,_this.nextDueAt,_this.locationLat,_this.locationLng,_this.locationCapturedAt,_this.passPercentage,const DeepCollectionEquality().hash(_this.items),const DeepCollectionEquality().hash(_this.findings),const DeepCollectionEquality().hash(_this.signatures),_this.syncState]);
}

@override
String toString() {
  final _this = this as Inspection;
  return 'Inspection(id: ${_this.id}, templateId: ${_this.templateId}, templateName: ${_this.templateName}, customerId: ${_this.customerId}, customerName: ${_this.customerName}, siteId: ${_this.siteId}, siteName: ${_this.siteName}, siteAddress: ${_this.siteAddress}, siteCoverImageUrl: ${_this.siteCoverImageUrl}, inspectorId: ${_this.inspectorId}, inspectorName: ${_this.inspectorName}, inspectorAvatarUrl: ${_this.inspectorAvatarUrl}, status: ${_this.status}, scheduledAt: ${_this.scheduledAt}, startedAt: ${_this.startedAt}, completedAt: ${_this.completedAt}, recurrence: ${_this.recurrence}, nextDueAt: ${_this.nextDueAt}, locationLat: ${_this.locationLat}, locationLng: ${_this.locationLng}, locationCapturedAt: ${_this.locationCapturedAt}, passPercentage: ${_this.passPercentage}, items: ${_this.items}, findings: ${_this.findings}, signatures: ${_this.signatures}, syncState: ${_this.syncState})';
}


}

/// @nodoc
abstract mixin class $InspectionCopyWith<$Res>  {
  factory $InspectionCopyWith(Inspection value, $Res Function(Inspection) _then) = _$InspectionCopyWithImpl;
@useResult
$Res call({
 String id, String templateId, String templateName, String customerId, String customerName, String siteId, String siteName, String? siteAddress, String? siteCoverImageUrl, String inspectorId, String inspectorName, String? inspectorAvatarUrl, InspectionStatus status, DateTime? scheduledAt, DateTime? startedAt, DateTime? completedAt, RecurrenceType recurrence, DateTime? nextDueAt, double? locationLat, double? locationLng, DateTime? locationCapturedAt, double? passPercentage, List<InspectionItem> items, List<Finding> findings, List<InspectionSignature> signatures,@JsonKey(includeFromJson: false, includeToJson: false) SyncState syncState
});




}
/// @nodoc
class _$InspectionCopyWithImpl<$Res>
    implements $InspectionCopyWith<$Res> {
  _$InspectionCopyWithImpl(this._self, this._then);

  final Inspection _self;
  final $Res Function(Inspection) _then;

/// Create a copy of Inspection
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? templateId = null,Object? templateName = null,Object? customerId = null,Object? customerName = null,Object? siteId = null,Object? siteName = null,Object? siteAddress = freezed,Object? siteCoverImageUrl = freezed,Object? inspectorId = null,Object? inspectorName = null,Object? inspectorAvatarUrl = freezed,Object? status = null,Object? scheduledAt = freezed,Object? startedAt = freezed,Object? completedAt = freezed,Object? recurrence = null,Object? nextDueAt = freezed,Object? locationLat = freezed,Object? locationLng = freezed,Object? locationCapturedAt = freezed,Object? passPercentage = freezed,Object? items = null,Object? findings = null,Object? signatures = null,Object? syncState = null,}) {
  return _then(Inspection(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,templateId: null == templateId ? _self.templateId : templateId // ignore: cast_nullable_to_non_nullable
as String,templateName: null == templateName ? _self.templateName : templateName // ignore: cast_nullable_to_non_nullable
as String,customerId: null == customerId ? _self.customerId : customerId // ignore: cast_nullable_to_non_nullable
as String,customerName: null == customerName ? _self.customerName : customerName // ignore: cast_nullable_to_non_nullable
as String,siteId: null == siteId ? _self.siteId : siteId // ignore: cast_nullable_to_non_nullable
as String,siteName: null == siteName ? _self.siteName : siteName // ignore: cast_nullable_to_non_nullable
as String,siteAddress: freezed == siteAddress ? _self.siteAddress : siteAddress // ignore: cast_nullable_to_non_nullable
as String?,siteCoverImageUrl: freezed == siteCoverImageUrl ? _self.siteCoverImageUrl : siteCoverImageUrl // ignore: cast_nullable_to_non_nullable
as String?,inspectorId: null == inspectorId ? _self.inspectorId : inspectorId // ignore: cast_nullable_to_non_nullable
as String,inspectorName: null == inspectorName ? _self.inspectorName : inspectorName // ignore: cast_nullable_to_non_nullable
as String,inspectorAvatarUrl: freezed == inspectorAvatarUrl ? _self.inspectorAvatarUrl : inspectorAvatarUrl // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as InspectionStatus,scheduledAt: freezed == scheduledAt ? _self.scheduledAt : scheduledAt // ignore: cast_nullable_to_non_nullable
as DateTime?,startedAt: freezed == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,completedAt: freezed == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,recurrence: null == recurrence ? _self.recurrence : recurrence // ignore: cast_nullable_to_non_nullable
as RecurrenceType,nextDueAt: freezed == nextDueAt ? _self.nextDueAt : nextDueAt // ignore: cast_nullable_to_non_nullable
as DateTime?,locationLat: freezed == locationLat ? _self.locationLat : locationLat // ignore: cast_nullable_to_non_nullable
as double?,locationLng: freezed == locationLng ? _self.locationLng : locationLng // ignore: cast_nullable_to_non_nullable
as double?,locationCapturedAt: freezed == locationCapturedAt ? _self.locationCapturedAt : locationCapturedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,passPercentage: freezed == passPercentage ? _self.passPercentage : passPercentage // ignore: cast_nullable_to_non_nullable
as double?,items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<InspectionItem>,findings: null == findings ? _self.findings : findings // ignore: cast_nullable_to_non_nullable
as List<Finding>,signatures: null == signatures ? _self.signatures : signatures // ignore: cast_nullable_to_non_nullable
as List<InspectionSignature>,syncState: null == syncState ? _self.syncState : syncState // ignore: cast_nullable_to_non_nullable
as SyncState,
  ));
}

}


/// Adds pattern-matching-related methods to [Inspection].
extension InspectionPatterns on Inspection {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Inspection value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Inspection() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Inspection value)  $default,){
final _that = this;
switch (_that) {
case _Inspection():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Inspection value)?  $default,){
final _that = this;
switch (_that) {
case _Inspection() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String templateId,  String templateName,  String customerId,  String customerName,  String siteId,  String siteName,  String? siteAddress,  String? siteCoverImageUrl,  String inspectorId,  String inspectorName,  String? inspectorAvatarUrl,  InspectionStatus status,  DateTime? scheduledAt,  DateTime? startedAt,  DateTime? completedAt,  RecurrenceType recurrence,  DateTime? nextDueAt,  double? locationLat,  double? locationLng,  DateTime? locationCapturedAt,  double? passPercentage,  List<InspectionItem> items,  List<Finding> findings,  List<InspectionSignature> signatures, @JsonKey(includeFromJson: false, includeToJson: false)  SyncState syncState)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Inspection() when $default != null:
return $default(_that.id,_that.templateId,_that.templateName,_that.customerId,_that.customerName,_that.siteId,_that.siteName,_that.siteAddress,_that.siteCoverImageUrl,_that.inspectorId,_that.inspectorName,_that.inspectorAvatarUrl,_that.status,_that.scheduledAt,_that.startedAt,_that.completedAt,_that.recurrence,_that.nextDueAt,_that.locationLat,_that.locationLng,_that.locationCapturedAt,_that.passPercentage,_that.items,_that.findings,_that.signatures,_that.syncState);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String templateId,  String templateName,  String customerId,  String customerName,  String siteId,  String siteName,  String? siteAddress,  String? siteCoverImageUrl,  String inspectorId,  String inspectorName,  String? inspectorAvatarUrl,  InspectionStatus status,  DateTime? scheduledAt,  DateTime? startedAt,  DateTime? completedAt,  RecurrenceType recurrence,  DateTime? nextDueAt,  double? locationLat,  double? locationLng,  DateTime? locationCapturedAt,  double? passPercentage,  List<InspectionItem> items,  List<Finding> findings,  List<InspectionSignature> signatures, @JsonKey(includeFromJson: false, includeToJson: false)  SyncState syncState)  $default,) {final _that = this;
switch (_that) {
case _Inspection():
return $default(_that.id,_that.templateId,_that.templateName,_that.customerId,_that.customerName,_that.siteId,_that.siteName,_that.siteAddress,_that.siteCoverImageUrl,_that.inspectorId,_that.inspectorName,_that.inspectorAvatarUrl,_that.status,_that.scheduledAt,_that.startedAt,_that.completedAt,_that.recurrence,_that.nextDueAt,_that.locationLat,_that.locationLng,_that.locationCapturedAt,_that.passPercentage,_that.items,_that.findings,_that.signatures,_that.syncState);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String templateId,  String templateName,  String customerId,  String customerName,  String siteId,  String siteName,  String? siteAddress,  String? siteCoverImageUrl,  String inspectorId,  String inspectorName,  String? inspectorAvatarUrl,  InspectionStatus status,  DateTime? scheduledAt,  DateTime? startedAt,  DateTime? completedAt,  RecurrenceType recurrence,  DateTime? nextDueAt,  double? locationLat,  double? locationLng,  DateTime? locationCapturedAt,  double? passPercentage,  List<InspectionItem> items,  List<Finding> findings,  List<InspectionSignature> signatures, @JsonKey(includeFromJson: false, includeToJson: false)  SyncState syncState)?  $default,) {final _that = this;
switch (_that) {
case _Inspection() when $default != null:
return $default(_that.id,_that.templateId,_that.templateName,_that.customerId,_that.customerName,_that.siteId,_that.siteName,_that.siteAddress,_that.siteCoverImageUrl,_that.inspectorId,_that.inspectorName,_that.inspectorAvatarUrl,_that.status,_that.scheduledAt,_that.startedAt,_that.completedAt,_that.recurrence,_that.nextDueAt,_that.locationLat,_that.locationLng,_that.locationCapturedAt,_that.passPercentage,_that.items,_that.findings,_that.signatures,_that.syncState);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Inspection extends Inspection {
  const _Inspection({required this.id, required this.templateId, required this.templateName, required this.customerId, required this.customerName, required this.siteId, required this.siteName, this.siteAddress, this.siteCoverImageUrl, required this.inspectorId, required this.inspectorName, this.inspectorAvatarUrl, required this.status, this.scheduledAt, this.startedAt, this.completedAt, this.recurrence = RecurrenceType.oneTime, this.nextDueAt, this.locationLat, this.locationLng, this.locationCapturedAt, this.passPercentage,  List<InspectionItem> items = const <InspectionItem>[],  List<Finding> findings = const <Finding>[],  List<InspectionSignature> signatures = const <InspectionSignature>[], @JsonKey(includeFromJson: false, includeToJson: false) this.syncState = SyncState.synced}): _items = items,_findings = findings,_signatures = signatures,super._();
  factory _Inspection.fromJson(Map<String, dynamic> json) => _$InspectionFromJson(json);

@override final  String id;
@override final  String templateId;
@override final  String templateName;
@override final  String customerId;
@override final  String customerName;
@override final  String siteId;
@override final  String siteName;
@override final  String? siteAddress;
@override final  String? siteCoverImageUrl;
@override final  String inspectorId;
@override final  String inspectorName;
@override final  String? inspectorAvatarUrl;
@override final  InspectionStatus status;
@override final  DateTime? scheduledAt;
@override final  DateTime? startedAt;
@override final  DateTime? completedAt;
@override@JsonKey() final  RecurrenceType recurrence;
@override final  DateTime? nextDueAt;
@override final  double? locationLat;
@override final  double? locationLng;
@override final  DateTime? locationCapturedAt;
@override final  double? passPercentage;
 final  List<InspectionItem> _items;
@override@JsonKey() List<InspectionItem> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

 final  List<Finding> _findings;
@override@JsonKey() List<Finding> get findings {
  if (_findings is EqualUnmodifiableListView) return _findings;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_findings);
}

 final  List<InspectionSignature> _signatures;
@override@JsonKey() List<InspectionSignature> get signatures {
  if (_signatures is EqualUnmodifiableListView) return _signatures;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_signatures);
}

@override@JsonKey(includeFromJson: false, includeToJson: false) final  SyncState syncState;

/// Create a copy of Inspection
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InspectionCopyWith<_Inspection> get copyWith => __$InspectionCopyWithImpl<_Inspection>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$InspectionToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Inspection&&(identical(other.id, id) || other.id == id)&&(identical(other.templateId, templateId) || other.templateId == templateId)&&(identical(other.templateName, templateName) || other.templateName == templateName)&&(identical(other.customerId, customerId) || other.customerId == customerId)&&(identical(other.customerName, customerName) || other.customerName == customerName)&&(identical(other.siteId, siteId) || other.siteId == siteId)&&(identical(other.siteName, siteName) || other.siteName == siteName)&&(identical(other.siteAddress, siteAddress) || other.siteAddress == siteAddress)&&(identical(other.siteCoverImageUrl, siteCoverImageUrl) || other.siteCoverImageUrl == siteCoverImageUrl)&&(identical(other.inspectorId, inspectorId) || other.inspectorId == inspectorId)&&(identical(other.inspectorName, inspectorName) || other.inspectorName == inspectorName)&&(identical(other.inspectorAvatarUrl, inspectorAvatarUrl) || other.inspectorAvatarUrl == inspectorAvatarUrl)&&(identical(other.status, status) || other.status == status)&&(identical(other.scheduledAt, scheduledAt) || other.scheduledAt == scheduledAt)&&(identical(other.startedAt, startedAt) || other.startedAt == startedAt)&&(identical(other.completedAt, completedAt) || other.completedAt == completedAt)&&(identical(other.recurrence, recurrence) || other.recurrence == recurrence)&&(identical(other.nextDueAt, nextDueAt) || other.nextDueAt == nextDueAt)&&(identical(other.locationLat, locationLat) || other.locationLat == locationLat)&&(identical(other.locationLng, locationLng) || other.locationLng == locationLng)&&(identical(other.locationCapturedAt, locationCapturedAt) || other.locationCapturedAt == locationCapturedAt)&&(identical(other.passPercentage, passPercentage) || other.passPercentage == passPercentage)&&const DeepCollectionEquality().equals(other.items, _items)&&const DeepCollectionEquality().equals(other.findings, _findings)&&const DeepCollectionEquality().equals(other.signatures, _signatures)&&(identical(other.syncState, syncState) || other.syncState == syncState));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hashAll([runtimeType,id,templateId,templateName,customerId,customerName,siteId,siteName,siteAddress,siteCoverImageUrl,inspectorId,inspectorName,inspectorAvatarUrl,status,scheduledAt,startedAt,completedAt,recurrence,nextDueAt,locationLat,locationLng,locationCapturedAt,passPercentage,const DeepCollectionEquality().hash(_items),const DeepCollectionEquality().hash(_findings),const DeepCollectionEquality().hash(_signatures),syncState]);
}

@override
String toString() {
    return 'Inspection(id: $id, templateId: $templateId, templateName: $templateName, customerId: $customerId, customerName: $customerName, siteId: $siteId, siteName: $siteName, siteAddress: $siteAddress, siteCoverImageUrl: $siteCoverImageUrl, inspectorId: $inspectorId, inspectorName: $inspectorName, inspectorAvatarUrl: $inspectorAvatarUrl, status: $status, scheduledAt: $scheduledAt, startedAt: $startedAt, completedAt: $completedAt, recurrence: $recurrence, nextDueAt: $nextDueAt, locationLat: $locationLat, locationLng: $locationLng, locationCapturedAt: $locationCapturedAt, passPercentage: $passPercentage, items: $items, findings: $findings, signatures: $signatures, syncState: $syncState)';
}


}

/// @nodoc
abstract mixin class _$InspectionCopyWith<$Res> implements $InspectionCopyWith<$Res> {
  factory _$InspectionCopyWith(_Inspection value, $Res Function(_Inspection) _then) = __$InspectionCopyWithImpl;
@override @useResult
$Res call({
 String id, String templateId, String templateName, String customerId, String customerName, String siteId, String siteName, String? siteAddress, String? siteCoverImageUrl, String inspectorId, String inspectorName, String? inspectorAvatarUrl, InspectionStatus status, DateTime? scheduledAt, DateTime? startedAt, DateTime? completedAt, RecurrenceType recurrence, DateTime? nextDueAt, double? locationLat, double? locationLng, DateTime? locationCapturedAt, double? passPercentage, List<InspectionItem> items, List<Finding> findings, List<InspectionSignature> signatures,@JsonKey(includeFromJson: false, includeToJson: false) SyncState syncState
});




}
/// @nodoc
class __$InspectionCopyWithImpl<$Res>
    implements _$InspectionCopyWith<$Res> {
  __$InspectionCopyWithImpl(this._self, this._then);

  final _Inspection _self;
  final $Res Function(_Inspection) _then;

/// Create a copy of Inspection
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? templateId = null,Object? templateName = null,Object? customerId = null,Object? customerName = null,Object? siteId = null,Object? siteName = null,Object? siteAddress = freezed,Object? siteCoverImageUrl = freezed,Object? inspectorId = null,Object? inspectorName = null,Object? inspectorAvatarUrl = freezed,Object? status = null,Object? scheduledAt = freezed,Object? startedAt = freezed,Object? completedAt = freezed,Object? recurrence = null,Object? nextDueAt = freezed,Object? locationLat = freezed,Object? locationLng = freezed,Object? locationCapturedAt = freezed,Object? passPercentage = freezed,Object? items = null,Object? findings = null,Object? signatures = null,Object? syncState = null,}) {
  return _then(_Inspection(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,templateId: null == templateId ? _self.templateId : templateId // ignore: cast_nullable_to_non_nullable
as String,templateName: null == templateName ? _self.templateName : templateName // ignore: cast_nullable_to_non_nullable
as String,customerId: null == customerId ? _self.customerId : customerId // ignore: cast_nullable_to_non_nullable
as String,customerName: null == customerName ? _self.customerName : customerName // ignore: cast_nullable_to_non_nullable
as String,siteId: null == siteId ? _self.siteId : siteId // ignore: cast_nullable_to_non_nullable
as String,siteName: null == siteName ? _self.siteName : siteName // ignore: cast_nullable_to_non_nullable
as String,siteAddress: freezed == siteAddress ? _self.siteAddress : siteAddress // ignore: cast_nullable_to_non_nullable
as String?,siteCoverImageUrl: freezed == siteCoverImageUrl ? _self.siteCoverImageUrl : siteCoverImageUrl // ignore: cast_nullable_to_non_nullable
as String?,inspectorId: null == inspectorId ? _self.inspectorId : inspectorId // ignore: cast_nullable_to_non_nullable
as String,inspectorName: null == inspectorName ? _self.inspectorName : inspectorName // ignore: cast_nullable_to_non_nullable
as String,inspectorAvatarUrl: freezed == inspectorAvatarUrl ? _self.inspectorAvatarUrl : inspectorAvatarUrl // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as InspectionStatus,scheduledAt: freezed == scheduledAt ? _self.scheduledAt : scheduledAt // ignore: cast_nullable_to_non_nullable
as DateTime?,startedAt: freezed == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,completedAt: freezed == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,recurrence: null == recurrence ? _self.recurrence : recurrence // ignore: cast_nullable_to_non_nullable
as RecurrenceType,nextDueAt: freezed == nextDueAt ? _self.nextDueAt : nextDueAt // ignore: cast_nullable_to_non_nullable
as DateTime?,locationLat: freezed == locationLat ? _self.locationLat : locationLat // ignore: cast_nullable_to_non_nullable
as double?,locationLng: freezed == locationLng ? _self.locationLng : locationLng // ignore: cast_nullable_to_non_nullable
as double?,locationCapturedAt: freezed == locationCapturedAt ? _self.locationCapturedAt : locationCapturedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,passPercentage: freezed == passPercentage ? _self.passPercentage : passPercentage // ignore: cast_nullable_to_non_nullable
as double?,items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<InspectionItem>,findings: null == findings ? _self._findings : findings // ignore: cast_nullable_to_non_nullable
as List<Finding>,signatures: null == signatures ? _self._signatures : signatures // ignore: cast_nullable_to_non_nullable
as List<InspectionSignature>,syncState: null == syncState ? _self.syncState : syncState // ignore: cast_nullable_to_non_nullable
as SyncState,
  ));
}


}

// dart format on
