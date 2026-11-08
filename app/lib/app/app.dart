import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'providers/theme_providers.dart';
import 'providers/auth_providers.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';

class InspectlyApp extends ConsumerWidget {
  const InspectlyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'Inspectly',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      routerConfig: router,
      // While a saved session is being restored, show a plain background
      // instead of flashing the Welcome screen (QC-030).
      builder: (context, child) => ref.watch(authStateProvider) is AuthUnknown
          ? ColoredBox(color: Theme.of(context).scaffoldBackgroundColor)
          : child!,
    );
  }
}
