import '../../core/utils/result.dart';
import '../models/app_user.dart';

abstract interface class AuthRepository {
  Future<Result<AppUser>> login({
    required String email,
    required String password,
  });
  Future<Result<void>> logout();
  Future<Result<AppUser>> currentUser();
  Future<bool> isLoggedIn();
}
