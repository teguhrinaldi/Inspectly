import 'dart:io';

import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

/// Captures a photo (camera or gallery — both real, via image_picker) and
/// produces a watermarked derivative for use as inspection evidence, per
/// spec §9.9: the original is never modified, a separate stamped copy is
/// generated for the report/evidence trail.
class EvidenceCaptureService {
  final ImagePicker _picker = ImagePicker();
  static const _uuid = Uuid();

  Future<String?> captureFromCamera() async {
    final file = await _picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 2000,
      imageQuality: 90,
    );
    return file?.path;
  }

  Future<String?> pickFromGallery() async {
    final file = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 2000,
      imageQuality: 90,
    );
    return file?.path;
  }

  /// Draws a subtle, legible watermark band (brand + site + inspector +
  /// timestamp + coordinates when available) onto a *copy* of [sourcePath]
  /// and returns the new file's path.
  Future<String> applyWatermark(
    String sourcePath, {
    required String siteName,
    required String inspectorName,
    DateTime? timestamp,
    double? latitude,
    double? longitude,
  }) async {
    final bytes = await File(sourcePath).readAsBytes();
    final decoded = img.decodeImage(bytes);
    if (decoded == null) return sourcePath;

    final lines = <String>[
      'Inspectly · $siteName',
      inspectorName,
      DateFormat('MMM d, yyyy · h:mm a').format(timestamp ?? DateTime.now()),
      if (latitude != null && longitude != null)
        '${latitude.toStringAsFixed(5)}, ${longitude.toStringAsFixed(5)}',
    ];

    final bandHeight = 26 * lines.length + 16;
    var stamped = img.fillRect(
      decoded,
      x1: 0,
      y1: decoded.height - bandHeight,
      x2: decoded.width,
      y2: decoded.height,
      color: img.ColorRgba8(0, 0, 0, 110),
    );

    for (var i = 0; i < lines.length; i++) {
      stamped = img.drawString(
        stamped,
        lines[i],
        font: img.arial14,
        x: 12,
        y: decoded.height - bandHeight + 10 + (i * 20),
        color: img.ColorRgba8(255, 255, 255, 255),
      );
    }

    final docsDir = await getApplicationDocumentsDirectory();
    final watermarkDir = Directory(
      p.join(docsDir.path, 'inspectly', 'evidence_watermarked'),
    );
    if (!await watermarkDir.exists()) {
      await watermarkDir.create(recursive: true);
    }
    final outPath = p.join(watermarkDir.path, '${_uuid.v4()}.jpg');
    await File(outPath).writeAsBytes(img.encodeJpg(stamped, quality: 92));
    return outPath;
  }
}
