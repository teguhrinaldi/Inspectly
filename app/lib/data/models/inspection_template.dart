import 'package:freezed_annotation/freezed_annotation.dart';

part 'inspection_template.freezed.dart';
part 'inspection_template.g.dart';

@freezed
abstract class TemplateChecklistItem with _$TemplateChecklistItem {
  const factory TemplateChecklistItem({
    required String id,
    required String sectionId,
    required String label,
    String? helpText,
    @Default(false) bool requiresEvidence,
    @Default(0) int sortOrder,
  }) = _TemplateChecklistItem;

  factory TemplateChecklistItem.fromJson(Map<String, dynamic> json) =>
      _$TemplateChecklistItemFromJson(json);
}

@freezed
abstract class TemplateSection with _$TemplateSection {
  const factory TemplateSection({
    required String id,
    required String templateId,
    required String title,
    @Default(0) int sortOrder,
    @Default(<TemplateChecklistItem>[]) List<TemplateChecklistItem> items,
  }) = _TemplateSection;

  factory TemplateSection.fromJson(Map<String, dynamic> json) =>
      _$TemplateSectionFromJson(json);
}

@freezed
abstract class InspectionTemplate with _$InspectionTemplate {
  const factory InspectionTemplate({
    required String id,
    required String name,
    String? description,
    required String category,
    @Default(true) bool isActive,
    @Default(<TemplateSection>[]) List<TemplateSection> sections,
  }) = _InspectionTemplate;

  factory InspectionTemplate.fromJson(Map<String, dynamic> json) =>
      _$InspectionTemplateFromJson(json);
}
