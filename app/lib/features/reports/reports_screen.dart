import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../app/providers/inspection_providers.dart';
import '../../app/theme/app_colors.dart';
import '../../core/utils/date_labels.dart';
import '../../core/widgets/app_image.dart';
import '../../core/widgets/responsive_content.dart';
import '../../core/widgets/surfaces.dart';
import '../../data/models/enums.dart';
import '../../data/models/inspection.dart';
import '../../data/repositories/inspection_repository.dart';
import '../../core/errors/failure.dart';

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.palette;
    final async = ref.watch(
      inspectionListProvider(
        const InspectionListFilter(status: InspectionStatus.completed),
      ),
    );

    return Scaffold(
      body: SafeArea(
        child: ResponsiveContent(
          child: async.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => EmptyState(
              icon: LucideIcons.cloudOff,
              title: 'Could not load reports',
              message: userMessage(e),
            ),
            data: (list) {
              final reports = [...list]
                ..sort(
                  (a, b) => (b.completedAt ?? DateTime(0)).compareTo(
                    a.completedAt ?? DateTime(0),
                  ),
                );
              final avg = reports.isEmpty
                  ? 0
                  : reports
                            .map((r) => r.computedPassPercentage)
                            .reduce((a, b) => a + b) /
                        reports.length;
              final openFindings = reports
                  .expand((r) => r.findings)
                  .where((f) => f.status == FindingStatus.open)
                  .length;

              return RefreshIndicator(
                onRefresh: () async => ref.invalidate(inspectionListProvider),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                  children: [
                    Text(
                      'Reports',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: p.textPrimary,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _Stat(
                          value: '${reports.length}',
                          label: 'Completed',
                          tone: Tone.blue,
                        ),
                        const SizedBox(width: 10),
                        _Stat(
                          value: '${avg.round()}%',
                          label: 'Avg. Pass Rate',
                          tone: Tone.teal,
                        ),
                        const SizedBox(width: 10),
                        _Stat(
                          value: '$openFindings',
                          label: 'Open Findings',
                          tone: Tone.orange,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const SectionTitle('Completed Inspections'),
                    const SizedBox(height: 10),
                    if (reports.isEmpty)
                      const EmptyState(
                        icon: LucideIcons.fileText,
                        title: 'No reports yet',
                        message: 'Reports appear here once an inspection is completed and signed.',
                      ),
                    for (final r in reports) ...[
                      _ReportCard(inspection: r),
                      const SizedBox(height: 10),
                    ],
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label, required this.tone});

  final String value;
  final String label;
  final Tone tone;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: p.tint(tone),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: p.fg(tone),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 12, color: p.fg(tone)),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  const _ReportCard({required this.inspection});
  final Inspection inspection;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final pct = inspection.computedPassPercentage.round();
    final critical = inspection.findings
        .where(
          (f) =>
              f.severity == FindingSeverity.critical ||
              f.severity == FindingSeverity.high,
        )
        .length;
    return SurfaceCard(
      onTap: () => context.go('/inspections/${inspection.id}/summary'),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox.square(
              dimension: 54,
              child: AppImage(
                inspection.siteCoverImageUrl,
                placeholderIcon: LucideIcons.building2,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  inspection.siteName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: p.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  inspection.templateName,
                  style: TextStyle(fontSize: 13, color: p.textSecondary),
                ),
                const SizedBox(height: 4),
                Text(
                  [
                    if (inspection.completedAt != null)
                      shortDate(inspection.completedAt!),
                    '${inspection.findings.length} findings',
                    if (critical > 0) '$critical critical/high',
                  ].join(' · '),
                  style: TextStyle(fontSize: 12.5, color: p.textMuted),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            children: [
              Text(
                '$pct%',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: p.fg(pct >= 80 ? Tone.green : Tone.orange),
                ),
              ),
              IconButton(
                tooltip: 'Open PDF report',
                visualDensity: VisualDensity.compact,
                icon: Icon(LucideIcons.fileText, size: 20, color: p.primary),
                onPressed: () => context.push('/report/${inspection.id}'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
