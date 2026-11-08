import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../app/providers/inspection_providers.dart';
import '../../app/providers/site_providers.dart';
import '../../app/theme/app_colors.dart';
import '../../core/utils/date_labels.dart';
import '../../core/utils/media_source.dart';
import '../../core/widgets/app_image.dart';
import '../../core/widgets/responsive_content.dart';
import '../../core/widgets/status_style.dart';
import '../../core/widgets/surfaces.dart';
import '../../data/models/enums.dart';
import '../../data/models/evidence.dart';
import '../../data/models/finding.dart';
import '../../data/models/inspection.dart';
import '../../data/models/site_history.dart';
import '../../core/errors/failure.dart';

/// Previous vs current findings for the same site + template, plus the
/// site's inspection history. Matching is deterministic (by checklist item).
class ComparisonScreen extends ConsumerWidget {
  const ComparisonScreen({super.key, required this.inspectionId});
  final String inspectionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.palette;
    final async = ref.watch(inspectionByIdProvider(inspectionId));
    return Scaffold(
      appBar: ScreenHeader(
        title: 'Previous Inspection Comparison',
        trailing: IconButton(
          tooltip: 'Close',
          icon: Icon(LucideIcons.x, color: p.textSecondary, size: 22),
          onPressed: () => context.go('/inspections/$inspectionId'),
        ),
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => EmptyState(
          icon: LucideIcons.cloudOff,
          title: 'Could not load inspection',
          message: userMessage(e),
        ),
        data: (current) => ResponsiveContent(child: _Body(current: current)),
      ),
    );
  }
}

class _Body extends ConsumerStatefulWidget {
  const _Body({required this.current});
  final Inspection current;

  @override
  ConsumerState<_Body> createState() => _BodyState();
}

class _BodyState extends ConsumerState<_Body> {
  int _selected = 0;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final current = widget.current;
    final comparisonAsync = ref.watch(
      siteComparisonProvider((
        siteId: current.siteId,
        inspectionId: current.id,
      )),
    );
    final historyAsync = ref.watch(siteHistoryProvider(current.siteId));

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
      children: [
        Text(
          current.siteName,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: p.textPrimary,
          ),
        ),
        const SizedBox(height: 14),
        comparisonAsync.when(
          loading: () => const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (e, _) => SurfaceCard(
            child: Text(
              'Could not load comparison.',
              style: TextStyle(color: p.textSecondary),
            ),
          ),
          data: (comparison) {
            if (comparison == null) {
              return SurfaceCard(
                child: Row(
                  children: [
                    const IconTile(icon: LucideIcons.history, tone: Tone.blue),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'No earlier completed ${current.templateName.toLowerCase()} at this site to compare with.',
                        style: TextStyle(color: p.textSecondary),
                      ),
                    ),
                  ],
                ),
              );
            }
            const order = [
              ComparisonState.stillOpen,
              ComparisonState.newFinding,
              ComparisonState.resolved,
            ];
            final sorted = comparison.copyWith(
              entries: [...comparison.entries]
                ..sort(
                  (a, b) =>
                      order.indexOf(a.state).compareTo(order.indexOf(b.state)),
                ),
            );
            return _ComparisonPanel(
              comparison: sorted,
              selected: comparison.entries.isEmpty
                  ? 0
                  : _selected.clamp(0, comparison.entries.length - 1),
              onSelect: (i) => setState(() => _selected = i),
            );
          },
        ),
        const SizedBox(height: 18),
        SurfaceCard(
          padding: const EdgeInsets.fromLTRB(14, 16, 14, 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Padding(
                padding: EdgeInsets.only(left: 4, bottom: 10),
                child: SectionTitle('Inspection History'),
              ),
              historyAsync.when(
                loading: () => const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (e, _) => Text(
                  'Could not load history.',
                  style: TextStyle(color: p.textSecondary),
                ),
                data: (entries) => Column(
                  children: [
                    for (final entry in entries)
                      _HistoryRow(
                        entry: entry,
                        highlighted: entry.inspectionId == current.id,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ComparisonPanel extends ConsumerWidget {
  const _ComparisonPanel({
    required this.comparison,
    required this.selected,
    required this.onSelect,
  });

  final SiteComparisonResult comparison;
  final int selected;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.palette;
    final prev = ref
        .watch(inspectionByIdProvider(comparison.previousInspectionId))
        .value;
    final curr = ref
        .watch(inspectionByIdProvider(comparison.currentInspectionId))
        .value;

    if (comparison.entries.isEmpty) {
      return SurfaceCard(
        child: Text(
          'No open findings in either inspection — nothing changed.',
          style: TextStyle(color: p.textSecondary),
        ),
      );
    }
    final entry = comparison.entries[selected];
    Finding? find(Inspection? i, String? id) =>
        i?.findings.where((f) => f.id == id).firstOrNull;
    final prevFinding = find(prev, entry.previousFindingId);
    final currFinding = find(curr, entry.currentFindingId);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: _DateHeader(
                label: 'Previous',
                date: comparison.previousDate,
                tone: Tone.green,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _DateHeader(
                label: 'Current',
                date: comparison.currentDate,
                tone: Tone.teal,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (comparison.entries.length > 1) ...[
          SizedBox(
            height: 38,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: comparison.entries.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final e = comparison.entries[i];
                final isSel = i == selected;
                return ChoiceChip(
                  selected: isSel,
                  showCheckmark: false,
                  onSelected: (_) => onSelect(i),
                  label: Text('${e.label} · ${e.state.label}'),
                  labelStyle: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: isSel ? Colors.white : p.textSecondary,
                  ),
                  selectedColor: p.primary,
                  backgroundColor: p.surfaceAlt,
                  side: BorderSide.none,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
        ],
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _SideCard(
                  title: entry.label,
                  inspection: prev,
                  finding: prevFinding,
                  overlay: entry.state,
                  onCompare: () =>
                      Navigator.of(context, rootNavigator: true).push(
                        MaterialPageRoute(
                          builder: (_) => _CompareViewer(
                            title: entry.label,
                            previous: prevFinding?.evidence.firstOrNull,
                            current: currFinding?.evidence.firstOrNull,
                            previousDate: comparison.previousDate,
                            currentDate: comparison.currentDate,
                            state: entry.state,
                          ),
                        ),
                      ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SideCard(
                  title: entry.label,
                  inspection: curr,
                  finding: currFinding,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DateHeader extends StatelessWidget {
  const _DateHeader({
    required this.label,
    required this.date,
    required this.tone,
  });

  final String label;
  final DateTime date;
  final Tone tone;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return SurfaceCard(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              color: p.tint(tone),
              shape: BoxShape.circle,
            ),
            child: Icon(LucideIcons.clock, size: 11, color: p.fg(tone)),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: '$label ',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: p.textPrimary,
                    ),
                  ),
                  TextSpan(
                    text: '(${shortDate(date)})',
                    style: TextStyle(color: p.textMuted),
                  ),
                ],
              ),
              style: const TextStyle(fontSize: 12.5),
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }
}

class _SideCard extends StatelessWidget {
  const _SideCard({
    required this.title,
    required this.inspection,
    required this.finding,
    this.overlay,
    this.onCompare,
  });

  final String title;
  final Inspection? inspection;
  final Finding? finding;
  final ComparisonState? overlay;
  final VoidCallback? onCompare;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final photo = finding?.evidence.firstOrNull;
    final item = inspection?.items
        .where((i) => i.id == finding?.inspectionItemId)
        .firstOrNull;
    final overlayTone = switch (overlay) {
      ComparisonState.stillOpen => Tone.coral,
      ComparisonState.newFinding => Tone.red,
      ComparisonState.resolved => Tone.green,
      null => null,
    };

    return SurfaceCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: p.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          AspectRatio(
            aspectRatio: 4 / 3,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (photo != null)
                    AppImage(photo.displaySource)
                  else
                    ColoredBox(
                      color: p.surfaceAlt,
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Text(
                            finding == null ? 'No open finding' : 'No photo',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 12, color: p.textMuted),
                          ),
                        ),
                      ),
                    ),
                  if (overlayTone != null)
                    Positioned(
                      left: 8,
                      bottom: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: overlayTone.fg,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          overlay!.label,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Status',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: p.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              if (item?.result != null)
                StatusBadge(
                  style: StatusStyle.forChecklistResult(item!.result!),
                  showIcon: true,
                ),
              StatusBadge(
                showIcon: true,
                style: finding == null
                    ? const StatusStyle(
                        icon: LucideIcons.circleCheck,
                        tone: Tone.green,
                        label: 'Clear',
                      )
                    : finding!.status == FindingStatus.open
                    ? const StatusStyle(
                        icon: LucideIcons.circleDot,
                        tone: Tone.orange,
                        label: 'Open',
                      )
                    : const StatusStyle(
                        icon: LucideIcons.circleCheck,
                        tone: Tone.green,
                        label: 'Resolved',
                      ),
              ),
            ],
          ),
          const Spacer(),
          const SizedBox(height: 12),
          if (onCompare != null)
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: p.primarySoft,
                minimumSize: const Size(0, 44),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: onCompare,
              child: const Text('Compare'),
            )
          else
            const SizedBox(height: 44),
        ],
      ),
    );
  }
}

class _HistoryRow extends StatelessWidget {
  const _HistoryRow({required this.entry, required this.highlighted});
  final SiteHistoryEntry entry;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final date = entry.completedAt;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: highlighted ? p.primarySoft : p.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: p.border),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => context.go('/inspections/${entry.inspectionId}'),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              children: [
                Icon(
                  entry.status == InspectionStatus.completed
                      ? LucideIcons.shieldCheck
                      : LucideIcons.clock,
                  size: 18,
                  color: p.primary,
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: 96,
                  child: Text(
                    date == null ? '—' : shortDate(date),
                    style: TextStyle(fontSize: 13, color: p.textSecondary),
                  ),
                ),
                Expanded(
                  child: Text(
                    entry.templateName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 13, color: p.textSecondary),
                  ),
                ),
                const SizedBox(width: 6),
                StatusBadge(
                  style: StatusStyle.forInspectionStatus(entry.status),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CompareViewer extends StatelessWidget {
  const _CompareViewer({
    required this.title,
    required this.previous,
    required this.current,
    required this.previousDate,
    required this.currentDate,
    required this.state,
  });

  final String title;
  final Evidence? previous;
  final Evidence? current;
  final DateTime previousDate;
  final DateTime currentDate;
  final ComparisonState state;

  @override
  Widget build(BuildContext context) {
    Widget pane(String label, DateTime date, Evidence? e) => Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Text(
              '$label · ${shortDate(date)}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: e == null
                ? const Center(
                    child: Text(
                      'No photo',
                      style: TextStyle(color: Colors.white54),
                    ),
                  )
                : InteractiveViewer(
                    child: AppImage(e.displaySource, fit: BoxFit.contain),
                  ),
          ),
        ],
      ),
    );

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text('$title · ${state.label}'),
      ),
      body: OrientationBuilder(
        builder: (context, o) {
          final panes = [
            pane('Previous', previousDate, previous),
            pane('Current', currentDate, current),
          ];
          return o == Orientation.portrait
              ? Column(children: panes)
              : Row(children: panes);
        },
      ),
    );
  }
}
