import 'package:inspectly/core/utils/result.dart';
import 'package:inspectly/data/datasources/demo/demo_reference_data.dart';
import 'package:inspectly/data/models/app_user.dart';
import 'package:inspectly/data/repositories/auth_repository.dart';

/// Signed in as a demo user (by id), e.g. the inspector who owns the
/// inspection a test works on (writes are owner-only, QC-001).
class SignedInAs implements AuthRepository {
  SignedInAs(this.userId);
  final String userId;

  AppUser get _user =>
      DemoReferenceData.users.firstWhere((u) => u.id == userId);

  @override
  Future<Result<AppUser>> currentUser() async => Success(_user);
  @override
  Future<bool> isLoggedIn() async => true;
  @override
  Future<Result<AppUser>> login({
    required String email,
    required String password,
  }) async => Success(_user);
  @override
  Future<Result<void>> logout() async => const Success(null);
}
