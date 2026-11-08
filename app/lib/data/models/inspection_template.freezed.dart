// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'inspection_template.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TemplateChecklistItem {

 String get id; String get sectionId; String get label; String? get helpText; bool get requiresEvidence; int get sortOrder;
/// Create a copy of TemplateChecklistItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TemplateChecklistItemCopyWith<TemplateChecklistItem> get copyWith => _$TemplateChecklistItemCopyWithImpl<TemplateChecklistItem>(this as TemplateChecklistItem, _$identity);

  /// Serializes this TemplateChecklistItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as TemplateChecklistItem;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TemplateChecklistItem&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.sectionId, _this.sectionId) || other.sectionId == _this.sectionId)&&(identical(other.label, _this.label) || other.label == _this.label)&&(identical(other.helpText, _this.helpText) || other.helpText == _this.helpText)&&(identical(other.requiresEvidence, _this.requiresEvidence) || other.requiresEvidence == _this.requiresEvidence)&&(identical(other.sortOrder, _this.sortOrder) || other.sortOrder == _this.sortOrder));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as TemplateChecklistItem;
  return Object.hash(runtimeType,_this.id,_this.sectionId,_this.label,_this.helpText,_this.requiresEvidence,_this.sortOrder);
}

@override
String toString() {
  final _this = this as TemplateChecklistItem;
  return 'TemplateChecklistItem(id: ${_this.id}, sectionId: ${_this.sectionId}, label: ${_this.label}, helpText: ${_this.helpText}, requiresEvidence: ${_this.requiresEvidence}, sortOrder: ${_this.sortOrder})';
}


}

/// @nodoc
abstract mixin class $TemplateChecklistItemCopyWith<$Res>  {
  factory $TemplateChecklistItemCopyWith(TemplateChecklistItem value, $Res Function(TemplateChecklistItem) _then) = _$TemplateChecklistItemCopyWithImpl;
@useResult
$Res call({
 String id, String sectionId, String label, String? helpText, bool requiresEvidence, int sortOrder
});




}
/// @nodoc
class _$TemplateChecklistItemCopyWithImpl<$Res>
    implements $TemplateChecklistItemCopyWith<$Res> {
  _$TemplateChecklistItemCopyWithImpl(this._self, this._then);

  final TemplateChecklistItem _self;
  final $Res Function(TemplateChecklistItem) _then;

/// Create a copy of TemplateChecklistItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? sectionId = null,Object? label = null,Object? helpText = freezed,Object? requiresEvidence = null,Object? sortOrder = null,}) {
  return _then(TemplateChecklistItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,sectionId: null == sectionId ? _self.sectionId : sectionId // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,helpText: freezed == helpText ? _self.helpText : helpText // ignore: cast_nullable_to_non_nullable
as String?,requiresEvidence: null == requiresEvidence ? _self.requiresEvidence : requiresEvidence // ignore: cast_nullable_to_non_nullable
as bool,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [TemplateChecklistItem].
extension TemplateChecklistItemPatterns on TemplateChecklistItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TemplateChecklistItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TemplateChecklistItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TemplateChecklistItem value)  $default,){
final _that = this;
switch (_that) {
case _TemplateChecklistItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TemplateChecklistItem value)?  $default,){
final _that = this;
switch (_that) {
case _TemplateChecklistItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String sectionId,  String label,  String? helpText,  bool requiresEvidence,  int sortOrder)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TemplateChecklistItem() when $default != null:
return $default(_that.id,_that.sectionId,_that.label,_that.helpText,_that.requiresEvidence,_that.sortOrder);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String sectionId,  String label,  String? helpText,  bool requiresEvidence,  int sortOrder)  $default,) {final _that = this;
switch (_that) {
case _TemplateChecklistItem():
return $default(_that.id,_that.sectionId,_that.label,_that.helpText,_that.requiresEvidence,_that.sortOrder);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String sectionId,  String label,  String? helpText,  bool requiresEvidence,  int sortOrder)?  $default,) {final _that = this;
switch (_that) {
case _TemplateChecklistItem() when $default != null:
return $default(_that.id,_that.sectionId,_that.label,_that.helpText,_that.requiresEvidence,_that.sortOrder);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TemplateChecklistItem implements TemplateChecklistItem {
  const _TemplateChecklistItem({required this.id, required this.sectionId, required this.label, this.helpText, this.requiresEvidence = false, this.sortOrder = 0});
  factory _TemplateChecklistItem.fromJson(Map<String, dynamic> json) => _$TemplateChecklistItemFromJson(json);

@override final  String id;
@override final  String sectionId;
@override final  String label;
@override final  String? helpText;
@override@JsonKey() final  bool requiresEvidence;
@override@JsonKey() final  int sortOrder;

/// Create a copy of TemplateChecklistItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TemplateChecklistItemCopyWith<_TemplateChecklistItem> get copyWith => __$TemplateChecklistItemCopyWithImpl<_TemplateChecklistItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TemplateChecklistItemToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _TemplateChecklistItem&&(identical(other.id, id) || other.id == id)&&(identical(other.sectionId, sectionId) || other.sectionId == sectionId)&&(identical(other.label, label) || other.label == label)&&(identical(other.helpText, helpText) || other.helpText == helpText)&&(identical(other.requiresEvidence, requiresEvidence) || other.requiresEvidence == requiresEvidence)&&(identical(other.sortOrder, sortOrder) || other.sortOrder == sortOrder));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,sectionId,label,helpText,requiresEvidence,sortOrder);
}

@override
String toString() {
    return 'TemplateChecklistItem(id: $id, sectionId: $sectionId, label: $label, helpText: $helpText, requiresEvidence: $requiresEvidence, sortOrder: $sortOrder)';
}


}

/// @nodoc
abstract mixin class _$TemplateChecklistItemCopyWith<$Res> implements $TemplateChecklistItemCopyWith<$Res> {
  factory _$TemplateChecklistItemCopyWith(_TemplateChecklistItem value, $Res Function(_TemplateChecklistItem) _then) = __$TemplateChecklistItemCopyWithImpl;
@override @useResult
$Res call({
 String id, String sectionId, String label, String? helpText, bool requiresEvidence, int sortOrder
});




}
/// @nodoc
class __$TemplateChecklistItemCopyWithImpl<$Res>
    implements _$TemplateChecklistItemCopyWith<$Res> {
  __$TemplateChecklistItemCopyWithImpl(this._self, this._then);

  final _TemplateChecklistItem _self;
  final $Res Function(_TemplateChecklistItem) _then;

/// Create a copy of TemplateChecklistItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? sectionId = null,Object? label = null,Object? helpText = freezed,Object? requiresEvidence = null,Object? sortOrder = null,}) {
  return _then(_TemplateChecklistItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,sectionId: null == sectionId ? _self.sectionId : sectionId // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,helpText: freezed == helpText ? _self.helpText : helpText // ignore: cast_nullable_to_non_nullable
as String?,requiresEvidence: null == requiresEvidence ? _self.requiresEvidence : requiresEvidence // ignore: cast_nullable_to_non_nullable
as bool,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$TemplateSection {

 String get id; String get templateId; String get title; int get sortOrder; List<TemplateChecklistItem> get items;
/// Create a copy of TemplateSection
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TemplateSectionCopyWith<TemplateSection> get copyWith => _$TemplateSectionCopyWithImpl<TemplateSection>(this as TemplateSection, _$identity);

  /// Serializes this TemplateSection to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as TemplateSection;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TemplateSection&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.templateId, _this.templateId) || other.templateId == _this.templateId)&&(identical(other.title, _this.title) || other.title == _this.title)&&(identical(other.sortOrder, _this.sortOrder) || other.sortOrder == _this.sortOrder)&&const DeepCollectionEquality().equals(other.items, _this.items));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as TemplateSection;
  return Object.hash(runtimeType,_this.id,_this.templateId,_this.title,_this.sortOrder,const DeepCollectionEquality().hash(_this.items));
}

@override
String toString() {
  final _this = this as TemplateSection;
  return 'TemplateSection(id: ${_this.id}, templateId: ${_this.templateId}, title: ${_this.title}, sortOrder: ${_this.sortOrder}, items: ${_this.items})';
}


}

/// @nodoc
abstract mixin class $TemplateSectionCopyWith<$Res>  {
  factory $TemplateSectionCopyWith(TemplateSection value, $Res Function(TemplateSection) _then) = _$TemplateSectionCopyWithImpl;
@useResult
$Res call({
 String id, String templateId, String title, int sortOrder, List<TemplateChecklistItem> items
});




}
/// @nodoc
class _$TemplateSectionCopyWithImpl<$Res>
    implements $TemplateSectionCopyWith<$Res> {
  _$TemplateSectionCopyWithImpl(this._self, this._then);

  final TemplateSection _self;
  final $Res Function(TemplateSection) _then;

/// Create a copy of TemplateSection
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? templateId = null,Object? title = null,Object? sortOrder = null,Object? items = null,}) {
  return _then(TemplateSection(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,templateId: null == templateId ? _self.templateId : templateId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<TemplateChecklistItem>,
  ));
}

}


/// Adds pattern-matching-related methods to [TemplateSection].
extension TemplateSectionPatterns on TemplateSection {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TemplateSection value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TemplateSection() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TemplateSection value)  $default,){
final _that = this;
switch (_that) {
case _TemplateSection():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TemplateSection value)?  $default,){
final _that = this;
switch (_that) {
case _TemplateSection() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String templateId,  String title,  int sortOrder,  List<TemplateChecklistItem> items)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TemplateSection() when $default != null:
return $default(_that.id,_that.templateId,_that.title,_that.sortOrder,_that.items);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String templateId,  String title,  int sortOrder,  List<TemplateChecklistItem> items)  $default,) {final _that = this;
switch (_that) {
case _TemplateSection():
return $default(_that.id,_that.templateId,_that.title,_that.sortOrder,_that.items);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String templateId,  String title,  int sortOrder,  List<TemplateChecklistItem> items)?  $default,) {final _that = this;
switch (_that) {
case _TemplateSection() when $default != null:
return $default(_that.id,_that.templateId,_that.title,_that.sortOrder,_that.items);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TemplateSection implements TemplateSection {
  const _TemplateSection({required this.id, required this.templateId, required this.title, this.sortOrder = 0,  List<TemplateChecklistItem> items = const <TemplateChecklistItem>[]}): _items = items;
  factory _TemplateSection.fromJson(Map<String, dynamic> json) => _$TemplateSectionFromJson(json);

@override final  String id;
@override final  String templateId;
@override final  String title;
@override@JsonKey() final  int sortOrder;
 final  List<TemplateChecklistItem> _items;
@override@JsonKey() List<TemplateChecklistItem> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}


/// Create a copy of TemplateSection
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TemplateSectionCopyWith<_TemplateSection> get copyWith => __$TemplateSectionCopyWithImpl<_TemplateSection>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TemplateSectionToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _TemplateSection&&(identical(other.id, id) || other.id == id)&&(identical(other.templateId, templateId) || other.templateId == templateId)&&(identical(other.title, title) || other.title == title)&&(identical(other.sortOrder, sortOrder) || other.sortOrder == sortOrder)&&const DeepCollectionEquality().equals(other.items, _items));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,templateId,title,sortOrder,const DeepCollectionEquality().hash(_items));
}

@override
String toString() {
    return 'TemplateSection(id: $id, templateId: $templateId, title: $title, sortOrder: $sortOrder, items: $items)';
}


}

/// @nodoc
abstract mixin class _$TemplateSectionCopyWith<$Res> implements $TemplateSectionCopyWith<$Res> {
  factory _$TemplateSectionCopyWith(_TemplateSection value, $Res Function(_TemplateSection) _then) = __$TemplateSectionCopyWithImpl;
@override @useResult
$Res call({
 String id, String templateId, String title, int sortOrder, List<TemplateChecklistItem> items
});




}
/// @nodoc
class __$TemplateSectionCopyWithImpl<$Res>
    implements _$TemplateSectionCopyWith<$Res> {
  __$TemplateSectionCopyWithImpl(this._self, this._then);

  final _TemplateSection _self;
  final $Res Function(_TemplateSection) _then;

/// Create a copy of TemplateSection
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? templateId = null,Object? title = null,Object? sortOrder = null,Object? items = null,}) {
  return _then(_TemplateSection(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,templateId: null == templateId ? _self.templateId : templateId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<TemplateChecklistItem>,
  ));
}


}


/// @nodoc
mixin _$InspectionTemplate {

 String get id; String get name; String? get description; String get category; bool get isActive; List<TemplateSection> get sections;
/// Create a copy of InspectionTemplate
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InspectionTemplateCopyWith<InspectionTemplate> get copyWith => _$InspectionTemplateCopyWithImpl<InspectionTemplate>(this as InspectionTemplate, _$identity);

  /// Serializes this InspectionTemplate to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as InspectionTemplate;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is InspectionTemplate&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.description, _this.description) || other.description == _this.description)&&(identical(other.category, _this.category) || other.category == _this.category)&&(identical(other.isActive, _this.isActive) || other.isActive == _this.isActive)&&const DeepCollectionEquality().equals(other.sections, _this.sections));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as InspectionTemplate;
  return Object.hash(runtimeType,_this.id,_this.name,_this.description,_this.category,_this.isActive,const DeepCollectionEquality().hash(_this.sections));
}

@override
String toString() {
  final _this = this as InspectionTemplate;
  return 'InspectionTemplate(id: ${_this.id}, name: ${_this.name}, description: ${_this.description}, category: ${_this.category}, isActive: ${_this.isActive}, sections: ${_this.sections})';
}


}

/// @nodoc
abstract mixin class $InspectionTemplateCopyWith<$Res>  {
  factory $InspectionTemplateCopyWith(InspectionTemplate value, $Res Function(InspectionTemplate) _then) = _$InspectionTemplateCopyWithImpl;
@useResult
$Res call({
 String id, String name, String? description, String category, bool isActive, List<TemplateSection> sections
});




}
/// @nodoc
class _$InspectionTemplateCopyWithImpl<$Res>
    implements $InspectionTemplateCopyWith<$Res> {
  _$InspectionTemplateCopyWithImpl(this._self, this._then);

  final InspectionTemplate _self;
  final $Res Function(InspectionTemplate) _then;

/// Create a copy of InspectionTemplate
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? description = freezed,Object? category = null,Object? isActive = null,Object? sections = null,}) {
  return _then(InspectionTemplate(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,sections: null == sections ? _self.sections : sections // ignore: cast_nullable_to_non_nullable
as List<TemplateSection>,
  ));
}

}


/// Adds pattern-matching-related methods to [InspectionTemplate].
extension InspectionTemplatePatterns on InspectionTemplate {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _InspectionTemplate value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _InspectionTemplate() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _InspectionTemplate value)  $default,){
final _that = this;
switch (_that) {
case _InspectionTemplate():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _InspectionTemplate value)?  $default,){
final _that = this;
switch (_that) {
case _InspectionTemplate() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String? description,  String category,  bool isActive,  List<TemplateSection> sections)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _InspectionTemplate() when $default != null:
return $default(_that.id,_that.name,_that.description,_that.category,_that.isActive,_that.sections);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String? description,  String category,  bool isActive,  List<TemplateSection> sections)  $default,) {final _that = this;
switch (_that) {
case _InspectionTemplate():
return $default(_that.id,_that.name,_that.description,_that.category,_that.isActive,_that.sections);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String? description,  String category,  bool isActive,  List<TemplateSection> sections)?  $default,) {final _that = this;
switch (_that) {
case _InspectionTemplate() when $default != null:
return $default(_that.id,_that.name,_that.description,_that.category,_that.isActive,_that.sections);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _InspectionTemplate implements InspectionTemplate {
  const _InspectionTemplate({required this.id, required this.name, this.description, required this.category, this.isActive = true,  List<TemplateSection> sections = const <TemplateSection>[]}): _sections = sections;
  factory _InspectionTemplate.fromJson(Map<String, dynamic> json) => _$InspectionTemplateFromJson(json);

@override final  String id;
@override final  String name;
@override final  String? description;
@override final  String category;
@override@JsonKey() final  bool isActive;
 final  List<TemplateSection> _sections;
@override@JsonKey() List<TemplateSection> get sections {
  if (_sections is EqualUnmodifiableListView) return _sections;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_sections);
}


/// Create a copy of InspectionTemplate
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InspectionTemplateCopyWith<_InspectionTemplate> get copyWith => __$InspectionTemplateCopyWithImpl<_InspectionTemplate>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$InspectionTemplateToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _InspectionTemplate&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.category, category) || other.category == category)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&const DeepCollectionEquality().equals(other.sections, _sections));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,name,description,category,isActive,const DeepCollectionEquality().hash(_sections));
}

@override
String toString() {
    return 'InspectionTemplate(id: $id, name: $name, description: $description, category: $category, isActive: $isActive, sections: $sections)';
}


}

/// @nodoc
abstract mixin class _$InspectionTemplateCopyWith<$Res> implements $InspectionTemplateCopyWith<$Res> {
  factory _$InspectionTemplateCopyWith(_InspectionTemplate value, $Res Function(_InspectionTemplate) _then) = __$InspectionTemplateCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String? description, String category, bool isActive, List<TemplateSection> sections
});




}
/// @nodoc
class __$InspectionTemplateCopyWithImpl<$Res>
    implements _$InspectionTemplateCopyWith<$Res> {
  __$InspectionTemplateCopyWithImpl(this._self, this._then);

  final _InspectionTemplate _self;
  final $Res Function(_InspectionTemplate) _then;

/// Create a copy of InspectionTemplate
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? description = freezed,Object? category = null,Object? isActive = null,Object? sections = null,}) {
  return _then(_InspectionTemplate(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,sections: null == sections ? _self._sections : sections // ignore: cast_nullable_to_non_nullable
as List<TemplateSection>,
  ));
}


}

// dart format on
