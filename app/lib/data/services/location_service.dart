import 'dart:async';

import 'package:geolocator/geolocator.dart';

/// One position reading with its accuracy radius in metres.
class LocationFix {
  const LocationFix(this.latitude, this.longitude, this.accuracy);
  final double latitude;
  final double longitude;
  final double? accuracy;
}

/// Wraps geolocator with the permission-handling flow the spec requires
/// (§9.10): request permission, and if denied, let the caller continue
/// without location rather than blocking the workflow. One-shot reads only
/// (inspection start / evidence capture) — never background tracking.
///
/// A high-accuracy fix gets at most [preciseTimeout] (3 s); after that the
/// device's last known position is used, so taking a photo indoors doesn't
/// stall. The accuracy is reported either way (QC-043).
class LocationService {
  LocationService({
    this.preciseTimeout = const Duration(seconds: 3),
    Future<bool> Function()? serviceEnabled,
    Future<bool> Function()? permission,
    Future<LocationFix> Function()? precise,
    Future<LocationFix?> Function()? lastKnown,
  }) : _serviceEnabled = serviceEnabled ?? Geolocator.isLocationServiceEnabled,
       _askPermission = permission,
       _precise = precise ?? _defaultPrecise,
       _lastKnown = lastKnown ?? _defaultLastKnown;

  final Duration preciseTimeout;
  final Future<bool> Function() _serviceEnabled;
  final Future<bool> Function()? _askPermission;
  final Future<LocationFix> Function() _precise;
  final Future<LocationFix?> Function() _lastKnown;

  static Future<LocationFix> _defaultPrecise() async {
    final p = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );
    return LocationFix(p.latitude, p.longitude, p.accuracy);
  }

  static Future<LocationFix?> _defaultLastKnown() async {
    final p = await Geolocator.getLastKnownPosition();
    return p == null ? null : LocationFix(p.latitude, p.longitude, p.accuracy);
  }

  /// Null when location may be read, otherwise why not.
  Future<LocationResult?> _checkPermission() async {
    final hook = _askPermission;
    if (hook != null) {
      return await hook()
          ? null
          : const LocationResult.denied('Location permission was denied.');
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
    return null;
  }

  Future<LocationResult> getCurrentLocation() async {
    // Everything — including the permission checks — is inside the try: a
    // platform error must never escape to the caller (QC-034).
    try {
      if (!await _serviceEnabled()) {
        return const LocationResult.unavailable(
          'Location services are turned off on this device.',
        );
      }
      final denied = await _checkPermission();
      if (denied != null) return denied;

      LocationFix? fix;
      var lastKnown = false;
      try {
        fix = await _precise().timeout(preciseTimeout);
      } catch (_) {
        fix = null; // timeout or no fix: fall back below
      }
      if (fix == null) {
        fix = await _lastKnown();
        lastKnown = true;
      }
      if (fix == null) {
        return const LocationResult.unavailable(
          'Could not determine the location in time.',
        );
      }
      return LocationResult.success(
        fix.latitude,
        fix.longitude,
        accuracy: fix.accuracy,
        isLastKnown: lastKnown,
      );
    } catch (e) {
      return LocationResult.unavailable('Could not determine location: $e');
    }
  }
}

sealed class LocationResult {
  const LocationResult();
  const factory LocationResult.success(
    double latitude,
    double longitude, {
    double? accuracy,
    bool isLastKnown,
  }) = LocationSuccess;
  const factory LocationResult.denied(String message) = LocationDenied;
  const factory LocationResult.unavailable(String message) =
      LocationUnavailable;
}

class LocationSuccess extends LocationResult {
  const LocationSuccess(
    this.latitude,
    this.longitude, {
    this.accuracy,
    this.isLastKnown = false,
  });
  final double latitude;
  final double longitude;

  /// Radius in metres (68% confidence), when the platform reports it.
  final double? accuracy;

  /// True when this is the device's last known position (no fresh fix in
  /// time), not a new reading.
  final bool isLastKnown;
}

class LocationDenied extends LocationResult {
  const LocationDenied(this.message);
  final String message;
}

class LocationUnavailable extends LocationResult {
  const LocationUnavailable(this.message);
  final String message;
}
