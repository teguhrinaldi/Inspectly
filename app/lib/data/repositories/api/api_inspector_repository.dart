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
        final data = await _client.getAllPages(
          '/inspectors',
          queryParameters: {'search': ?search},
        );
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
      // No GET /inspectors/{id}; list() reads every page, and a failed
      // list is reported as that failure rather than as "not found".
      final all = await list();
      final failure = all.when(success: (_) => null, failure: (f) => f);
      if (failure != null) return Failed(failure);
      final match = all.dataOrNull!.where((i) => i.id == id);
      if (match.isEmpty) return const Failed(NotFoundFailure());
      return Success(match.first);
    } on Failure catch (f) {
      return Failed(f);
    }
  }
}
