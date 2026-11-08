import '../../../core/errors/failure.dart';
import '../../../core/network/api_client.dart';
import '../../../core/utils/result.dart';
import '../../models/inspection_template.dart';
import '../template_repository.dart';

class ApiTemplateRepository implements TemplateRepository {
  ApiTemplateRepository({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  @override
  Future<Result<List<InspectionTemplate>>> list({
    bool activeOnly = false,
  }) async {
    try {
      final items = await _client.guard(() async {
        final data = await _client.getAllPages(
          '/inspection-templates',
          queryParameters: {if (activeOnly) 'active': '1'},
        );
        return data
            .map((e) => InspectionTemplate.fromJson(e as Map<String, dynamic>))
            .toList();
      });
      return Success(items);
    } on Failure catch (f) {
      return Failed(f);
    }
  }

  @override
  Future<Result<InspectionTemplate>> getById(String id) async {
    try {
      final template = await _client.guard(() async {
        final response = await _client.dio.get('/inspection-templates/$id');
        return InspectionTemplate.fromJson(_client.unwrap(response));
      });
      return Success(template);
    } on Failure catch (f) {
      return Failed(f);
    }
  }

  @override
  Future<Result<InspectionTemplate>> create(InspectionTemplate template) async {
    try {
      final saved = await _client.guard(() async {
        final response = await _client.dio.post(
          '/inspection-templates',
          data: template.toJson(),
        );
        return InspectionTemplate.fromJson(_client.unwrap(response));
      });
      return Success(saved);
    } on Failure catch (f) {
      return Failed(f);
    }
  }

  @override
  Future<Result<InspectionTemplate>> update(InspectionTemplate template) async {
    try {
      final saved = await _client.guard(() async {
        final response = await _client.dio.put(
          '/inspection-templates/${template.id}',
          data: template.toJson(),
        );
        return InspectionTemplate.fromJson(_client.unwrap(response));
      });
      return Success(saved);
    } on Failure catch (f) {
      return Failed(f);
    }
  }

  @override
  Future<Result<void>> delete(String id) async {
    try {
      await _client.guard(
        () => _client.dio.delete('/inspection-templates/$id'),
      );
      return const Success(null);
    } on Failure catch (f) {
      return Failed(f);
    }
  }
}
