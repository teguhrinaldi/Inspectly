import 'package:flutter/material.dart';
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
}) async {
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

  final capture = EvidenceCaptureService();
  final raw = fromCamera
      ? await capture.captureFromCamera()
      : await capture.pickFromGallery();
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
