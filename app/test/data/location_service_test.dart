import 'package:flutter_test/flutter_test.dart';
import 'package:inspectly/data/services/location_service.dart';

/// QC-034: a platform error while checking/requesting location permission
/// (plugin missing, permission request already running, ...) must come back
/// as "location unavailable", never as an exception that leaves the
/// caller's busy spinner running forever.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('platform errors become LocationUnavailable', () async {
    // No geolocator platform implementation in unit tests: every call throws.
    final result = await LocationService().getCurrentLocation();
    expect(result, isA<LocationUnavailable>());
  });
}
