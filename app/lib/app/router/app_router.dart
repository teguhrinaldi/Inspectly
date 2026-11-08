import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/login_screen.dart';
import '../../features/auth/welcome_screen.dart';
import '../../features/checklist/checklist_screen.dart';
import '../../features/create/create_inspection_screen.dart';
import '../../features/dashboard/dashboard_screen.dart';
import '../../features/findings/evidence_screen.dart';
import '../../features/findings/findings_screen.dart';
import '../../features/inspections/inspection_detail_screen.dart';
import '../../features/inspections/inspection_list_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/qr_scanner/qr_scanner_screen.dart';
import '../../features/reports/comparison_screen.dart';
import '../../features/reports/report_screen.dart';
import '../../features/reports/reports_screen.dart';
import '../../features/reports/risk_summary_screen.dart';
import '../../features/reports/signature_screen.dart';
import '../providers/auth_providers.dart';
import '../shell/app_shell.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  String id(GoRouterState state) => state.pathParameters['id']!;

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/welcome',
    redirect: (context, state) {
      if (authState is AuthUnknown) return null;
      final loggedIn = authState is AuthLoggedIn;
      final loc = state.matchedLocation;
      final onPublic = loc == '/welcome' || loc == '/login';
      if (!loggedIn && !onPublic) return '/welcome';
      if (loggedIn && onPublic) return '/home';
      return null;
    },
    routes: [
      GoRoute(path: '/welcome', builder: (_, _) => const WelcomeScreen()),
      GoRoute(path: '/login', builder: (_, _) => const LoginScreen()),
      GoRoute(
        path: '/qr-scanner',
        parentNavigatorKey: rootNavigatorKey,
        builder: (_, _) => const QrScannerScreen(),
      ),
      GoRoute(
        path: '/checklist/:id',
        parentNavigatorKey: rootNavigatorKey,
        builder: (_, s) => ChecklistScreen(inspectionId: id(s)),
      ),
      GoRoute(
        path: '/report/:id',
        parentNavigatorKey: rootNavigatorKey,
        builder: (_, s) => ReportScreen(inspectionId: id(s)),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) =>
            AppShell(navigationShell: shell, location: state.uri),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                builder: (_, _) => const DashboardScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/inspections',
                builder: (_, _) => const InspectionListScreen(),
                routes: [
                  GoRoute(
                    path: ':id',
                    builder: (_, s) =>
                        InspectionDetailScreen(inspectionId: id(s)),
                    routes: [
                      GoRoute(
                        path: 'findings',
                        builder: (_, s) => FindingsScreen(inspectionId: id(s)),
                      ),
                      GoRoute(
                        path: 'evidence',
                        builder: (_, s) => EvidenceScreen(inspectionId: id(s)),
                      ),
                      GoRoute(
                        path: 'signature',
                        builder: (_, s) => SignatureScreen(inspectionId: id(s)),
                      ),
                      GoRoute(
                        path: 'summary',
                        builder: (_, s) =>
                            RiskSummaryScreen(inspectionId: id(s)),
                      ),
                      GoRoute(
                        path: 'comparison',
                        builder: (_, s) =>
                            ComparisonScreen(inspectionId: id(s)),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/create',
                builder: (_, _) => const CreateInspectionScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/reports',
                builder: (_, _) => const ReportsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (_, _) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
