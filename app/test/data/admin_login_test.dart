import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inspectly/core/errors/failure.dart';
import 'package:inspectly/core/network/api_client.dart';
import 'package:inspectly/core/storage/token_storage.dart';
import 'package:inspectly/data/repositories/api/api_auth_repository.dart';

/// QC-027: admin accounts use the web panel; the app refuses them in API
/// mode exactly like Demo Mode does, and doesn't keep their token.
class _MemoryTokens extends TokenStorage {
  String? token;
  @override
  Future<String?> read() async => token;
  @override
  Future<void> write(String value) async => token = value;
  @override
  Future<void> clear() async => token = null;
  @override
  Future<String?> readUser() async => null;
  @override
  Future<void> writeUser(String json) async {}
}

class _LoginAdapter implements HttpClientAdapter {
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async => ResponseBody.fromString(
    jsonEncode(
      options.path.endsWith('/login')
          ? {
              'token': '1|admintoken',
              'user': {
                'id': 1,
                'name': 'Admin',
                'email': 'admin@inspectly.test',
                'role': 'admin',
              },
            }
          : {'message': 'Logged out.'},
    ),
    200,
    headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    },
  );

  @override
  void close({bool force = false}) {}
}

void main() {
  test('admin credentials are refused by the mobile app', () async {
    final tokens = _MemoryTokens();
    final dio = Dio(BaseOptions(baseUrl: 'http://test/api'))
      ..httpClientAdapter = _LoginAdapter();
    final repo = ApiAuthRepository(
      client: ApiClient(dio: dio, tokenStorage: tokens),
      tokenStorage: tokens,
    );

    final result = await repo.login(
      email: 'admin@inspectly.test',
      password: 'password',
    );

    result.when(
      success: (_) => fail('admin must not sign in to the app'),
      failure: (f) => expect(f, isA<ForbiddenFailure>()),
    );
    expect(tokens.token, isNull);
  });
}
