import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../app/providers/inspection_providers.dart';
import '../../app/theme/app_colors.dart';
import '../../core/utils/date_labels.dart';
import '../../core/widgets/responsive_content.dart';
import '../../core/widgets/surfaces.dart';
import '../../data/models/enums.dart';
import '../../data/models/inspection.dart';
import '../../data/repositories/inspection_repository.dart';
import 'widgets/inspection_row.dart';
import '../../core/errors/failure.dart';

class InspectionListScreen extends ConsumerStatefulWidget {
  const InspectionListScreen({super.key});

  @override
  ConsumerState<InspectionListScreen> createState() =>
      _InspectionListScreenState();
}

class _InspectionListScreenState extends ConsumerState<InspectionListScreen> {
  static const _filters = [
    InspectionStatus.scheduled,
    InspectionStatus.inProgress,
    InspectionStatus.review,
    InspectionStatus.completed,
    InspectionStatus.draft,
  ];

  InspectionStatus? _statusFilter;
  final _searchController = TextEditingController();
  String _search = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Upcoming work first (soonest first), then past inspections newest first.
  List<Inspection> _sorted(List<Inspection> items) {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    DateTime when(Inspection i) => displayDate(i) ?? DateTime(9999);
    final upcoming = items.where((i) => !when(i).isBefore(todayStart)).toList()
      ..sort((a, b) => when(a).compareTo(when(b)));
    final past = items.where((i) => when(i).isBefore(todayStart)).toList()
      ..sort((a, b) => when(b).compareTo(when(a)));
    return [...upcoming, ...past];
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final filter = InspectionListFilter(
      status: _statusFilter,
      search: _search.isEmpty ? null : _search,
    );
    final inspectionsAsync = ref.watch(inspectionListProvider(filter));

    return Scaffold(
      body: SafeArea(
        child: ResponsiveContent(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 12, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Inspections',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: p.textPrimary,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Scan site QR code',
                      icon: Icon(LucideIcons.scanLine, color: p.textPrimary),
                      onPressed: () => context.push('/qr-scanner'),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                child: TextField(
                  controller: _searchController,
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    hintText: 'Search inspections...',
                    prefixIcon: const Icon(LucideIcons.search, size: 20),
                    fillColor: p.surfaceAlt,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: p.primary),
                    ),
                  ),
                  onChanged: (value) => setState(() => _search = value),
                ),
              ),
              SizedBox(
                height: 62,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
                  children: [
                    _FilterChip(
                      label: 'All',
                      selected: _statusFilter == null,
                      onTap: () => setState(() => _statusFilter = null),
                    ),
                    for (final status in _filters)
                      Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: _FilterChip(
                          label: status.label,
                          selected: _statusFilter == status,
                          onTap: () => setState(() => _statusFilter = status),
                        ),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: inspectionsAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (err, st) => EmptyState(
                    icon: LucideIcons.cloudOff,
                    title: 'Could not load inspections',
                    message: userMessage(err),
                    action: RetryButton(
                      onPressed: () => ref.invalidate(inspectionListProvider),
                    ),
                  ),
                  data: (items) {
                    if (items.isEmpty) {
                      return EmptyState(
                        icon: LucideIcons.clipboardList,
                        title: 'No inspections found',
                        message: _search.isEmpty && _statusFilter == null
                            ? 'Scan a site QR code or create a new inspection.'
                            : 'Try a different search or filter.',
                      );
                    }
                    final sorted = _sorted(items);
                    return RefreshIndicator(
                      onRefresh: () async =>
                          ref.invalidate(inspectionListProvider),
                      child: ListView.separated(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                        itemCount: sorted.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final inspection = sorted[index];
                          return InspectionRow(
                            inspection: inspection,
                            leading: InspectionRowLeading.inspectorAvatar,
                            showChevron: true,
                            onTap: () =>
                                context.go('/inspections/${inspection.id}'),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
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
        color: selected ? p.primary : p.surfaceAlt,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Center(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  color: selected ? Colors.white : p.textSecondary,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
