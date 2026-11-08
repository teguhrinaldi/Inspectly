import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inspectly/app/app.dart';
import 'package:inspectly/app/providers/repository_providers.dart';
import 'package:inspectly/app/router/app_router.dart';
import 'package:inspectly/core/utils/result.dart';
import 'package:inspectly/data/models/app_user.dart';
import 'package:inspectly/data/repositories/auth_repository.dart';

import '../helpers/pump_screen.dart';
import '../layout/extreme_data.dart' show extremeUser;

/// QC-030: a signed-in user's cold start must not flash the Welcome screen
/// while the session is restored, and the router is created only once.
class _SlowRestore implements AuthRepository {
  final gate = Completer<void>();

  @override
  Future<bool> isLoggedIn() async => true;
  @override
  Future<Result<AppUser>> currentUser() async {
    await gate.future;
    return const Success(extremeUser);
  }

  @override
  Future<Result<AppUser>> login({
    required String email,
    required String password,
  }) async => const Success(extremeUser);
  @override
  Future<Result<void>> logout() async => const Success(null);
}

void main() {
  testWidgets('no Welcome flash while a saved session is restored', (
    tester,
  ) async {
    await tester.runAsync(loadAppFonts);
    final auth = _SlowRestore();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [authRepositoryProvider.overrideWithValue(auth)],
        child: const InspectlyApp(),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Get Started'), findsNothing);
    final container = ProviderScope.containerOf(
      tester.element(find.byType(InspectlyApp)),
    );
    final routerBefore = container.read(routerProvider);

    auth.gate.complete();
    await tester.pumpAndSettle();

    expect(find.text("Today's Inspections"), findsOneWidget);
    expect(identical(container.read(routerProvider), routerBefore), isTrue);
  });
}
