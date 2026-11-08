import 'dart:async';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inspectly/app/providers/auth_providers.dart';
import 'package:inspectly/app/providers/repository_providers.dart';
import 'package:inspectly/core/errors/failure.dart';
import 'package:inspectly/core/network/api_client.dart';
import 'package:inspectly/core/storage/token_storage.dart';
import 'package:inspectly/core/utils/result.dart';
import 'package:inspectly/data/models/app_user.dart';
import 'package:inspectly/data/models/enums.dart';
import 'package:inspectly/data/repositories/api/api_auth_repository.dart';
import 'package:inspectly/data/repositories/auth_repository.dart';

/// QC-008: session handling in API mode.
class _MemoryTokens extends TokenStorage {
  String? token;
  String? user;

  @override
  Future<String?> read() async => token;
  @override
  Future<void> write(String value) async => token = value;
  @override
  Future<void> clear() async {
    token = null;
    user = null;
  }

  @override
  Future<String?> readUser() async => user;
  @override
  Future<void> writeUser(String json) async => user = json;
}

class _OfflineAdapter implements HttpClientAdapter {
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async => throw DioException(
    requestOptions: options,
    type: DioExceptionType.connectionError,
  );

  @override
  void close({bool force = false}) {}
}

const _michael = AppUser(
  id: '2',
  name: 'Michael Carter',
  email: 'michael.carter@inspectly.test',
  role: UserRole.inspector,
);

class _FakeAuth implements AuthRepository {
  _FakeAuth(this.current);
  Future<Result<AppUser>> Function() current;
  bool loggedOut = false;

  @override
  Future<Result<AppUser>> currentUser() => current();
  @override
  Future<bool> isLoggedIn() async => true;
  @override
  Future<Result<AppUser>> login({
    required String email,
    required String password,
  }) async => const Success(_michael);
  @override
  Future<Result<void>> logout() async {
    loggedOut = true;
    return const Success(null);
  }
}

ProviderContainer _container(AuthRepository repo) {
  final c = ProviderContainer(
    overrides: [authRepositoryProvider.overrideWithValue(repo)],
  );
  addTearDown(c.dispose);
  return c;
}

Future<void> _settle() => Future<void>.delayed(Duration.zero);

void main() {
  test('offline at launch keeps the cached user signed in', () async {
    final tokens = _MemoryTokens()
      ..token = 'abc'
      ..user =
          '{"id":"2","name":"Michael Carter",'
          '"email":"michael.carter@inspectly.test","role":"inspector"}';
    final dio = Dio(BaseOptions(baseUrl: 'http://test/api'))
      ..httpClientAdapter = _OfflineAdapter();
    final repo = ApiAuthRepository(
      client: ApiClient(dio: dio, tokenStorage: tokens),
      tokenStorage: tokens,
    );

    final result = await repo.currentUser();

    expect(result.dataOrNull?.name, 'Michael Carter');
  });

  test('restore logs out only when the token is rejected', () async {
    // No network and nothing cached: show the login, but keep the token.
    final offlineRepo = _FakeAuth(() async => const Failed(NetworkFailure()));
    final offline = _container(offlineRepo);
    offline.read(authStateProvider);
    await _settle();
    expect(offlineRepo.loggedOut, isFalse);

    final fake = _FakeAuth(() async => const Failed(UnauthorizedFailure()));
    final expired = _container(fake);
    expired.read(authStateProvider);
    await _settle();
    expect(expired.read(authStateProvider), isA<AuthLoggedOut>());
    expect(fake.loggedOut, isTrue);
  });

  test(
    'a slow restore does not undo a login that happened meanwhile',
    () async {
      final slow = Completer<Result<AppUser>>();
      final c = _container(_FakeAuth(() => slow.future));
      c.read(authStateProvider);

      await c
          .read(authStateProvider.notifier)
          .login(email: 'x@y.z', password: 'secret');
      slow.complete(const Failed(TimeoutFailure()));
      await _settle();

      expect(c.read(authStateProvider), isA<AuthLoggedIn>());
    },
  );

  test('a 401 from any request signs the user out', () async {
    final fake = _FakeAuth(() async => const Success(_michael));
    final c = _container(fake);
    c.read(authStateProvider);
    await _settle();
    expect(c.read(authStateProvider), isA<AuthLoggedIn>());

    ApiClient.reportUnauthorized();
    await _settle();

    expect(c.read(authStateProvider), isA<AuthLoggedOut>());
    expect(fake.loggedOut, isTrue);
  });
}
