import '../../core/utils/result.dart';
import '../models/evidence.dart';

abstract interface class EvidenceRepository {
  /// [localFilePath] is the already-captured (and, if applicable, watermarked)
  /// photo on device. Implementations persist/upload it and return the
  /// stored Evidence record.
  Future<Result<Evidence>> attach({
    required String inspectionId,
    String? inspectionItemId,
    String? findingId,
    required String localFilePath,
    double? latitude,
    double? longitude,
  });

  Future<Result<void>> remove(String evidenceId);
}
