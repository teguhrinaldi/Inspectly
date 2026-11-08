import '../../core/utils/result.dart';
import '../models/signature.dart';

abstract interface class SignatureRepository {
  Future<Result<InspectionSignature>> save({
    required String inspectionId,
    required SignatureType type,
    required String signerName,
    required String localFilePath,
  });
}
