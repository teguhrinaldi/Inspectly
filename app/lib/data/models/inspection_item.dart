import 'package:freezed_annotation/freezed_annotation.dart';

import 'enums.dart';
import 'evidence.dart';

part 'inspection_item.freezed.dart';
part 'inspection_item.g.dart';

@freezed
abstract class InspectionItem with _$InspectionItem {
  const factory InspectionItem({
    required String id,
    required String inspectionId,
    // Null on the server once the item was removed from its template.
    @Default('') String templateChecklistItemId,
    required String label,
    String? helpText,
    ChecklistResult? result,
    String? note,
    @Default(0) int sortOrder,
    @Default(<Evidence>[]) List<Evidence> evidence,
  }) = _InspectionItem;

  factory InspectionItem.fromJson(Map<String, dynamic> json) =>
      _$InspectionItemFromJson(json);
}
