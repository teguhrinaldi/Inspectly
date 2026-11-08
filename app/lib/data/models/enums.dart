// Locked state enums shared with the Laravel API.
// See docs/architecture.md §3 before adding new states.
// JSON values are pinned with @JsonValue so json_serializable encodes/decodes
// them exactly as the API expects, independent of the Dart member names.
import 'package:json_annotation/json_annotation.dart';

enum InspectionStatus {
  @JsonValue('draft')
  draft,
  @JsonValue('scheduled')
  scheduled,
  @JsonValue('in_progress')
  inProgress,
  @JsonValue('completed')
  completed;

  String get label => switch (this) {
    InspectionStatus.draft => 'Draft',
    InspectionStatus.scheduled => 'Scheduled',
    InspectionStatus.inProgress => 'In Progress',
    InspectionStatus.completed => 'Completed',
  };
}

enum ChecklistResult {
  @JsonValue('pass')
  pass,
  @JsonValue('fail')
  fail,
  @JsonValue('na')
  na;

  String get label => switch (this) {
    ChecklistResult.pass => 'Pass',
    ChecklistResult.fail => 'Fail',
    ChecklistResult.na => 'N/A',
  };
}

enum FindingSeverity {
  @JsonValue('critical')
  critical,
  @JsonValue('high')
  high,
  @JsonValue('medium')
  medium,
  @JsonValue('low')
  low;

  String get label => switch (this) {
    FindingSeverity.critical => 'Critical',
    FindingSeverity.high => 'High',
    FindingSeverity.medium => 'Medium',
    FindingSeverity.low => 'Low',
  };

  /// Lower is worse; used for sorting findings by severity (most severe first).
  int get rank => switch (this) {
    FindingSeverity.critical => 0,
    FindingSeverity.high => 1,
    FindingSeverity.medium => 2,
    FindingSeverity.low => 3,
  };
}

enum FindingStatus {
  @JsonValue('open')
  open,
  @JsonValue('resolved')
  resolved,
}

/// Flutter-only concept: never sent to / received from the API as a field.
enum SyncState {
  local,
  pendingSync,
  synced,
  syncFailed;

  String get label => switch (this) {
    SyncState.local => 'Local',
    SyncState.pendingSync => 'Pending Sync',
    SyncState.synced => 'Synced',
    SyncState.syncFailed => 'Sync Failed',
  };
}

enum RecurrenceType {
  @JsonValue('one_time')
  oneTime,
  @JsonValue('weekly')
  weekly,
  @JsonValue('monthly')
  monthly,
  @JsonValue('quarterly')
  quarterly;

  String get label => switch (this) {
    RecurrenceType.oneTime => 'One time',
    RecurrenceType.weekly => 'Weekly',
    RecurrenceType.monthly => 'Monthly',
    RecurrenceType.quarterly => 'Every 3 months',
  };
}

enum UserRole {
  @JsonValue('inspector')
  inspector,
  @JsonValue('admin')
  admin,
}

enum ComparisonState {
  newFinding,
  stillOpen,
  resolved;

  String get label => switch (this) {
    ComparisonState.newFinding => 'New',
    ComparisonState.stillOpen => 'Still Open',
    ComparisonState.resolved => 'Resolved',
  };
}

enum ActivityType {
  @JsonValue('started')
  started,
  @JsonValue('checklist_updated')
  checklistUpdated,
  @JsonValue('finding_added')
  findingAdded,
  @JsonValue('photo_added')
  photoAdded,
  @JsonValue('signature_captured')
  signatureCaptured,
  @JsonValue('completed')
  completed,
  @JsonValue('report_generated')
  reportGenerated,
}
