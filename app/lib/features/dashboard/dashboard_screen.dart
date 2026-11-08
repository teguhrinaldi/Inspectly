import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../app/providers/auth_providers.dart';
import '../../app/providers/inspection_providers.dart';
import '../../app/theme/app_colors.dart';
import '../../core/widgets/app_image.dart';
import '../../core/widgets/responsive_content.dart';
import '../../core/widgets/surfaces.dart';
import '../../data/models/app_user.dart';
import '../../data/models/enums.dart';
import '../../data/models/inspection.dart';
import '../../data/repositories/inspection_repository.dart';
import '../../data/services/notification_service.dart';
import '../inspections/widgets/inspection_row.dart';
import 'home_data.dart';
import 'tablet_home.dart';
import '../../core/errors/failure.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  /// Content width from which Home uses the tablet composition.
  static const tabletMinWidth = 680.0;

  /// Reminders for every SCHEDULED inspection: fires the evening before, at
  /// 18:00. Re-scheduling on every refresh is cheap — the same notification
  /// id replaces the pending alarm. Best-effort: never allowed to break the
  /// dashboard (no plugin in widget tests; permission may be denied).
  Future<void> _scheduleReminders(List<Inspection> all) async {
    try {
      final granted = await NotificationService.instance.requestPermission();
      if (!granted) return;
      final plan = reminderPlan(all);
      for (final inspection in all) {
        final remindAt = plan.schedule[inspection.id];
        if (remindAt == null) continue;
        await NotificationService.instance.scheduleInspectionReminder(
          inspection: inspection,
          remindAt: remindAt,
        );
      }
      for (final id in plan.cancel) {
        await NotificationService.instance.cancelReminder(id);
      }
    } catch (e) {
      debugPrint('DashboardScreen: could not schedule reminders. $e');
    }
  }

  static String _greeting(DateTime now) => now.hour < 12
      ? 'Good morning,'
      : now.hour < 18
      ? 'Good afternoon,'
      : 'Good evening,';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final user = authState is AuthLoggedIn ? authState.user : null;
    final inspectionsAsync = ref.watch(
      inspectionListProvider(const InspectionListFilter()),
    );

    return Scaffold(
      body: SafeArea(
        child: inspectionsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, st) => EmptyState(
            icon: LucideIcons.cloudOff,
            title: 'Could not load inspections',
            message: userMessage(err),
            action: OutlinedButton(
              onPressed: () => ref.invalidate(inspectionListProvider),
              child: const Text('Try again'),
            ),
          ),
          data: (all) {
            _scheduleReminders(all);
            final now = DateTime.now();
            final home = HomeData(all, user?.id, now: now);

            return RefreshIndicator(
              onRefresh: () async => ref.invalidate(inspectionListProvider),
              child: LayoutBuilder(
                builder: (context, constraints) =>
                    ResponsiveContent.isTablet(context) &&
                        constraints.maxWidth >= tabletMinWidth
                    ? TabletHome(
                        data: home,
                        user: user,
                        greeting: _greeting(now),
                        onBranch: (index) =>
                            StatefulNavigationShell.of(context).goBranch(index),
                      )
                    : _PhoneHome(
                        home: home,
                        user: user,
                        greeting: _greeting(now),
                      ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _PhoneHome extends StatelessWidget {
  const _PhoneHome({
    required this.home,
    required this.user,
    required this.greeting,
  });

  final HomeData home;
  final AppUser? user;
  final String greeting;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final upcoming = home.upcoming;
    return ResponsiveContent(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      greeting,
                      style: TextStyle(fontSize: 15, color: p.textSecondary),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${user?.name ?? ''} 👋',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: p.textPrimary,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => StatefulNavigationShell.of(context).goBranch(4),
                child: AppAvatar(
                  url: user?.avatarUrl,
                  name: user?.name ?? '',
                  size: 44,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const SectionTitle("Today's Inspections"),
          const SizedBox(height: 12),
          Row(
            children: [
              _CountTile(
                count: home.countMine(InspectionStatus.scheduled),
                label: 'Scheduled',
                tone: Tone.blue,
              ),
              const SizedBox(width: 10),
              _CountTile(
                count: home.countMine(InspectionStatus.inProgress),
                label: 'In Progress',
                tone: Tone.teal,
              ),
              const SizedBox(width: 10),
              _CountTile(
                count: home.openFindingsMine,
                label: 'Open Findings',
                tone: Tone.orange,
              ),
            ],
          ),
          const SizedBox(height: 24),
          const SectionTitle('Quick Actions'),
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
                label: 'New\nInspection',
                onTap: () => StatefulNavigationShell.of(context).goBranch(2),
              ),
              _QuickAction(
                icon: LucideIcons.clipboardList,
                label: 'Templates',
                onTap: () => context.go('/create?view=templates'),
              ),
              _QuickAction(
                icon: LucideIcons.fileText,
                label: 'Reports',
                onTap: () => StatefulNavigationShell.of(context).goBranch(3),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const SectionTitle('Upcoming Inspections'),
          const SizedBox(height: 12),
          if (upcoming.isEmpty)
            SurfaceCard(
              child: Text(
                'No upcoming inspections.',
                style: TextStyle(color: p.textSecondary),
              ),
            )
          else
            for (final i in upcoming.take(5)) ...[
              InspectionRow(
                inspection: i,
                onTap: () => context.go('/inspections/${i.id}'),
              ),
              const SizedBox(height: 10),
            ],
        ],
      ),
    );
  }
}

class _CountTile extends StatelessWidget {
  const _CountTile({
    required this.count,
    required this.label,
    required this.tone,
  });

  final int count;
  final String label;
  final Tone tone;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final fg = p.fg(tone);
    return Expanded(
      child: Semantics(
        label: '$count $label',
        excludeSemantics: true,
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 14, 10, 14),
          decoration: BoxDecoration(
            color: p.tint(tone),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$count',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: fg,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                  color: fg,
                ),
              ),
            ],
          ),
        ),
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
        label: label.replaceAll('\n', ' '),
        excludeSemantics: true,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(
              children: [
                Container(
                  width: 62,
                  height: 62,
                  decoration: BoxDecoration(
                    color: p.surfaceAlt,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: p.border),
                  ),
                  alignment: Alignment.center,
                  child: Icon(icon, color: p.primary, size: 26),
                ),
                const SizedBox(height: 8),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12.5,
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

/// Which inspections get a reminder (the evening before, 18:00) and which
/// must lose theirs because they were started, completed or unscheduled
/// since — otherwise a stale reminder still fires (QC-040).
({Map<String, DateTime> schedule, List<String> cancel}) reminderPlan(
  List<Inspection> all,
) {
  final schedule = <String, DateTime>{};
  final cancel = <String>[];
  for (final inspection in all) {
    final at = inspection.scheduledAt;
    if (inspection.status == InspectionStatus.scheduled && at != null) {
      schedule[inspection.id] = DateTime(at.year, at.month, at.day - 1, 18);
    } else {
      cancel.add(inspection.id);
    }
  }
  return (schedule: schedule, cancel: cancel);
}
