import '../../data/models/enums.dart';

/// Manual mirrors of the `@JsonValue` strings in `data/models/enums.dart`,
/// for the rare spots (request bodies/query params built by hand, rather
/// than through a freezed model's generated `toJson`) that need an enum's
/// wire value directly. Keep these in sync with the `@JsonValue` annotations.
String checklistResultToJson(ChecklistResult r) => switch (r) {
  ChecklistResult.pass => 'pass',
  ChecklistResult.fail => 'fail',
  ChecklistResult.na => 'na',
};

String recurrenceTypeToJson(RecurrenceType r) => switch (r) {
  RecurrenceType.oneTime => 'one_time',
  RecurrenceType.weekly => 'weekly',
  RecurrenceType.monthly => 'monthly',
  RecurrenceType.quarterly => 'quarterly',
};

String inspectionStatusToJson(InspectionStatus s) => switch (s) {
  InspectionStatus.draft => 'draft',
  InspectionStatus.scheduled => 'scheduled',
  InspectionStatus.inProgress => 'in_progress',
  InspectionStatus.completed => 'completed',
};
