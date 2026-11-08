import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inspectly/app/providers/repository_providers.dart';
import 'package:inspectly/core/utils/result.dart';
import 'package:inspectly/data/models/app_user.dart';
import 'package:inspectly/data/models/enums.dart';
import 'package:inspectly/data/repositories/auth_repository.dart';
import 'package:inspectly/features/auth/login_screen.dart';
import 'package:inspectly/features/create/create_inspection_screen.dart';

import '../helpers/pump_screen.dart';

/// QC-036: obvious input mistakes are caught before any request is sent.
class _CountingAuth implements AuthRepository {
  int logins = 0;
  @override
  Future<Result<AppUser>> login({
    required String email,
    required String password,
  }) async {
    logins++;
    return const Success(
      AppUser(id: '1', name: 'M', email: 'm@x.test', role: UserRole.inspector),
    );
  }

  @override
  Future<bool> isLoggedIn() async => false;
  @override
  Future<Result<AppUser>> currentUser() async => throw UnimplementedError();
  @override
  Future<Result<void>> logout() async => const Success(null);
}

void main() {
  for (final (email, message) in [
    ('   ', 'Enter your email'),
    ('not-an-email', 'Enter a valid email address'),
  ]) {
    testWidgets('login rejects "$email" without calling the server', (
      tester,
    ) async {
      final auth = _CountingAuth();
      await pumpScreen(
        tester,
        const LoginScreen(),
        overrides: [authRepositoryProvider.overrideWithValue(auth)],
      );
      await tester.pumpAndSettle();
      final fields = find.byType(TextFormField);
      await tester.enterText(fields.first, email);
      await tester.enterText(fields.last, 'password');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
      await tester.pumpAndSettle();

      expect(auth.logins, 0);
      expect(find.text(message), findsOneWidget);
    });
  }

  test('a schedule in the past is rejected', () {
    final now = DateTime(2026, 11, 8, 15);
    expect(scheduleProblem(DateTime(2026, 11, 8, 8), now), isNotNull);
    expect(scheduleProblem(DateTime(2026, 11, 8, 16), now), isNull);
  });
}
