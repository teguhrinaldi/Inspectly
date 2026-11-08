import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../app/providers/inspection_providers.dart';
import '../../app/providers/repository_providers.dart';
import '../../app/providers/template_providers.dart';
import '../../app/theme/app_colors.dart';
import '../../core/utils/date_labels.dart';
import '../../core/widgets/app_image.dart';
import '../../core/widgets/responsive_content.dart';
import '../../core/widgets/status_style.dart';
import '../../core/widgets/surfaces.dart';
import '../../data/models/enums.dart';
import '../../data/models/inspection.dart';
import '../../data/models/inspection_item.dart';
import '../../data/services/location_service.dart';
import '../findings/evidence_screen.dart';
import '../findings/findings_screen.dart';
import '../findings/widgets/finding_widgets.dart';
import 'widgets/notes_tab.dart';
import '../../core/errors/failure.dart';
import '../../app/providers/permissions.dart';
import '../../app/providers/auth_providers.dart';

class InspectionDetailScreen extends ConsumerWidget {
  const InspectionDetailScreen({super.key, required this.inspectionId});

  final String inspectionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.palette;
    final inspectionAsync = ref.watch(inspectionByIdProvider(inspectionId));

    return Scaffold(
      appBar: ScreenHeader(
        title: 'Inspection Detail',
        onBack: () =>
            context.canPop() ? context.pop() : context.go('/inspections'),
        trailing: IconButton(
          tooltip: 'Close',
          icon: Icon(LucideIcons.x, color: p.textSecondary, size: 22),
          onPressed: () => context.go('/inspections'),
        ),
      ),
      body: inspectionAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, st) => EmptyState(
          icon: LucideIcons.cloudOff,
          title: 'Could not load this inspection',
          message: userMessage(err),
          action: OutlinedButton(
            onPressed: () =>
                ref.invalidate(inspectionByIdProvider(inspectionId)),
            child: const Text('Try again'),
          ),
        ),
        data: (inspection) => _DetailBody(inspection: inspection),
      ),
    );
  }
}

class _DetailBody extends ConsumerStatefulWidget {
  const _DetailBody({required this.inspection});
  final Inspection inspection;

  @override
  ConsumerState<_DetailBody> createState() => _DetailBodyState();
}

class _DetailBodyState extends ConsumerState<_DetailBody> {
  int _tab = 0;
  bool _starting = false;

  Inspection get inspection => widget.inspection;

  Future<void> _primaryAction() async {
    final id = inspection.id;
    switch (inspection.status) {
      case InspectionStatus.draft:
      case InspectionStatus.scheduled:
        setState(() => _starting = true);
        final repo = ref.read(inspectionRepositoryProvider);
        final container = ProviderScope.containerOf(context, listen: false);
        final location = await LocationService().getCurrentLocation();
        final result = await repo.start(
          id,
          locationLat: location is LocationSuccess ? location.latitude : null,
          locationLng: location is LocationSuccess ? location.longitude : null,
        );
        container.invalidateInspection(id);
        if (!mounted) return;
        setState(() => _starting = false);
        if (result.dataOrNull == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                result.when(
                  success: (_) => 'Could not start the inspection.',
                  failure: (f) => f.message,
                ),
              ),
            ),
          );
          return;
        }
        if (location is! LocationSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Started without GPS — location unavailable.'),
            ),
          );
        }
        context.push('/checklist/$id');
      case InspectionStatus.inProgress:
        context.push('/checklist/$id');
      case InspectionStatus.completed:
        context.go('/inspections/$id/summary');
    }
  }

  bool get _canWrite =>
      canWriteInspection(ref.watch(authStateProvider), inspection);

  String get _ctaLabel => switch (inspection.status) {
    InspectionStatus.draft || InspectionStatus.scheduled => 'Start Inspection',
    InspectionStatus.inProgress => 'Continue Inspection',
    InspectionStatus.completed => 'View Risk Summary',
  };

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final evidenceCount = inspection.allEvidence.length;
    final date =
        inspection.completedAt ??
        inspection.scheduledAt ??
        inspection.startedAt;
    final tabs = [
      'Checklist',
      'Findings (${inspection.findings.length})',
      'Evidence ($evidenceCount)',
      'Notes',
    ];

    return Column(
      children: [
        Expanded(
          child: ResponsiveContent(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                SizedBox(
                  height: 190,
                  child: AppImage(
                    inspection.siteCoverImageUrl,
                    placeholderIcon: LucideIcons.building2,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        inspection.siteName,
                        style: TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.w700,
                          color: p.textPrimary,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        inspection.templateName,
                        style: TextStyle(fontSize: 15, color: p.textSecondary),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          StatusBadge(
                            // One colour per status everywhere (QC-059).
                            style: StatusStyle.forInspectionStatus(
                              inspection.status,
                            ),
                            showIcon: true,
                            large: true,
                          ),
                          const Spacer(),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '${inspection.completedItemCount} / ${inspection.totalItemCount}',
                                style: TextStyle(
                                  fontSize: 19,
                                  fontWeight: FontWeight.w700,
                                  color: p.textPrimary,
                                ),
                              ),
                              Text(
                                'Progress',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: p.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SurfaceCard(
                        padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
                        child: Column(
                          children: [
                            _InfoRow(
                              icon: LucideIcons.userRound,
                              label: 'Customer',
                              value: inspection.customerName,
                            ),
                            _InfoRow(
                              icon: LucideIcons.userRound,
                              label: 'Inspector',
                              value: inspection.inspectorName,
                            ),
                            if (date != null)
                              _InfoRow(
                                icon: LucideIcons.calendarDays,
                                label: 'Date',
                                value: relativeDateTimeComma(date),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 42,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: tabs.length,
                          separatorBuilder: (_, _) => const SizedBox(width: 6),
                          itemBuilder: (context, i) => _PillTab(
                            label: tabs[i],
                            selected: _tab == i,
                            onTap: () => setState(() => _tab = i),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      switch (_tab) {
                        0 => _ChecklistSummary(inspection: inspection),
                        1 => FindingsView(
                          inspection: inspection,
                          embedded: true,
                        ),
                        2 => EvidenceView(inspection: inspection),
                        _ => NotesView(inspection: inspection),
                      },
                      if (inspection.status != InspectionStatus.draft) ...[
                        const SizedBox(height: 16),
                        SurfaceCard(
                          onTap: () => context.go(
                            '/inspections/${inspection.id}/comparison',
                          ),
                          padding: const EdgeInsets.all(14),
                          child: Row(
                            children: [
                              const IconTile(
                                icon: LucideIcons.gitCompareArrows,
                                tone: Tone.blue,
                                size: 40,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Previous Inspection Comparison',
                                      style: TextStyle(
                                        fontSize: 14.5,
                                        fontWeight: FontWeight.w600,
                                        color: p.textPrimary,
                                      ),
                                    ),
                                    Text(
                                      'Before & after, plus site history',
                                      style: TextStyle(
                                        fontSize: 12.5,
                                        color: p.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                LucideIcons.chevronRight,
                                size: 18,
                                color: p.textMuted,
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            color: p.background,
            border: Border(top: BorderSide(color: p.border)),
          ),
          // On tablets there is no bottom nav to absorb the home-indicator
          // inset, so the button must stay clear of it (QC-039). On phones
          // the shell's Scaffold already removed that padding.
          child: SafeArea(
            top: false,
            child: ResponsiveContent(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                child: SizedBox(
                  width: double.infinity,
                  child:
                      !_canWrite &&
                          inspection.status != InspectionStatus.completed
                      ? _ViewOnlyNote(inspectorName: inspection.inspectorName)
                      : ElevatedButton(
                          onPressed: _starting ? null : _primaryAction,
                          child: _starting
                              ? const SizedBox.square(
                                  dimension: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(_ctaLabel),
                        ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: p.textSecondary),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 12.5, color: p.textMuted),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(fontSize: 14.5, color: p.textPrimary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PillTab extends StatelessWidget {
  const _PillTab({
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
    return Semantics(
      selected: selected,
      button: true,
      child: Material(
        color: selected ? p.primarySoft : p.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: selected ? Colors.transparent : p.border),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 11),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                    color: selected ? p.primary : p.textSecondary,
                  ),
                ),
                const Spacer(),
                Container(
                  height: 2.5,
                  width: 34,
                  decoration: BoxDecoration(
                    color: selected ? p.primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 4),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ChecklistSummary extends ConsumerWidget {
  const _ChecklistSummary({required this.inspection});
  final Inspection inspection;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.palette;
    if (inspection.items.isEmpty) {
      return SurfaceCard(
        child: Text(
          'Checklist has not been generated yet.',
          style: TextStyle(color: p.textSecondary),
        ),
      );
    }
    final template = ref
        .watch(templateByIdProvider(inspection.templateId))
        .value;
    final groups = <(String, List<InspectionItem>)>[];
    if (template != null) {
      for (final section in template.sections) {
        final ids = section.items.map((i) => i.id).toSet();
        final items = inspection.items
            .where((i) => ids.contains(i.templateChecklistItemId))
            .toList();
        if (items.isNotEmpty) groups.add((section.title, items));
      }
    }
    if (groups.isEmpty) groups.add(('Checklist', inspection.items));

    return Column(
      children: [
        for (final (title, items) in groups) ...[
          SurfaceCard(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: p.textPrimary,
                        ),
                      ),
                    ),
                    Text(
                      '${items.where((i) => i.result != null).length} / ${items.length}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: p.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                for (final item in items)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.label,
                            style: TextStyle(
                              fontSize: 14,
                              color: p.textPrimary,
                            ),
                          ),
                        ),
                        if (item.result != null)
                          StatusBadge(
                            style: StatusStyle.forChecklistResult(item.result!),
                            showIcon: true,
                          )
                        else
                          Text(
                            'Pending',
                            style: TextStyle(fontSize: 12, color: p.textMuted),
                          ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}

/// Shown instead of Start/Continue on another inspector's inspection.
class _ViewOnlyNote extends StatelessWidget {
  const _ViewOnlyNote({required this.inspectorName});
  final String inspectorName;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      constraints: const BoxConstraints(minHeight: 50),
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: p.surfaceAlt,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        'View only · assigned to $inspectorName',
        textAlign: TextAlign.center,
        style: TextStyle(color: p.textSecondary, fontWeight: FontWeight.w600),
      ),
    );
  }
}
