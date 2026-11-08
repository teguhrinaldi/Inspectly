import 'package:freezed_annotation/freezed_annotation.dart';

import 'enums.dart';

part 'activity_entry.freezed.dart';
part 'activity_entry.g.dart';

@freezed
abstract class ActivityEntry with _$ActivityEntry {
  const factory ActivityEntry({
    required String id,
    required String inspectionId,
    required ActivityType type,
    @Default('') String description,
    String? actorName,
    required DateTime occurredAt,
  }) = _ActivityEntry;

  factory ActivityEntry.fromJson(Map<String, dynamic> json) =>
      _$ActivityEntryFromJson(json);
}
