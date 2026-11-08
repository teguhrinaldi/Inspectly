import 'package:freezed_annotation/freezed_annotation.dart';

import 'enums.dart';
import 'evidence.dart';

part 'finding.freezed.dart';
part 'finding.g.dart';

@freezed
abstract class Finding with _$Finding {
  const factory Finding({
    required String id,
    required String inspectionId,
    String? inspectionItemId,
    required String title,
    // Nullable on the server (e.g. cleared in the admin panel).
    @Default('') String description,
    required FindingSeverity severity,
    String? recommendation,
    String? location,
    @Default(FindingStatus.open) FindingStatus status,
    @Default(<Evidence>[]) List<Evidence> evidence,
  }) = _Finding;

  factory Finding.fromJson(Map<String, dynamic> json) =>
      _$FindingFromJson(json);
}
