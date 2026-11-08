import '../../data/models/evidence.dart';
import '../../data/models/signature.dart';

/// Bundled demo assets and on-device files are used as-is; anything else is
/// a server-side path, so the API's public URL is used instead.
String resolveMedia(String filePath, String? fileUrl) {
  if (filePath.startsWith('assets/') ||
      filePath.startsWith('/') ||
      RegExp(r'^[A-Za-z]:[\\/]').hasMatch(filePath)) {
    return filePath;
  }
  return fileUrl ?? filePath;
}

extension EvidenceMedia on Evidence {
  String get displaySource =>
      watermarkedPath ?? resolveMedia(filePath, fileUrl);
}

extension SignatureMedia on InspectionSignature {
  String get displaySource => resolveMedia(filePath, fileUrl);
}
