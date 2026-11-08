import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../app/theme/app_colors.dart';
import '../../data/models/enums.dart';

/// Icon + tone + label for every status enum. Status is always shown with a
/// text label, never by color alone.
class StatusStyle {
  const StatusStyle({
    required this.icon,
    required this.tone,
    required this.label,
  });

  final IconData icon;
  final Tone tone;
  final String label;

  static StatusStyle forInspectionStatus(InspectionStatus status) =>
      switch (status) {
        InspectionStatus.draft => const StatusStyle(
          icon: LucideIcons.filePen,
          tone: Tone.slate,
          label: 'Draft',
        ),
        InspectionStatus.scheduled => const StatusStyle(
          icon: LucideIcons.calendarClock,
          tone: Tone.blue,
          label: 'Scheduled',
        ),
        InspectionStatus.inProgress => const StatusStyle(
          icon: LucideIcons.circleDot,
          tone: Tone.orange,
          label: 'In Progress',
        ),
        InspectionStatus.completed => const StatusStyle(
          icon: LucideIcons.circleCheck,
          tone: Tone.green,
          label: 'Completed',
        ),
      };

  static StatusStyle forChecklistResult(ChecklistResult result) =>
      switch (result) {
        ChecklistResult.pass => const StatusStyle(
          icon: LucideIcons.circleCheck,
          tone: Tone.green,
          label: 'Pass',
        ),
        ChecklistResult.fail => const StatusStyle(
          icon: LucideIcons.circleX,
          tone: Tone.red,
          label: 'Fail',
        ),
        ChecklistResult.na => const StatusStyle(
          icon: LucideIcons.circleMinus,
          tone: Tone.slate,
          label: 'N/A',
        ),
      };

  static StatusStyle forSeverity(FindingSeverity severity) =>
      switch (severity) {
        FindingSeverity.critical => const StatusStyle(
          icon: LucideIcons.triangleAlert,
          tone: Tone.red,
          label: 'Critical',
        ),
        FindingSeverity.high => const StatusStyle(
          icon: LucideIcons.triangleAlert,
          tone: Tone.orange,
          label: 'High',
        ),
        FindingSeverity.medium => const StatusStyle(
          icon: LucideIcons.circleAlert,
          tone: Tone.amber,
          label: 'Medium',
        ),
        FindingSeverity.low => const StatusStyle(
          icon: LucideIcons.info,
          tone: Tone.green,
          label: 'Low',
        ),
      };

  static StatusStyle forSyncState(SyncState state) => switch (state) {
    SyncState.local => const StatusStyle(
      icon: LucideIcons.hardDrive,
      tone: Tone.slate,
      label: 'Local',
    ),
    SyncState.pendingSync => const StatusStyle(
      icon: LucideIcons.cloudUpload,
      tone: Tone.orange,
      label: 'Pending Sync',
    ),
    SyncState.synced => const StatusStyle(
      icon: LucideIcons.cloud,
      tone: Tone.green,
      label: 'Synced',
    ),
    SyncState.syncFailed => const StatusStyle(
      icon: LucideIcons.cloudOff,
      tone: Tone.red,
      label: 'Sync Failed',
    ),
  };
}

/// Tinted pill with the status label (and optionally its icon).
class StatusBadge extends StatelessWidget {
  const StatusBadge({
    super.key,
    required this.style,
    this.showIcon = false,
    this.large = false,
  });

  final StatusStyle style;
  final bool showIcon;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final fg = p.fg(style.tone);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: large ? 14 : 10,
        vertical: large ? 7 : 4.5,
      ),
      decoration: BoxDecoration(
        color: p.tint(style.tone),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon) ...[
            Icon(style.icon, size: large ? 16 : 13, color: fg),
            const SizedBox(width: 6),
          ],
          Text(
            style.label,
            style: TextStyle(
              color: fg,
              fontSize: large ? 13.5 : 11.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
