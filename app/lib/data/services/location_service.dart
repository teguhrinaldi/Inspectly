import 'package:geolocator/geolocator.dart';

/// Wraps geolocator with the permission-handling flow the spec requires
/// (§9.10): request permission, and if denied, let the caller continue
/// without location rather than blocking the workflow. This is a one-shot
/// location read (inspection start / evidence capture) — never background
/// tracking.
class LocationService {
  Future<LocationResult> getCurrentLocation() async {
    // Everything — including the permission checks — is inside the try: a
    // platform error must never escape to the caller (QC-034).
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        return const LocationResult.unavailable(
          'Location services are turned off on this device.',
        );
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied) {
        return const LocationResult.denied('Location permission was denied.');
      }
      if (permission == LocationPermission.deniedForever) {
        return const LocationResult.denied(
          'Location permission is permanently denied. Enable it in Settings to tag inspections with location.',
        );
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );
      return LocationResult.success(position.latitude, position.longitude);
    } catch (e) {
      return LocationResult.unavailable('Could not determine location: $e');
    }
  }
}

sealed class LocationResult {
  const LocationResult();
  const factory LocationResult.success(double latitude, double longitude) =
      LocationSuccess;
  const factory LocationResult.denied(String message) = LocationDenied;
  const factory LocationResult.unavailable(String message) =
      LocationUnavailable;
}

class LocationSuccess extends LocationResult {
  const LocationSuccess(this.latitude, this.longitude);
  final double latitude;
  final double longitude;
}

class LocationDenied extends LocationResult {
  const LocationDenied(this.message);
  final String message;
}

class LocationUnavailable extends LocationResult {
  const LocationUnavailable(this.message);
  final String message;
}
