import 'package:flutter_test/flutter_test.dart';
import 'package:inspectly/core/network/api_client.dart';

/// QC-049: a release build in API mode must use HTTPS (Android blocks
/// cleartext HTTP in release, so every request would fail silently).
void main() {
  test('release API builds require an https base URL', () {
    expect(
      apiConfigProblem(
        useApi: true,
        baseUrl: 'http://10.0.2.2:8000/api',
        release: true,
      ),
      isNotNull,
    );
    expect(
      apiConfigProblem(
        useApi: true,
        baseUrl: 'https://api.example.com/api',
        release: true,
      ),
      isNull,
    );
    // Debug builds and Demo Mode are free to use the emulator default.
    expect(
      apiConfigProblem(
        useApi: true,
        baseUrl: 'http://10.0.2.2:8000/api',
        release: false,
      ),
      isNull,
    );
    expect(
      apiConfigProblem(useApi: false, baseUrl: 'http://x', release: true),
      isNull,
    );
  });
}
