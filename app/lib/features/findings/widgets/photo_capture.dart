import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../data/services/evidence_capture_service.dart';
import '../../../data/services/location_service.dart';

class CapturedPhoto {
  const CapturedPhoto(this.path, this.latitude, this.longitude);
  final String path;
  final double? latitude;
  final double? longitude;
}

/// Asks camera vs gallery, captures, tags GPS when permitted, and burns the
/// site/inspector/time/GPS watermark into the image. Null when cancelled.
Future<CapturedPhoto?> capturePhoto(
  BuildContext context, {
  required String siteName,
  required String inspectorName,
  @visibleForTesting EvidenceCaptureService? captureService,
}) async {
  final messenger = ScaffoldMessenger.maybeOf(context);
  final fromCamera = await showModalBottomSheet<bool>(
    context: context,
    useRootNavigator: true,
    builder: (context) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(LucideIcons.camera),
            title: const Text('Take photo'),
            onTap: () => Navigator.pop(context, true),
          ),
          ListTile(
            leading: const Icon(LucideIcons.image),
            title: const Text('Choose from gallery'),
            onTap: () => Navigator.pop(context, false),
          ),
          const SizedBox(height: 8),
        ],
      ),
    ),
  );
  if (fromCamera == null) return null;

  final capture = captureService ?? EvidenceCaptureService();
  final String? raw;
  try {
    raw = fromCamera
        ? await capture.captureFromCamera()
        : await capture.pickFromGallery();
  } on PlatformException catch (e) {
    // Permission denied (camera_access_denied / photo_access_denied), no
    // camera, or the picker already open: explain instead of failing
    // silently with an unhandled error (QC-014).
    final denied = e.code.contains('access_denied');
    messenger?.showSnackBar(
      SnackBar(
        content: Text(
          denied
              ? (fromCamera
                    ? 'Camera access is turned off for Inspectly.'
                    : 'Photo access is turned off for Inspectly.')
              : 'Could not open the ${fromCamera ? 'camera' : 'gallery'}.',
        ),
        action: denied
            ? SnackBarAction(
                label: 'Settings',
                onPressed: Geolocator.openAppSettings,
              )
            : null,
      ),
    );
    return null;
  }
  if (raw == null) return null;

  final location = await LocationService().getCurrentLocation();
  final lat = location is LocationSuccess ? location.latitude : null;
  final lng = location is LocationSuccess ? location.longitude : null;
  final watermarked = await capture.applyWatermark(
    raw,
    siteName: siteName,
    inspectorName: inspectorName,
    latitude: lat,
    longitude: lng,
  );
  return CapturedPhoto(watermarked, lat, lng);
}
