import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../app/providers/inspection_providers.dart';
import '../../app/theme/app_colors.dart';
import '../../core/widgets/responsive_content.dart';
import '../../core/widgets/status_style.dart';
import '../../core/widgets/surfaces.dart';
import '../../data/models/finding.dart';
import '../../data/models/inspection.dart';
import 'findings_screen.dart';
import 'widgets/finding_widgets.dart';

class EvidenceScreen extends ConsumerWidget {
  const EvidenceScreen({super.key, required this.inspectionId});
  final String inspectionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(inspectionByIdProvider(inspectionId));
    return Scaffold(
      appBar: const ScreenHeader(title: 'Evidence'),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => EmptyState(
          icon: LucideIcons.cloudOff,
          title: 'Could not load evidence',
          message: '$e',
        ),
        data: (inspection) => ResponsiveContent(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            children: [EvidenceView(inspection: inspection)],
          ),
        ),
      ),
    );
  }
}

/// Segmented "By Finding" / "All Photos" evidence browser. Also embedded in
/// the inspection detail "Evidence" tab.
class EvidenceView extends StatefulWidget {
  const EvidenceView({super.key, required this.inspection});
  final Inspection inspection;

  @override
  State<EvidenceView> createState() => _EvidenceViewState();
}

class _EvidenceViewState extends State<EvidenceView> {
  bool _byFinding = true;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final inspection = widget.inspection;
    final all = inspection.allEvidence;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: p.surfaceAlt,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              _Segment(
                label: 'By Finding',
                selected: _byFinding,
                onTap: () => setState(() => _byFinding = true),
              ),
              _Segment(
                label: 'All Photos (${all.length})',
                selected: !_byFinding,
                onTap: () => setState(() => _byFinding = false),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        SurfaceCard(
          child: Row(
            children: [
              const IconTile(icon: LucideIcons.building2, tone: Tone.teal),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      inspection.siteName,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: p.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      inspection.templateName,
                      style: TextStyle(fontSize: 13, color: p.textSecondary),
                    ),
                    if (inspection.siteAddress != null) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            LucideIcons.mapPin,
                            size: 13,
                            color: p.textMuted,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              inspection.siteAddress!,
                              style: TextStyle(
                                fontSize: 13,
                                color: p.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (inspection.locationLat != null &&
                        inspection.locationLng != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            LucideIcons.locateFixed,
                            size: 13,
                            color: p.textMuted,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'GPS at start ${inspection.locationLat!.toStringAsFixed(5)}, ${inspection.locationLng!.toStringAsFixed(5)}',
                            style: TextStyle(
                              fontSize: 12.5,
                              color: p.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        if (all.isEmpty)
          const EmptyState(
            icon: LucideIcons.camera,
            title: 'No photos yet',
            message:
                'Photos added to checklist items and findings appear here.',
          )
        else if (_byFinding) ...[
          for (final f in inspection.findings.where(
            (f) => f.evidence.isNotEmpty,
          )) ...[
            SurfaceCard(
              onTap: () => FindingDetailSheet.show(context, inspection, f),
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FindingSummaryLine(finding: f),
                  const SizedBox(height: 12),
                  EvidenceStrip(evidence: f.evidence),
                ],
              ),
            ),
            const SizedBox(height: 10),
          ],
          for (final item in inspection.items.where(
            (i) => i.evidence.isNotEmpty,
          )) ...[
            SurfaceCard(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const IconTile(
                        icon: LucideIcons.listChecks,
                        tone: Tone.blue,
                        size: 36,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.label,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: p.textPrimary,
                              ),
                            ),
                            Text(
                              'Checklist item · ${photoCount(item.evidence.length)}',
                              style: TextStyle(
                                fontSize: 13,
                                color: p.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  EvidenceStrip(evidence: item.evidence),
                ],
              ),
            ),
            const SizedBox(height: 10),
          ],
        ] else
          LayoutBuilder(
            builder: (context, c) {
              final size = (c.maxWidth - 16) / 3;
              return Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final (i, e) in all.indexed)
                    EvidenceThumb(
                      evidence: e,
                      size: size,
                      gallery: all,
                      index: i,
                    ),
                ],
              );
            },
          ),
      ],
    );
  }
}

/// Icon + title + "High · 2 photos" + location, compact.
class FindingSummaryLine extends StatelessWidget {
  const FindingSummaryLine({super.key, required this.finding});
  final Finding finding;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final style = StatusStyle.forSeverity(finding.severity);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        IconTile(
          icon: severityGlyph(finding.severity),
          tone: style.tone,
          size: 36,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                finding.title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: p.textPrimary,
                ),
              ),
              const SizedBox(height: 3),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: style.label,
                      style: TextStyle(
                        color: p.fg(style.tone),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    TextSpan(
                      text: '  ·  ${photoCount(finding.evidence.length)}',
                    ),
                  ],
                ),
                style: TextStyle(fontSize: 13, color: p.textSecondary),
              ),
              if (finding.location != null) ...[
                const SizedBox(height: 3),
                Text(
                  finding.location!,
                  style: TextStyle(fontSize: 13, color: p.textSecondary),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Expanded(
      child: Semantics(
        selected: selected,
        button: true,
        child: Material(
          color: selected ? p.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(11),
          elevation: selected ? 1 : 0,
          shadowColor: const Color(0x221B3A6B),
          child: InkWell(
            borderRadius: BorderRadius.circular(11),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  color: selected ? p.textPrimary : p.textSecondary,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
