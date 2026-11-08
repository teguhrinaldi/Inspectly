import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../app/providers/inspection_providers.dart';
import '../../app/providers/repository_providers.dart';
import '../../app/theme/app_colors.dart';
import '../../core/widgets/responsive_content.dart';
import '../../core/widgets/status_style.dart';
import '../../core/widgets/surfaces.dart';
import '../../data/models/enums.dart';
import '../../data/models/finding.dart';
import '../../data/models/inspection.dart';
import 'finding_actions.dart';
import 'widgets/finding_widgets.dart';
import 'widgets/photo_capture.dart';
import '../../core/errors/failure.dart';

class FindingsScreen extends ConsumerWidget {
  const FindingsScreen({super.key, required this.inspectionId});
  final String inspectionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(inspectionByIdProvider(inspectionId));
    return Scaffold(
      appBar: const ScreenHeader(title: 'Findings'),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => EmptyState(
          icon: LucideIcons.cloudOff,
          title: 'Could not load findings',
          message: userMessage(e),
        ),
        data: (inspection) =>
            ResponsiveContent(child: FindingsView(inspection: inspection)),
      ),
    );
  }
}

/// Add button, severity tiles and the finding cards. Also embedded in the
/// inspection detail "Findings" tab.
class FindingsView extends ConsumerWidget {
  const FindingsView({
    super.key,
    required this.inspection,
    this.embedded = false,
  });

  final Inspection inspection;
  final bool embedded;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.palette;
    final editable = inspection.status != InspectionStatus.completed;
    final findings = inspection.findings;
    final children = <Widget>[
      if (editable)
        Align(
          alignment: Alignment.centerRight,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(minimumSize: const Size(0, 46)),
            icon: const Icon(LucideIcons.plus, size: 18),
            label: const Text('Add Finding'),
            onPressed: () => addFindingFlow(context, ref, inspection),
          ),
        ),
      if (editable) const SizedBox(height: 16),
      SeverityTiles(inspection: inspection),
      const SizedBox(height: 16),
      if (findings.isEmpty)
        SurfaceCard(
          child: Row(
            children: [
              const IconTile(icon: LucideIcons.circleCheck, tone: Tone.green),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'No findings recorded for this inspection.',
                  style: TextStyle(color: p.textSecondary),
                ),
              ),
            ],
          ),
        ),
      for (final f in findings) ...[
        FindingCard(
          finding: f,
          onTap: () => FindingDetailSheet.show(context, inspection, f),
        ),
        const SizedBox(height: 10),
      ],
    ];
    if (embedded) return Column(children: children);
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      children: children,
    );
  }
}

class FindingDetailSheet extends ConsumerWidget {
  const FindingDetailSheet({
    super.key,
    required this.inspectionId,
    required this.findingId,
  });

  final String inspectionId;
  final String findingId;

  static Future<void> show(
    BuildContext context,
    Inspection inspection,
    Finding finding,
  ) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      useRootNavigator: true,
      builder: (_) => FindingDetailSheet(
        inspectionId: inspection.id,
        findingId: finding.id,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.palette;
    final inspection = ref.watch(inspectionByIdProvider(inspectionId)).value;
    final finding = inspection?.findings
        .where((f) => f.id == findingId)
        .firstOrNull;
    if (inspection == null || finding == null) {
      return const SizedBox(
        height: 200,
        child: Center(child: CircularProgressIndicator()),
      );
    }
    final style = StatusStyle.forSeverity(finding.severity);
    final editable = inspection.status != InspectionStatus.completed;

    Future<void> addPhoto() async {
      final photo = await capturePhoto(
        context,
        siteName: inspection.siteName,
        inspectorName: inspection.inspectorName,
      );
      if (photo == null) return;
      await ref
          .read(evidenceRepositoryProvider)
          .attach(
            inspectionId: inspection.id,
            findingId: finding.id,
            localFilePath: photo.path,
            latitude: photo.latitude,
            longitude: photo.longitude,
          );
      ref.invalidateInspection(inspection.id);
    }

    Future<void> toggleResolved() async {
      await ref
          .read(inspectionRepositoryProvider)
          .updateFinding(
            finding.copyWith(
              status: finding.status == FindingStatus.open
                  ? FindingStatus.resolved
                  : FindingStatus.open,
            ),
          );
      ref.invalidateInspection(inspection.id);
    }

    Widget block(String title, String? body) => body == null
        ? const SizedBox.shrink()
        : Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: p.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  body,
                  style: TextStyle(fontSize: 14.5, color: p.textPrimary),
                ),
              ],
            ),
          );

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      child: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        children: [
          Row(
            children: [
              StatusBadge(style: style, showIcon: true),
              const SizedBox(width: 8),
              if (finding.status == FindingStatus.resolved)
                const StatusBadge(
                  style: StatusStyle(
                    icon: LucideIcons.circleCheck,
                    tone: Tone.green,
                    label: 'Resolved',
                  ),
                  showIcon: true,
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            finding.title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: p.textPrimary,
            ),
          ),
          if (finding.location != null) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(LucideIcons.building2, size: 14, color: p.textMuted),
                const SizedBox(width: 6),
                Text(
                  finding.location!,
                  style: TextStyle(color: p.textSecondary, fontSize: 13.5),
                ),
              ],
            ),
          ],
          block('Description', finding.description),
          block('Recommendation', finding.recommendation),
          const SizedBox(height: 16),
          Text(
            'Photo (${finding.evidence.length})',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: p.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          if (finding.evidence.isNotEmpty)
            EvidenceStrip(evidence: finding.evidence, size: 96),
          if (editable) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(LucideIcons.camera, size: 18),
                    label: const Text('Add Photo'),
                    onPressed: addPhoto,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: Icon(
                      finding.status == FindingStatus.open
                          ? LucideIcons.circleCheck
                          : LucideIcons.rotateCcw,
                      size: 18,
                    ),
                    label: Text(
                      finding.status == FindingStatus.open
                          ? 'Mark Resolved'
                          : 'Reopen',
                    ),
                    onPressed: toggleResolved,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
