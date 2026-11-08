import '../../../core/errors/failure.dart';
import '../../../core/network/api_client.dart';
import '../../../core/storage/token_storage.dart';
import '../../../core/utils/result.dart';
import '../../models/app_user.dart';
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
      await _tokenStorage.write(data['token'] as String);
      return Success(AppUser.fromJson(data['user'] as Map<String, dynamic>));
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
      return Success(AppUser.fromJson(data['user'] as Map<String, dynamic>));
    } on Failure catch (f) {
      return Failed(f);
    }
  }

  @override
  Future<bool> isLoggedIn() async => (await _tokenStorage.read()) != null;
}
