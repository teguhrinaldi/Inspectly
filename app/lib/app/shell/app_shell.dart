import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/widgets/app_image.dart';
import '../../core/widgets/inspectly_logo.dart';
import '../../core/widgets/responsive_content.dart';
import '../../data/repositories/inspection_repository.dart';
import '../../features/dashboard/home_data.dart';
import '../providers/auth_providers.dart';
import '../providers/inspection_providers.dart';
import '../theme/app_colors.dart';

/// Phone: the five-item bottom bar. Tablet: a persistent navy sidebar
/// (docs/design/reference_a_tablet_admin.png) — a compact icon rail in
/// portrait, the full labelled sidebar in landscape.
class AppShell extends StatelessWidget {
  const AppShell({
    super.key,
    required this.navigationShell,
    required this.location,
  });

  final StatefulNavigationShell navigationShell;
  final Uri location;

  static const sidebarBreakpoint = 1000.0;

  static const _items = [
    (LucideIcons.house, 'Home'),
    (LucideIcons.clipboardPen, 'Inspections'),
    (LucideIcons.circlePlus, 'Create'),
    (LucideIcons.fileText, 'Reports'),
    (LucideIcons.user, 'Profile'),
  ];

  void _go(int index) => navigationShell.goBranch(
    index,
    initialLocation: index == navigationShell.currentIndex,
  );

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (ResponsiveContent.isTablet(context) &&
        width >= ResponsiveContent.tabletBreakpoint) {
      final isDark = context.palette.isDark;
      return Scaffold(
        body: Column(
          children: [
            // Navy band under the status bar (light icons) so the clock stays
            // readable across the navy sidebar and the light content.
            AnnotatedRegion<SystemUiOverlayStyle>(
              value: SystemUiOverlayStyle.light,
              child: Container(
                height: MediaQuery.paddingOf(context).top,
                color: isDark ? _Side.bgDark : _Side.bg,
              ),
            ),
            Expanded(
              child: MediaQuery.removePadding(
                context: context,
                removeTop: true,
                child: Row(
                  children: [
                    _TabletSidebar(
                      extended: width >= sidebarBreakpoint,
                      currentIndex: navigationShell.currentIndex,
                      location: location,
                      onBranch: _go,
                    ),
                    // Own semantics container: route barriers inside the
                    // branch navigators would otherwise block the sidebar
                    // painted before it.
                    Expanded(
                      child: Semantics(container: true, child: navigationShell),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    final p = context.palette;
    final current = navigationShell.currentIndex;
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: DecoratedBox(
        decoration: BoxDecoration(
          color: p.surface,
          border: Border(top: BorderSide(color: p.border)),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 64,
            child: Row(
              children: [
                for (final (index, (icon, label)) in _items.indexed)
                  Expanded(
                    child: _NavItem(
                      icon: icon,
                      label: label,
                      selected: index == current,
                      onTap: () => _go(index),
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

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final color = selected ? p.primary : p.textMuted;
    return Semantics(
      selected: selected,
      button: true,
      label: label,
      excludeSemantics: true,
      child: InkResponse(
        onTap: onTap,
        radius: 36,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 24, color: color),
            const SizedBox(height: 4),
            // One line that shrinks with large system fonts instead of
            // wrapping ("Inspectio/ns") and overflowing the 64px bar.
            Flexible(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    label,
                    maxLines: 1,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                      color: color,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Sidebar colors are fixed navy in both themes, like the admin panel.
class _Side {
  static const bg = AppColors.sidebar;
  static const bgDark = Color(0xFF0A1322);
  static const text = Color(0xFFC4CCE0);
  static const muted = Color(0xFF7F8BA6);
  static const card = Color(0xFF15233F);
  static const cardBorder = Color(0xFF22324F);
}

class _TabletSidebar extends ConsumerWidget {
  const _TabletSidebar({
    required this.extended,
    required this.currentIndex,
    required this.location,
    required this.onBranch,
  });

  final bool extended;
  final int currentIndex;
  final Uri location;
  final void Function(int branch) onBranch;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onTemplates =
        currentIndex == 2 && location.queryParameters['view'] == 'templates';
    final entries = <_SideEntry>[
      _SideEntry(
        LucideIcons.house,
        'Home',
        currentIndex == 0,
        () => onBranch(0),
      ),
      _SideEntry(
        LucideIcons.clipboardPen,
        'Inspections',
        currentIndex == 1,
        () => onBranch(1),
      ),
      _SideEntry(
        LucideIcons.circlePlus,
        'New Inspection',
        currentIndex == 2 && !onTemplates,
        () => context.go('/create'),
      ),
      _SideEntry(
        LucideIcons.clipboardList,
        'Templates',
        onTemplates,
        () => context.go('/create?view=templates'),
      ),
      _SideEntry(
        LucideIcons.fileText,
        'Reports',
        currentIndex == 3,
        () => onBranch(3),
      ),
      _SideEntry(
        LucideIcons.user,
        'Profile',
        currentIndex == 4,
        () => onBranch(4),
      ),
    ];

    final authState = ref.watch(authStateProvider);
    final user = authState is AuthLoggedIn ? authState.user : null;
    final active = ref
        .watch(inspectionListProvider(const InspectionListFilter()))
        .whenOrNull(data: (all) => HomeData(all, user?.id).activeInspection);
    final isDark = context.palette.isDark;

    return Container(
      width: extended ? 240 : 84,
      color: isDark ? _Side.bgDark : _Side.bg,
      child: SafeArea(
        right: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(extended ? 22 : 0, 22, 0, 26),
              child: Row(
                mainAxisAlignment: extended
                    ? MainAxisAlignment.start
                    : MainAxisAlignment.center,
                children: [
                  const InspectlyLogo(size: 30, color: Color(0xFF3B8BFF)),
                  if (extended) ...[
                    const SizedBox(width: 10),
                    const Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: InspectlyWordmark(
                          fontSize: 21,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            for (final e in entries)
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: extended ? 14 : 12,
                  vertical: 3,
                ),
                child: _SideItem(entry: e, extended: extended),
              ),
            const Spacer(),
            if (active != null)
              Padding(
                padding: EdgeInsets.fromLTRB(
                  extended ? 14 : 12,
                  0,
                  extended ? 14 : 12,
                  18,
                ),
                child: _ActiveSiteCard(
                  siteName: active.siteName,
                  extended: extended,
                  onTap: () => context.go('/inspections/${active.id}'),
                ),
              ),
            if (!extended && user != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 18),
                child: Center(
                  child: GestureDetector(
                    onTap: () => onBranch(4),
                    child: AppAvatar(
                      url: user.avatarUrl,
                      name: user.name,
                      size: 38,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SideEntry {
  const _SideEntry(this.icon, this.label, this.selected, this.onTap);
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
}

class _SideItem extends StatelessWidget {
  const _SideItem({required this.entry, required this.extended});

  final _SideEntry entry;
  final bool extended;

  @override
  Widget build(BuildContext context) {
    final selected = entry.selected;
    final fg = selected ? Colors.white : _Side.text;
    final item = Material(
      color: selected ? AppColors.primary : Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: entry.onTap,
        hoverColor: Colors.white.withValues(alpha: 0.06),
        child: SizedBox(
          height: extended ? 46 : 56,
          child: extended
              ? Row(
                  children: [
                    const SizedBox(width: 14),
                    Icon(entry.icon, size: 20, color: fg),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        entry.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: fg,
                          fontSize: 14.5,
                          fontWeight: selected
                              ? FontWeight.w600
                              : FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(entry.icon, size: 21, color: fg),
                    const SizedBox(height: 4),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          entry.label == 'New Inspection' ? 'New' : entry.label,
                          maxLines: 1,
                          style: TextStyle(
                            color: fg,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
    return Semantics(
      container: true,
      selected: selected,
      button: true,
      label: entry.label,
      excludeSemantics: true,
      child: extended ? item : Tooltip(message: entry.label, child: item),
    );
  }
}

/// Shortcut to the inspection in progress (derived from the loaded list).
class _ActiveSiteCard extends StatelessWidget {
  const _ActiveSiteCard({
    required this.siteName,
    required this.extended,
    required this.onTap,
  });

  final String siteName;
  final bool extended;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const pin = Icon(LucideIcons.mapPin, size: 20, color: Color(0xFF3B8BFF));
    return Semantics(
      button: true,
      label: 'Inspection in progress at $siteName',
      excludeSemantics: true,
      child: Material(
        color: _Side.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: _Side.cardBorder),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.all(extended ? 14 : 12),
            child: extended
                ? Row(
                    children: [
                      pin,
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'In progress at',
                              style: TextStyle(
                                color: _Side.muted,
                                fontSize: 11.5,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              siteName,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        LucideIcons.chevronRight,
                        size: 16,
                        color: _Side.muted,
                      ),
                    ],
                  )
                : const Center(child: pin),
          ),
        ),
      ),
    );
  }
}
