import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../app/providers/auth_providers.dart';
import '../../app/providers/inspection_providers.dart';
import '../../app/providers/repository_providers.dart';
import '../../app/providers/theme_providers.dart';
import '../../app/theme/app_colors.dart';
import '../../core/network/api_client.dart';
import '../../core/widgets/app_image.dart';
import '../../core/widgets/responsive_content.dart';
import '../../core/widgets/surfaces.dart';
import '../../data/models/enums.dart';
import '../../data/repositories/inspection_repository.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.palette;
    final authState = ref.watch(authStateProvider);
    final themeMode = ref.watch(themeModeProvider);
    if (authState is! AuthLoggedIn) return const SizedBox.shrink();
    final user = authState.user;
    final mineAsync = ref.watch(
      inspectionListProvider(InspectionListFilter(inspectorId: user.id)),
    );
    final mine = mineAsync.value ?? const [];
    // Until the counts are known (loading/failed) show a dash, not "0".
    String count(int n) => mineAsync.hasValue ? '$n' : '—';
    final completed = mine
        .where((i) => i.status == InspectionStatus.completed)
        .length;
    final active = mine
        .where(
          (i) =>
              i.status == InspectionStatus.inProgress ||
              i.status == InspectionStatus.scheduled,
        )
        .length;

    return Scaffold(
      body: SafeArea(
        child: ResponsiveContent(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
            children: [
              Text(
                'Profile',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: p.textPrimary,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 18),
              SurfaceCard(
                padding: const EdgeInsets.all(18),
                child: Row(
                  children: [
                    AppAvatar(url: user.avatarUrl, name: user.name, size: 68),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.name,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: p.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            user.email,
                            style: TextStyle(
                              fontSize: 13,
                              color: p.textSecondary,
                            ),
                          ),
                          if (user.phone != null)
                            Text(
                              user.phone!,
                              style: TextStyle(
                                fontSize: 13,
                                color: p.textSecondary,
                              ),
                            ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: p.primarySoft,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              user.role == UserRole.inspector
                                  ? 'Inspector'
                                  : 'Admin',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: p.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _Stat(value: count(active), label: 'Active', tone: Tone.blue),
                  const SizedBox(width: 10),
                  _Stat(
                    value: count(completed),
                    label: 'Completed',
                    tone: Tone.green,
                  ),
                ],
              ),
              const SizedBox(height: 22),
              const SectionTitle('Appearance'),
              const SizedBox(height: 10),
              SurfaceCard(
                padding: const EdgeInsets.all(6),
                child: Row(
                  children: [
                    for (final (mode, label, icon) in [
                      (ThemeMode.system, 'System', LucideIcons.smartphone),
                      (ThemeMode.light, 'Light', LucideIcons.sun),
                      (ThemeMode.dark, 'Dark', LucideIcons.moon),
                    ])
                      Expanded(
                        child: Semantics(
                          selected: themeMode == mode,
                          button: true,
                          child: Material(
                            color: themeMode == mode
                                ? p.primarySoft
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () => ref
                                  .read(themeModeProvider.notifier)
                                  .setThemeMode(mode),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                child: Column(
                                  children: [
                                    Icon(
                                      icon,
                                      size: 20,
                                      color: themeMode == mode
                                          ? p.primary
                                          : p.textSecondary,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      label,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: themeMode == mode
                                            ? p.primary
                                            : p.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              const SectionTitle('Workspace'),
              const SizedBox(height: 10),
              SurfaceCard(
                child: Row(
                  children: [
                    IconTile(
                      icon: useApiMode
                          ? LucideIcons.cloud
                          : LucideIcons.hardDrive,
                      tone: useApiMode ? Tone.teal : Tone.slate,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            useApiMode ? 'Connected to server' : 'Demo mode',
                            style: TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w600,
                              color: p.textPrimary,
                            ),
                          ),
                          Text(
                            useApiMode
                                ? apiBaseUrl
                                : 'Data is stored on this device only.',
                            style: TextStyle(
                              fontSize: 12.5,
                              color: p.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              OutlinedButton.icon(
                icon: const Icon(LucideIcons.logOut, size: 18),
                label: const Text('Log out'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.red,
                  side: const BorderSide(color: AppColors.red),
                ),
                onPressed: () => ref.read(authStateProvider.notifier).logout(),
              ),
            ],
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
        child: Row(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: p.fg(tone),
              ),
            ),
            const SizedBox(width: 10),
            Text(label, style: TextStyle(fontSize: 13, color: p.fg(tone))),
          ],
        ),
      ),
    );
  }
}
