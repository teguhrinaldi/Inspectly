import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../app/theme/app_colors.dart';
import '../../core/utils/date_labels.dart';
import '../../core/widgets/app_image.dart';
import '../../core/widgets/status_style.dart';
import '../../core/widgets/surfaces.dart';
import '../../data/models/app_user.dart';
import '../../data/models/enums.dart';
import '../../data/models/inspection.dart';
import 'home_data.dart';

/// Inspector Home on tablets (docs/design/reference_a_tablet_admin.png, panel
/// 3): greeting, the inspection in progress as a hero with Continue, status
/// tiles, today's work, quick actions and recent reports. Same data as the
/// phone Home — only the composition differs.
class TabletHome extends StatelessWidget {
  const TabletHome({
    super.key,
    required this.data,
    required this.user,
    required this.greeting,
    required this.onBranch,
  });

  final HomeData data;
  final AppUser? user;
  final String greeting;
  final void Function(int branch) onBranch;

  /// Content width from which today's list sits beside the side column.
  static const wideMinWidth = 900.0;

  @override
  Widget build(BuildContext context) {
    final active = data.activeInspection;
    final next = active == null
        ? data.upcoming.where((i) => i.inspectorId == user?.id).firstOrNull
        : null;
    final heroInspection = active ?? next;

    return LayoutBuilder(
      builder: (context, constraints) {
        // Landscape: today's list beside quick actions + reports. Portrait
        // (narrower content next to the rail): stacked, three status tiles.
        final wide = constraints.maxWidth >= wideMinWidth;
        final tiles = <Widget>[
          _SummaryTile(
            icon: LucideIcons.calendarDays,
            count: data.countMine(InspectionStatus.scheduled),
            label: 'Scheduled',
            tone: Tone.blue,
            showChevron: wide,
            onTap: () => onBranch(1),
          ),
          _SummaryTile(
            icon: LucideIcons.play,
            count: data.countMine(InspectionStatus.inProgress),
            label: 'In Progress',
            tone: Tone.green,
            showChevron: wide,
            onTap: () => onBranch(1),
          ),
          _SummaryTile(
            icon: LucideIcons.clock,
            count: data.countMine(InspectionStatus.review),
            label: 'Needs Review',
            tone: Tone.orange,
            showChevron: wide,
            onTap: () => onBranch(1),
          ),
          if (wide) _ViewAllTile(onTap: () => onBranch(1)),
        ];
        final today = _TodayCard(
          inspections: data.today,
          onViewAll: () => onBranch(1),
        );
        final quick = _QuickActionsCard(onBranch: onBranch);
        final reports = _RecentReportsCard(
          reports: data.recentReports.take(3).toList(),
          onViewAll: () => onBranch(3),
        );

        return ListView(
          padding: const EdgeInsets.fromLTRB(28, 22, 28, 28),
          children: [
            _Header(user: user, greeting: greeting, onBranch: onBranch),
            const SizedBox(height: 20),
            if (heroInspection != null) ...[
              _HeroCard(inspection: heroInspection, isActive: active != null),
              const SizedBox(height: 16),
            ],
            SizedBox(
              height: 84,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final (i, tile) in tiles.indexed) ...[
                    if (i > 0) const SizedBox(width: 14),
                    tile,
                  ],
                ],
              ),
            ),
            const SizedBox(height: 22),
            if (wide)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 3, child: today),
                  const SizedBox(width: 18),
                  Expanded(
                    flex: 2,
                    child: Column(
                      children: [quick, const SizedBox(height: 16), reports],
                    ),
                  ),
                ],
              )
            else ...[
              today,
              const SizedBox(height: 16),
              quick,
              const SizedBox(height: 16),
              reports,
            ],
          ],
        );
      },
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.user,
    required this.greeting,
    required this.onBranch,
  });

  final AppUser? user;
  final String greeting;
  final void Function(int branch) onBranch;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                greeting,
                style: TextStyle(fontSize: 14, color: p.textSecondary),
              ),
              const SizedBox(height: 3),
              Text(
                '${user?.name ?? ''} 👋',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: p.textPrimary,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          tooltip: 'Search inspections',
          onPressed: () => onBranch(1),
          icon: Icon(LucideIcons.search, color: p.textPrimary, size: 22),
        ),
        const SizedBox(width: 10),
        GestureDetector(
          onTap: () => onBranch(4),
          child: AppAvatar(
            url: user?.avatarUrl,
            name: user?.name ?? '',
            size: 44,
          ),
        ),
      ],
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.inspection, required this.isActive});

  final Inspection inspection;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final total = inspection.totalItemCount;
    final done = inspection.completedItemCount;
    final fraction = total == 0 ? 0.0 : done / total;
    final status = StatusStyle.forInspectionStatus(inspection.status);
    final statusColor = Color.lerp(status.tone.fg, Colors.white, 0.2)!;
    final date = displayDate(inspection);

    void open() => isActive
        ? context.push('/checklist/${inspection.id}')
        : context.go('/inspections/${inspection.id}');

    return Semantics(
      container: true,
      label:
          '${inspection.siteName}, ${inspection.templateName}, ${status.label}, $done of $total items',
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: SizedBox(
          // 168 at normal text size; grows with large system fonts so the
          // title, subtitle and action row never overflow the card.
          height: 168 + MediaQuery.textScalerOf(context).scale(60) - 60,
          child: Stack(
            fit: StackFit.expand,
            children: [
              AppImage(
                inspection.siteCoverImageUrl,
                placeholderIcon: LucideIcons.building2,
              ),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xF50E1A33),
                      Color(0xD90E1A33),
                      Color(0x660E1A33),
                    ],
                    stops: [0, 0.45, 1],
                  ),
                ),
              ),
              Material(
                type: MaterialType.transparency,
                child: InkWell(
                  onTap: () => context.go('/inspections/${inspection.id}'),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          inspection.siteName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(text: '${inspection.templateName} · '),
                              TextSpan(
                                text: isActive
                                    ? status.label
                                    : 'Next · ${date == null ? '' : relativeDateTime(date)}',
                                style: TextStyle(
                                  color: statusColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.78),
                            fontSize: 13.5,
                          ),
                        ),
                        const Spacer(),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '$done / $total items',
                                    style: TextStyle(
                                      color: Colors.white.withValues(
                                        alpha: 0.85,
                                      ),
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            99,
                                          ),
                                          child: LinearProgressIndicator(
                                            value: fraction,
                                            minHeight: 8,
                                            color: AppColors.primary,
                                            backgroundColor: Colors.white
                                                .withValues(alpha: 0.18),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        '${(fraction * 100).round()}%',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 28),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size(132, 46),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: open,
                              child: Text(isActive ? 'Continue' : 'View'),
                            ),
                          ],
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
    );
  }
}

class _SummaryTile extends StatelessWidget {
  const _SummaryTile({
    required this.icon,
    required this.count,
    required this.label,
    required this.tone,
    required this.onTap,
    this.showChevron = true,
  });

  final IconData icon;
  final int count;
  final String label;
  final Tone tone;
  final VoidCallback onTap;
  final bool showChevron;

  @override
  Widget build(BuildContext context) {
    final bg = Color.lerp(tone.fg, AppColors.navy, 0.28)!;
    return Expanded(
      child: Semantics(
        button: true,
        label: '$count $label',
        excludeSemantics: true,
        child: Material(
          color: bg,
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Row(
                children: [
                  Icon(icon, color: Colors.white, size: 26),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$count',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            height: 1.1,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.88),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (showChevron)
                    Icon(
                      LucideIcons.chevronRight,
                      color: Colors.white.withValues(alpha: 0.7),
                      size: 18,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ViewAllTile extends StatelessWidget {
  const _ViewAllTile({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Expanded(
      child: Material(
        color: p.isDark ? p.surfaceAlt : p.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: p.border),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'View All',
                    style: TextStyle(
                      color: p.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Icon(LucideIcons.arrowRight, color: p.textPrimary, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CardHeader extends StatelessWidget {
  const _CardHeader(this.title, {this.onViewAll});

  final String title;
  final VoidCallback? onViewAll;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 15.5,
              fontWeight: FontWeight.w700,
              color: p.textPrimary,
            ),
          ),
        ),
        if (onViewAll != null)
          InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: onViewAll,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              child: Row(
                children: [
                  Text(
                    'View all',
                    style: TextStyle(
                      color: p.primary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(LucideIcons.arrowRight, size: 15, color: p.primary),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _TodayCard extends StatelessWidget {
  const _TodayCard({required this.inspections, required this.onViewAll});

  final List<Inspection> inspections;
  final VoidCallback onViewAll;

  static String _when(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final diff = DateTime(
      date.year,
      date.month,
      date.day,
    ).difference(today).inDays;
    return switch (diff) {
      0 => DateFormat('HH:mm').format(date),
      -1 => 'Yesterday',
      1 => 'Tomorrow',
      _ => DateFormat('MMM d').format(date),
    };
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final rows = inspections.take(6).toList();
    return SurfaceCard(
      padding: const EdgeInsets.fromLTRB(0, 16, 0, 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: _CardHeader("Today's Inspections", onViewAll: onViewAll),
          ),
          const SizedBox(height: 8),
          if (rows.isEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 16),
              child: Text(
                'Nothing due today.',
                style: TextStyle(color: p.textSecondary, fontSize: 13.5),
              ),
            ),
          for (final (index, i) in rows.indexed) ...[
            if (index > 0)
              Divider(height: 1, color: p.border, indent: 18, endIndent: 18),
            _TodayRow(inspection: i, when: _when),
          ],
        ],
      ),
    );
  }
}

class _TodayRow extends StatelessWidget {
  const _TodayRow({required this.inspection, required this.when});

  final Inspection inspection;
  final String Function(DateTime) when;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final date = inspection.status == InspectionStatus.completed
        ? inspection.completedAt
        : displayDate(inspection);
    final secondary = TextStyle(fontSize: 12.5, color: p.textSecondary);
    return Semantics(
      button: true,
      label:
          '${inspection.siteName}, ${inspection.templateName}, ${inspection.status.label}',
      excludeSemantics: true,
      child: InkWell(
        onTap: () => context.go('/inspections/${inspection.id}'),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 11, 12, 11),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(9),
                child: SizedBox(
                  width: 48,
                  height: 42,
                  child: AppImage(
                    inspection.siteCoverImageUrl,
                    placeholderIcon: LucideIcons.building2,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                flex: 5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      inspection.siteName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: p.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      inspection.templateName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: secondary,
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 3,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: StatusBadge(
                      style: StatusStyle.forInspectionStatus(inspection.status),
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  '${inspection.completedItemCount} / ${inspection.totalItemCount} items',
                  style: secondary,
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  date == null ? '—' : when(date),
                  textAlign: TextAlign.right,
                  style: secondary,
                ),
              ),
              const SizedBox(width: 10),
              Icon(LucideIcons.chevronRight, size: 18, color: p.textMuted),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickActionsCard extends StatelessWidget {
  const _QuickActionsCard({required this.onBranch});

  final void Function(int branch) onBranch;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _CardHeader('Quick Actions'),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _QuickAction(
                icon: LucideIcons.scanLine,
                label: 'Scan QR',
                onTap: () => context.push('/qr-scanner'),
              ),
              _QuickAction(
                icon: LucideIcons.circlePlus,
                label: 'New Inspection',
                onTap: () => context.go('/create'),
              ),
              _QuickAction(
                icon: LucideIcons.clipboardList,
                label: 'Templates',
                onTap: () => context.go('/create?view=templates'),
              ),
              _QuickAction(
                icon: LucideIcons.fileChartColumn,
                label: 'Reports',
                onTap: () => onBranch(3),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Expanded(
      child: Semantics(
        button: true,
        label: label,
        excludeSemantics: true,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: p.surfaceAlt,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: p.border),
                  ),
                  alignment: Alignment.center,
                  child: Icon(icon, color: p.primary, size: 23),
                ),
                const SizedBox(height: 8),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  style: TextStyle(
                    fontSize: 12,
                    color: p.textPrimary,
                    height: 1.25,
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

class _RecentReportsCard extends StatelessWidget {
  const _RecentReportsCard({required this.reports, required this.onViewAll});

  final List<Inspection> reports;
  final VoidCallback onViewAll;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return SurfaceCard(
      padding: const EdgeInsets.fromLTRB(16, 16, 10, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 6),
            child: _CardHeader('Recent Reports', onViewAll: onViewAll),
          ),
          const SizedBox(height: 6),
          if (reports.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Text(
                'Reports appear once an inspection is completed.',
                style: TextStyle(color: p.textSecondary, fontSize: 13),
              ),
            ),
          for (final r in reports)
            Semantics(
              button: true,
              label: 'Report for ${r.siteName}',
              excludeSemantics: true,
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () => context.push('/report/${r.id}'),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      const IconTile(
                        icon: LucideIcons.fileText,
                        tone: Tone.red,
                        size: 36,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              r.siteName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600,
                                color: p.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              DateFormat('MMM d, yyyy · HH:mm')
                                  .format(r.completedAt!),
                              style: TextStyle(
                                fontSize: 12,
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
              ),
            ),
        ],
      ),
    );
  }
}
