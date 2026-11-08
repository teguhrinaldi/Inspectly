import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../app/providers/inspection_providers.dart';
import '../../app/providers/repository_providers.dart';
import '../../app/providers/template_providers.dart';
import '../../app/theme/app_colors.dart';
import '../../core/widgets/responsive_content.dart';
import '../../core/widgets/status_style.dart';
import '../../core/widgets/surfaces.dart';
import '../../data/models/enums.dart';
import '../../data/models/inspection.dart';
import '../../data/models/inspection_item.dart';
import '../findings/finding_actions.dart';
import '../findings/widgets/finding_widgets.dart';
import 'widgets/finding_form_sheet.dart';
import '../../core/errors/failure.dart';
import '../../app/providers/permissions.dart';
import '../../app/providers/auth_providers.dart';

/// One checklist item per page: result, photos and note, with
/// Previous / Next. Finishing hands over to the signature step.
class ChecklistScreen extends ConsumerWidget {
  const ChecklistScreen({super.key, required this.inspectionId});
  final String inspectionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inspectionAsync = ref.watch(inspectionByIdProvider(inspectionId));
    return Scaffold(
      appBar: ScreenHeader(
        title: 'Checklist',
        onBack: () => context.canPop()
            ? context.pop()
            : context.go('/inspections/$inspectionId'),
      ),
      body: inspectionAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, st) => EmptyState(
          icon: LucideIcons.cloudOff,
          title: 'Could not load checklist',
          message: userMessage(err),
          action: RetryButton(
            onPressed: () =>
                ref.invalidate(inspectionByIdProvider(inspectionId)),
          ),
        ),
        data: (inspection) => inspection.items.isEmpty
            ? const EmptyState(
                icon: LucideIcons.listChecks,
                title: 'No checklist items',
                message: 'This inspection has no checklist generated yet.',
              )
            : _Wizard(inspection: inspection),
      ),
    );
  }
}

class _Wizard extends ConsumerStatefulWidget {
  const _Wizard({required this.inspection});
  final Inspection inspection;

  @override
  ConsumerState<_Wizard> createState() => _WizardState();
}

class _WizardState extends ConsumerState<_Wizard> {
  late int _index;
  final _noteController = TextEditingController();
  final Map<String, ChecklistResult> _pending = {};
  bool _busy = false;
  bool _navigating = false;

  Inspection get inspection => widget.inspection;
  List<InspectionItem> get items =>
      [...inspection.items]..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  InspectionItem get item => items[_index];

  @override
  void initState() {
    super.initState();
    final firstOpen = items.indexWhere((i) => i.result == null);
    _index = firstOpen == -1 ? 0 : firstOpen;
    _noteController.text = item.note ?? '';
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  bool get _editable =>
      canWriteInspection(ref.read(authStateProvider), inspection) &&
      (inspection.status == InspectionStatus.inProgress ||
          inspection.status == InspectionStatus.review);

  Future<void> _saveNote() async {
    final text = _noteController.text.trim();
    if (!_editable || text == (item.note ?? '')) return;
    // Also runs when the screen is being left (focus lost on unmount), so
    // everything needed after the await is captured first.
    final repo = ref.read(inspectionRepositoryProvider);
    final container = ProviderScope.containerOf(context, listen: false);
    final messenger = ScaffoldMessenger.maybeOf(context);
    final result = await repo.updateChecklistItem(
      inspectionId: inspection.id,
      itemId: item.id,
      note: text,
    );
    if (!result.isSuccess) {
      messenger?.showSnackBar(
        const SnackBar(content: Text('Could not save the note.')),
      );
    }
    container.invalidateInspection(inspection.id);
  }

  Future<void> _select(ChecklistResult result) async {
    if (!_editable || _busy) return;
    final current = _pending[item.id] ?? item.result;
    if (current == result) return;
    final target = item;
    // Busy from the first tap: a Fail tapped again while the finding (and
    // its photos) is still uploading must not open a second form (QC-032).
    setState(() => _busy = true);
    try {
      if (result == ChecklistResult.fail) {
        final saved = await addFindingFlow(
          context,
          ref,
          inspection,
          itemId: target.id,
          itemLabel: target.label,
        );
        if (!saved || !mounted) return;
      }
      setState(() => _pending[target.id] = result);
      final repo = ref.read(inspectionRepositoryProvider);
      final container = ProviderScope.containerOf(context, listen: false);
      final res = await repo.updateChecklistItem(
        inspectionId: inspection.id,
        itemId: target.id,
        result: result,
      );
      container.invalidateInspection(inspection.id);
      if (!mounted) return;
      if (res.dataOrNull == null) {
        setState(() => _pending.remove(target.id));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not save this answer.')),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _go(int delta) async {
    // A second tap while the note is still saving would otherwise advance
    // from the already-advanced index and skip an item (QC-032).
    if (_navigating) return;
    final next = _index + delta;
    _navigating = true;
    try {
      await _saveNote();
    } finally {
      _navigating = false;
    }
    if (!mounted) return;
    if (next >= items.length) {
      final unanswered = items
          .where((i) => (_pending[i.id] ?? i.result) == null)
          .length;
      if (unanswered > 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '$unanswered item${unanswered == 1 ? '' : 's'} still need an answer.',
            ),
          ),
        );
        setState(() {
          _index = items.indexWhere(
            (i) => (_pending[i.id] ?? i.result) == null,
          );
          _noteController.text = item.note ?? '';
        });
        return;
      }
      context.go('/inspections/${inspection.id}/signature');
      return;
    }
    setState(() {
      _index = next.clamp(0, items.length - 1);
      _noteController.text = item.note ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final current = item;
    final result = _pending[current.id] ?? current.result;
    final template = ref
        .watch(templateByIdProvider(inspection.templateId))
        .value;
    final requiresEvidence =
        template?.sections
            .expand((s) => s.items)
            .where((t) => t.id == current.templateChecklistItemId)
            .firstOrNull
            ?.requiresEvidence ??
        false;
    final isLast = _index == items.length - 1;

    return Column(
      children: [
        Expanded(
          child: ResponsiveContent(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
              children: [
                Text(
                  current.label,
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w700,
                    color: p.textPrimary,
                    letterSpacing: -0.4,
                  ),
                ),
                if (current.helpText != null) ...[
                  const SizedBox(height: 10),
                  Text(
                    current.helpText!,
                    style: TextStyle(
                      fontSize: 15.5,
                      color: p.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ],
                const SizedBox(height: 22),
                for (final r in ChecklistResult.values) ...[
                  _ResultOption(
                    result: r,
                    selected: result == r,
                    enabled: _editable,
                    onTap: () => _select(r),
                  ),
                  const SizedBox(height: 10),
                ],
                const SizedBox(height: 14),
                Row(
                  children: [
                    Text(
                      'Photo (${current.evidence.length})',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: p.textPrimary,
                      ),
                    ),
                    if (requiresEvidence) ...[
                      const SizedBox(width: 8),
                      StatusBadge(
                        style: StatusStyle(
                          icon: LucideIcons.camera,
                          tone: current.evidence.isEmpty
                              ? Tone.orange
                              : Tone.green,
                          label: 'Required',
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 92,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      for (final (i, e) in current.evidence.indexed) ...[
                        EvidenceThumb(
                          evidence: e,
                          size: 92,
                          gallery: current.evidence,
                          index: i,
                        ),
                        const SizedBox(width: 10),
                      ],
                      if (_editable)
                        AddPhotoTile(
                          size: 92,
                          width: 128,
                          onTap: () => addItemPhotoFlow(
                            context,
                            ref,
                            inspection,
                            current.id,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Note',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: p.textPrimary,
                  ),
                ),
                const SizedBox(height: 10),
                Focus(
                  onFocusChange: (focused) {
                    if (!focused) _saveNote();
                  },
                  child: TextField(
                    controller: _noteController,
                    enabled: _editable,
                    minLines: 3,
                    maxLines: 5,
                    decoration: const InputDecoration(
                      hintText: 'Add note (optional)...',
                    ),
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
          child: SafeArea(
            top: false,
            child: ResponsiveContent(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                child: Row(
                  children: [
                    Text(
                      '${_index + 1} / ${items.length}',
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w700,
                        color: p.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Right-aligned like before, but scaled down instead of
                    // overflowing on narrow phones with large text.
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  minimumSize: const Size(0, 50),
                                  side: BorderSide(color: p.border),
                                  foregroundColor: p.textPrimary,
                                ),
                                onPressed: _index == 0 ? null : () => _go(-1),
                                icon: const Icon(
                                  LucideIcons.arrowLeft,
                                  size: 18,
                                ),
                                label: const Text('Previous'),
                              ),
                              const SizedBox(width: 10),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  minimumSize: const Size(96, 50),
                                ),
                                onPressed: _busy ? null : () => _go(1),
                                child: Text(isLast ? 'Finish' : 'Next'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ResultOption extends StatelessWidget {
  const _ResultOption({
    required this.result,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  final ChecklistResult result;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final style = StatusStyle.forChecklistResult(result);
    final fg = p.fg(style.tone);
    return Semantics(
      inMutuallyExclusiveGroup: true,
      checked: selected,
      button: true,
      label: style.label,
      excludeSemantics: true,
      child: Material(
        color: selected ? p.tint(style.tone) : p.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(
            color: selected ? fg.withValues(alpha: 0.35) : p.border,
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: enabled ? onTap : null,
          child: SizedBox(
            height: 58,
            child: Row(
              children: [
                const SizedBox(width: 16),
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: selected ? fg : Colors.transparent,
                    border: Border.all(
                      color: selected ? fg : p.textMuted,
                      width: 2,
                    ),
                  ),
                  child: selected
                      ? const Icon(
                          LucideIcons.check,
                          size: 14,
                          color: Colors.white,
                        )
                      : null,
                ),
                const SizedBox(width: 18),
                Text(
                  style.label,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                    color: selected ? fg : p.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
