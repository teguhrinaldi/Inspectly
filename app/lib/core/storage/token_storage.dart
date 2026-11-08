import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Sanctum bearer token, kept in the platform secure keystore/keychain —
/// never in SharedPreferences (spec §25, don't hardcode/expose secrets).
class TokenStorage {
  TokenStorage({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;
  static const _key = 'inspectly.auth_token';

  Future<String?> read() => _storage.read(key: _key);
  Future<void> write(String token) => _storage.write(key: _key, value: token);
  Future<void> clear() => _storage.delete(key: _key);
}
