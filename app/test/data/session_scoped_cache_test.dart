import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inspectly/app/providers/auth_providers.dart';
import 'package:inspectly/app/providers/inspection_providers.dart';
import 'package:inspectly/app/providers/repository_providers.dart';
import 'package:inspectly/core/errors/failure.dart';
import 'package:inspectly/core/utils/result.dart';
import 'package:inspectly/data/models/app_user.dart';
import 'package:inspectly/data/models/enums.dart';
import 'package:inspectly/data/repositories/auth_repository.dart';
import 'package:inspectly/data/repositories/inspection_repository.dart';

/// QC-009: data cached for one user must not be shown to the next user who
/// signs in on the same device.
class _SwitchableAuth implements AuthRepository {
  AppUser? current;

  @override
  Future<Result<AppUser>> currentUser() async => current == null
      ? const Failed(UnauthorizedFailure())
      : Success(current!);
  @override
  Future<bool> isLoggedIn() async => current != null;
  @override
  Future<Result<AppUser>> login({
    required String email,
    required String password,
  }) async {
    current = AppUser(
      id: email,
      name: email,
      email: email,
      role: UserRole.inspector,
    );
    return Success(current!);
  }

  @override
  Future<Result<void>> logout() async {
    current = null;
    return const Success(null);
  }
}

void main() {
  test('switching users drops cached inspection data', () async {
    final auth = _SwitchableAuth();
    final c = ProviderContainer(
      overrides: [authRepositoryProvider.overrideWithValue(auth)],
    );
    addTearDown(c.dispose);
    const filter = InspectionListFilter();
    final notifier = c.read(authStateProvider.notifier);

    await notifier.login(email: 'a@x.test', password: 'p');
    final sub = c.listen(inspectionListProvider(filter), (_, _) {});
    final listForA = await c.read(inspectionListProvider(filter).future);

    await notifier.logout();
    await notifier.login(email: 'b@x.test', password: 'p');
    final listForB = await c.read(inspectionListProvider(filter).future);

    expect(identical(listForA, listForB), isFalse);
    sub.close();
  });
}
