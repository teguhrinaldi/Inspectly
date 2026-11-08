import 'package:collection/collection.dart';

import '../../../core/errors/failure.dart';
import '../../../core/utils/result.dart';
import '../../datasources/demo/demo_reference_data.dart';
import '../../models/app_user.dart';
import '../auth_repository.dart';

/// Demo-mode auth: any of the seeded inspector emails (see docs/demo-data.md)
/// with password "password" logs in. No backend required.
class MockAuthRepository implements AuthRepository {
  AppUser? _current;

  @override
  Future<Result<AppUser>> login({
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));
    if (password != 'password') {
      return const Failed(UnauthorizedFailure('Incorrect email or password.'));
    }
    final user = DemoReferenceData.users
        .where(
          (u) =>
              u.email.toLowerCase() == email.toLowerCase() &&
              u.role.name == 'inspector',
        )
        .firstOrNull;
    if (user == null) {
      return const Failed(UnauthorizedFailure('Incorrect email or password.'));
    }
    _current = user;
    return Success(user);
  }

  @override
  Future<Result<void>> logout() async {
    _current = null;
    return const Success(null);
  }

  @override
  Future<Result<AppUser>> currentUser() async {
    final user = _current;
    if (user == null) return const Failed(UnauthorizedFailure());
    return Success(user);
  }

  @override
  Future<bool> isLoggedIn() async => _current != null;
}
