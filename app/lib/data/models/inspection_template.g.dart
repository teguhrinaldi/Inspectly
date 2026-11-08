// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inspection_template.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TemplateChecklistItem _$TemplateChecklistItemFromJson(
  Map<String, dynamic> json,
) => _TemplateChecklistItem(
  id: json['id'] as String,
  sectionId: json['section_id'] as String,
  label: json['label'] as String,
  helpText: json['help_text'] as String?,
  requiresEvidence: json['requires_evidence'] as bool? ?? false,
  sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$TemplateChecklistItemToJson(
  _TemplateChecklistItem instance,
) => <String, dynamic>{
  'id': instance.id,
  'section_id': instance.sectionId,
  'label': instance.label,
  'help_text': instance.helpText,
  'requires_evidence': instance.requiresEvidence,
  'sort_order': instance.sortOrder,
};

_TemplateSection _$TemplateSectionFromJson(Map<String, dynamic> json) =>
    _TemplateSection(
      id: json['id'] as String,
      templateId: json['template_id'] as String,
      title: json['title'] as String,
      sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
      items:
          (json['items'] as List<dynamic>?)
              ?.map(
                (e) =>
                    TemplateChecklistItem.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          const <TemplateChecklistItem>[],
    );

Map<String, dynamic> _$TemplateSectionToJson(_TemplateSection instance) =>
    <String, dynamic>{
      'id': instance.id,
      'template_id': instance.templateId,
      'title': instance.title,
      'sort_order': instance.sortOrder,
      'items': instance.items,
    };

_InspectionTemplate _$InspectionTemplateFromJson(Map<String, dynamic> json) =>
    _InspectionTemplate(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      category: json['category'] as String,
      isActive: json['is_active'] as bool? ?? true,
      sections:
          (json['sections'] as List<dynamic>?)
              ?.map((e) => TemplateSection.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <TemplateSection>[],
    );

Map<String, dynamic> _$InspectionTemplateToJson(_InspectionTemplate instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'category': instance.category,
      'is_active': instance.isActive,
      'sections': instance.sections,
    };
