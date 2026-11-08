import '../../../core/errors/failure.dart';
import '../../../core/network/api_client.dart';
import '../../../core/utils/result.dart';
import '../../models/inspector.dart';
import '../inspector_repository.dart';

class ApiInspectorRepository implements InspectorRepository {
  ApiInspectorRepository({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  @override
  Future<Result<List<Inspector>>> list({String? search}) async {
    try {
      final items = await _client.guard(() async {
        final response = await _client.dio.get(
          '/inspectors',
          queryParameters: {'search': ?search},
        );
        final data = response.data['data'] as List<dynamic>;
        return data
            .map((e) => Inspector.fromJson(e as Map<String, dynamic>))
            .toList();
      });
      return Success(items);
    } on Failure catch (f) {
      return Failed(f);
    }
  }

  @override
  Future<Result<Inspector>> getById(String id) async {
    try {
      final all = await list();
      final match = all.dataOrNull?.where((i) => i.id == id);
      if (match == null || match.isEmpty) {
        return const Failed(NotFoundFailure());
      }
      return Success(match.first);
    } on Failure catch (f) {
      return Failed(f);
    }
  }
}
