import 'dart:convert';

import '../../../core/errors/failure.dart';
import '../../../core/network/api_client.dart';
import '../../../core/storage/token_storage.dart';
import '../../../core/utils/result.dart';
import '../../models/app_user.dart';
import '../../models/enums.dart';
import '../auth_repository.dart';

class ApiAuthRepository implements AuthRepository {
  ApiAuthRepository({ApiClient? client, TokenStorage? tokenStorage})
    : _client = client ?? ApiClient(),
      _tokenStorage = tokenStorage ?? TokenStorage();

  final ApiClient _client;
  final TokenStorage _tokenStorage;

  @override
  Future<Result<AppUser>> login({
    required String email,
    required String password,
  }) async {
    try {
      final data = await _client.guard(() async {
        final response = await _client.dio.post(
          '/login',
          data: {'email': email, 'password': password},
        );
        return response.data as Map<String, dynamic>;
      });
      final user = await _client.guard(() async {
        await _tokenStorage.write(data['token'] as String);
        return AppUser.fromJson(data['user'] as Map<String, dynamic>);
      });
      if (user.role != UserRole.inspector) {
        // Admins work in the web panel only (same rule as Demo Mode):
        // revoke the token that was just issued and don't keep it.
        await logout();
        return const Failed(
          ForbiddenFailure(
            'Admin accounts sign in on the web admin panel, not in the app.',
          ),
        );
      }
      await _tokenStorage.writeUser(jsonEncode(user.toJson()));
      return Success(user);
    } on Failure catch (f) {
      return Failed(f);
    }
  }

  @override
  Future<Result<void>> logout() async {
    try {
      await _client.guard(() => _client.dio.post('/logout'));
      await _tokenStorage.clear();
      return const Success(null);
    } on Failure catch (f) {
      // Even if the server call fails (e.g. token already expired), the
      // local session should still end.
      await _tokenStorage.clear();
      return Failed(f);
    }
  }

  @override
  Future<Result<AppUser>> currentUser() async {
    try {
      final data = await _client.guard(() async {
        final response = await _client.dio.get('/me');
        return response.data as Map<String, dynamic>;
      });
      // GET /me responds {"user": {...}}, like POST /login.
      final user = await _client.guard(
        () async => AppUser.fromJson(data['user'] as Map<String, dynamic>),
      );
      await _tokenStorage.writeUser(jsonEncode(user.toJson()));
      return Success(user);
    } on Failure catch (f) {
      // No connection: keep working as the last known user. The token is
      // re-validated on the next request that does reach the server.
      if (f is NetworkFailure || f is TimeoutFailure) {
        final cached = await _cachedUser();
        if (cached != null) return Success(cached);
      }
      return Failed(f);
    }
  }

  Future<AppUser?> _cachedUser() async {
    try {
      final json = await _tokenStorage.readUser();
      if (json == null) return null;
      return AppUser.fromJson(jsonDecode(json) as Map<String, dynamic>);
    } catch (_) {
      return null; // unreadable cache = no cache
    }
  }

  @override
  Future<bool> isLoggedIn() async => (await _tokenStorage.read()) != null;
}
