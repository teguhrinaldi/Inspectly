import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../app/providers/repository_providers.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/widgets/surfaces.dart';
import '../../../data/models/activity_entry.dart';
import '../../../data/models/enums.dart';
import '../../../data/models/inspection.dart';

/// Checklist notes plus the inspection's activity timeline.
class NotesView extends ConsumerWidget {
  const NotesView({super.key, required this.inspection});
  final Inspection inspection;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.palette;
    final notedItems = inspection.items
        .where((i) => i.note != null && i.note!.isNotEmpty)
        .toList();

    return FutureBuilder(
      future: ref.read(inspectionRepositoryProvider).activities(inspection.id),
      builder: (context, snapshot) {
        final activities = snapshot.data?.dataOrNull ?? const <ActivityEntry>[];
        if (notedItems.isEmpty && activities.isEmpty) {
          return SurfaceCard(
            child: Text(
              'No notes or activity yet.',
              style: TextStyle(color: p.textSecondary),
            ),
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (notedItems.isNotEmpty) ...[
              const SectionTitle('Notes'),
              const SizedBox(height: 10),
              for (final item in notedItems) ...[
                SurfaceCard(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.label,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: p.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.note!,
                        style: TextStyle(
                          fontSize: 13.5,
                          color: p.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
              ],
              const SizedBox(height: 12),
            ],
            if (activities.isNotEmpty) ...[
              const SectionTitle('Activity'),
              const SizedBox(height: 10),
              SurfaceCard(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 4),
                child: Column(
                  children: [
                    for (final a in activities) _ActivityRow(activity: a),
                  ],
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

class _ActivityRow extends StatelessWidget {
  const _ActivityRow({required this.activity});
  final ActivityEntry activity;

  (IconData, Tone) get _visual => switch (activity.type) {
    ActivityType.started => (LucideIcons.circlePlay, Tone.blue),
    ActivityType.checklistUpdated => (LucideIcons.circleCheck, Tone.green),
    ActivityType.findingAdded => (LucideIcons.triangleAlert, Tone.orange),
    ActivityType.photoAdded => (LucideIcons.camera, Tone.blue),
    ActivityType.signatureCaptured => (LucideIcons.penLine, Tone.teal),
    ActivityType.completed => (LucideIcons.flagTriangleRight, Tone.green),
    ActivityType.reportGenerated => (LucideIcons.fileText, Tone.slate),
  };

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final (icon, tone) = _visual;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          IconTile(icon: icon, tone: tone, size: 30),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              activity.description,
              style: TextStyle(fontSize: 13.5, color: p.textPrimary),
            ),
          ),
          Text(
            DateFormat('MMM d, HH:mm').format(activity.occurredAt),
            style: TextStyle(fontSize: 11.5, color: p.textMuted),
          ),
        ],
      ),
    );
  }
}
