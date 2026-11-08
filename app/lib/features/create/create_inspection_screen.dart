import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../app/providers/auth_providers.dart';
import '../../app/providers/inspection_providers.dart';
import '../../app/providers/repository_providers.dart';
import '../../app/providers/site_providers.dart';
import '../../app/providers/template_providers.dart';
import '../../app/theme/app_colors.dart';
import '../../core/widgets/app_image.dart';
import '../../core/widgets/responsive_content.dart';
import '../../core/widgets/surfaces.dart';
import '../../data/models/enums.dart';
import '../../data/models/inspection_template.dart';
import '../../data/models/site.dart';
import '../../data/services/location_service.dart';

class CreateInspectionScreen extends ConsumerStatefulWidget {
  const CreateInspectionScreen({super.key});

  @override
  ConsumerState<CreateInspectionScreen> createState() =>
      _CreateInspectionScreenState();
}

class _CreateInspectionScreenState
    extends ConsumerState<CreateInspectionScreen> {
  final _templatesKey = GlobalKey();
  String? _siteId;
  String? _templateId;
  bool _scheduleLater = false;
  DateTime _when = DateTime.now().add(const Duration(days: 1));
  RecurrenceType _recurrence = RecurrenceType.oneTime;
  bool _saving = false;
  String? _lastView;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final view = GoRouterState.of(context).uri.queryParameters['view'];
    if (view == 'templates' && view != _lastView) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final ctx = _templatesKey.currentContext;
        if (ctx != null) {
          Scrollable.ensureVisible(
            ctx,
            duration: const Duration(milliseconds: 300),
          );
        }
      });
    }
    _lastView = view;
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _when,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 730)),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_when),
    );
    if (time == null) return;
    setState(
      () => _when = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      ),
    );
  }

  Future<void> _submit(List<Site> sites) async {
    final auth = ref.read(authStateProvider);
    final site = sites.where((s) => s.id == _siteId).firstOrNull;
    if (auth is! AuthLoggedIn || site == null || _templateId == null) return;
    setState(() => _saving = true);
    final repo = ref.read(inspectionRepositoryProvider);
    final container = ProviderScope.containerOf(context, listen: false);
    final created = await repo.create(
      templateId: _templateId!,
      siteId: site.id,
      customerId: site.customerId,
      inspectorId: auth.user.id,
      recurrence: _recurrence,
      scheduledAt: _scheduleLater ? _when : null,
    );
    final inspection = created.dataOrNull;
    if (inspection == null) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              created.when(
                success: (_) => 'Could not create the inspection.',
                failure: (f) => f.message,
              ),
            ),
          ),
        );
      }
      return;
    }
    final startNow = !_scheduleLater;
    String? startError;
    if (startNow) {
      final location = await LocationService().getCurrentLocation();
      final started = await repo.start(
        inspection.id,
        locationLat: location is LocationSuccess ? location.latitude : null,
        locationLng: location is LocationSuccess ? location.longitude : null,
      );
      startError = started.when(
        success: (_) => null,
        failure: (f) => f.message,
      );
    }
    container.invalidateInspection(inspection.id);
    if (!mounted) return;
    setState(() {
      _saving = false;
      _siteId = null;
      _templateId = null;
    });
    context.go('/inspections/${inspection.id}');
    if (startError != null) {
      // Created but not started: say why and stay on the detail screen,
      // where it can be started again (QC-035).
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Inspection created, but not started: $startError'),
        ),
      );
    } else if (startNow) {
      context.push('/checklist/${inspection.id}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final sitesAsync = ref.watch(siteListProvider);
    final templatesAsync = ref.watch(templateListProvider);
    final sites = sitesAsync.value ?? const <Site>[];

    return Scaffold(
      body: SafeArea(
        child: ResponsiveContent(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
            children: [
              Text(
                'New Inspection',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: p.textPrimary,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Pick a site and template, then start now or schedule it.',
                style: TextStyle(fontSize: 14, color: p.textSecondary),
              ),
              const SizedBox(height: 18),
              SurfaceCard(
                color: p.primarySoft,
                onTap: () => context.push('/qr-scanner'),
                child: Row(
                  children: [
                    IconTile(
                      icon: LucideIcons.scanLine,
                      tone: Tone.blue,
                      solid: true,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Scan Site QR Code',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: p.textPrimary,
                            ),
                          ),
                          Text(
                            'Identify the site instantly on location',
                            style: TextStyle(
                              fontSize: 13,
                              color: p.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(LucideIcons.chevronRight, color: p.primary, size: 20),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              const SectionTitle('Site'),
              const SizedBox(height: 10),
              sitesAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => InlineError(
                  message: 'Could not load sites.',
                  onRetry: () => ref.invalidate(siteListProvider),
                ),
                data: (list) => list.isEmpty
                    ? Text(
                        'No sites yet. Ask your admin to add one.',
                        style: TextStyle(color: p.textSecondary),
                      )
                    : Column(
                        children: [
                          for (final s in list) ...[
                            _SelectRow(
                              selected: _siteId == s.id,
                              onTap: () => setState(() => _siteId = s.id),
                              leading: ClipOval(
                                child: SizedBox.square(
                                  dimension: 42,
                                  child: AppImage(
                                    s.coverImageUrl,
                                    placeholderIcon: LucideIcons.building2,
                                  ),
                                ),
                              ),
                              title: s.name,
                              subtitle: s.customerName ?? s.address ?? '',
                            ),
                            const SizedBox(height: 8),
                          ],
                        ],
                      ),
              ),
              const SizedBox(height: 16),
              SectionTitle('Template', key: _templatesKey),
              const SizedBox(height: 10),
              templatesAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => InlineError(
                  message: 'Could not load templates.',
                  onRetry: () => ref.invalidate(templateListProvider),
                ),
                data: (list) => list.isEmpty
                    ? Text(
                        'No active templates yet. Ask your admin to add one.',
                        style: TextStyle(color: p.textSecondary),
                      )
                    : Column(
                        children: [
                          for (final t in list) ...[
                            _SelectRow(
                              selected: _templateId == t.id,
                              onTap: () => setState(() => _templateId = t.id),
                              leading: IconTile(
                                icon: templateIcon(t),
                                tone: Tone.blue,
                                size: 42,
                              ),
                              title: t.name,
                              subtitle: templateCounts(t),
                            ),
                            const SizedBox(height: 8),
                          ],
                        ],
                      ),
              ),
              const SizedBox(height: 16),
              const SectionTitle('When'),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _Choice(
                      label: 'Start now',
                      icon: LucideIcons.circlePlay,
                      selected: !_scheduleLater,
                      onTap: () => setState(() => _scheduleLater = false),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _Choice(
                      label: 'Schedule',
                      icon: LucideIcons.calendarClock,
                      selected: _scheduleLater,
                      onTap: () => setState(() => _scheduleLater = true),
                    ),
                  ),
                ],
              ),
              if (_scheduleLater) ...[
                const SizedBox(height: 10),
                SurfaceCard(
                  onTap: _pickDateTime,
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      Icon(
                        LucideIcons.calendarDays,
                        color: p.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          DateFormat('EEE, MMM d, yyyy · HH:mm').format(_when),
                          style: TextStyle(
                            fontSize: 14.5,
                            color: p.textPrimary,
                          ),
                        ),
                      ),
                      Text(
                        'Change',
                        style: TextStyle(
                          color: p.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 16),
              const SectionTitle('Repeat'),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final r in RecurrenceType.values)
                    ChoiceChip(
                      label: Text(r.label),
                      selected: _recurrence == r,
                      showCheckmark: false,
                      onSelected: (_) => setState(() => _recurrence = r),
                      labelStyle: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: _recurrence == r
                            ? Colors.white
                            : p.textSecondary,
                      ),
                      selectedColor: p.primary,
                      backgroundColor: p.surfaceAlt,
                      side: BorderSide.none,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _siteId != null && _templateId != null && !_saving
                    ? () => _submit(sites)
                    : null,
                child: _saving
                    ? const SizedBox.square(
                        dimension: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        _scheduleLater
                            ? 'Schedule Inspection'
                            : 'Start Inspection',
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

IconData templateIcon(InspectionTemplate t) => switch (t.category) {
  'safety' => LucideIcons.shieldCheck,
  'property' => LucideIcons.building2,
  'equipment' => LucideIcons.wrench,
  _ => LucideIcons.truck,
};

String templateCounts(InspectionTemplate t) {
  final items = t.sections.fold<int>(0, (n, s) => n + s.items.length);
  final sections = t.sections.length;
  return '$items items · $sections section${sections == 1 ? '' : 's'}';
}

class _SelectRow extends StatelessWidget {
  const _SelectRow({
    required this.selected,
    required this.onTap,
    required this.leading,
    required this.title,
    required this.subtitle,
  });

  final bool selected;
  final VoidCallback onTap;
  final Widget leading;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Semantics(
      selected: selected,
      button: true,
      label: '$title, $subtitle',
      excludeSemantics: true,
      child: Material(
        color: selected ? p.primarySoft : p.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: selected ? p.primary : p.border),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                leading,
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w600,
                          color: p.textPrimary,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12.5,
                          color: p.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  selected ? LucideIcons.circleCheck : LucideIcons.circle,
                  size: 20,
                  color: selected ? p.primary : p.textMuted,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Choice extends StatelessWidget {
  const _Choice({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
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
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: selected ? p.primary : p.border),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 18,
                  color: selected ? p.primary : p.textSecondary,
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: selected ? p.primary : p.textSecondary,
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
