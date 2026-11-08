import 'package:dio/dio.dart';

import '../../../core/errors/failure.dart';
import '../../../core/network/api_client.dart';
import '../../../core/utils/result.dart';
import '../../models/evidence.dart';
import '../evidence_repository.dart';

class ApiEvidenceRepository implements EvidenceRepository {
  ApiEvidenceRepository({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  @override
  Future<Result<Evidence>> attach({
    required String inspectionId,
    String? inspectionItemId,
    String? findingId,
    required String localFilePath,
    double? latitude,
    double? longitude,
    double? accuracy,
  }) async {
    try {
      final evidence = await _client.guard(() async {
        final form = FormData.fromMap({
          'inspection_id': inspectionId,
          'inspection_item_id': ?inspectionItemId,
          'finding_id': ?findingId,
          'lat': ?latitude,
          'lng': ?longitude,
          'accuracy': ?accuracy,
          'file': await MultipartFile.fromFile(localFilePath),
        });
        final response = await _client.dio.post('/evidence', data: form);
        return Evidence.fromJson(_client.unwrap(response));
      });
      return Success(evidence);
    } on Failure catch (f) {
      return Failed(f);
    }
  }

  @override
  Future<Result<void>> remove(String evidenceId) async {
    try {
      await _client.guard(() => _client.dio.delete('/evidence/$evidenceId'));
      return const Success(null);
    } on Failure catch (f) {
      return Failed(f);
    }
  }
}
