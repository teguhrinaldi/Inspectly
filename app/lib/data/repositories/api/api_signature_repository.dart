import 'package:dio/dio.dart';

import '../../../core/errors/failure.dart';
import '../../../core/network/api_client.dart';
import '../../../core/utils/result.dart';
import '../../models/signature.dart';
import '../signature_repository.dart';

class ApiSignatureRepository implements SignatureRepository {
  ApiSignatureRepository({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  @override
  Future<Result<InspectionSignature>> save({
    required String inspectionId,
    required SignatureType type,
    required String signerName,
    required String localFilePath,
  }) async {
    try {
      final signature = await _client.guard(() async {
        final form = FormData.fromMap({
          'inspection_id': inspectionId,
          'type': type == SignatureType.inspector ? 'inspector' : 'customer',
          'signer_name': signerName,
          'file': await MultipartFile.fromFile(localFilePath),
        });
        final response = await _client.dio.post('/signatures', data: form);
        return InspectionSignature.fromJson(_client.unwrap(response));
      });
      return Success(signature);
    } on Failure catch (f) {
      return Failed(f);
    }
  }
}
