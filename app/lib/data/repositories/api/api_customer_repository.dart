import '../../../core/errors/failure.dart';
import '../../../core/network/api_client.dart';
import '../../../core/utils/result.dart';
import '../../models/customer.dart';
import '../customer_repository.dart';

class ApiCustomerRepository implements CustomerRepository {
  ApiCustomerRepository({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  @override
  Future<Result<List<Customer>>> list({String? search}) async {
    try {
      final items = await _client.guard(() async {
        final response = await _client.dio.get(
          '/customers',
          queryParameters: {'search': ?search},
        );
        final data = response.data['data'] as List<dynamic>;
        return data
            .map((e) => Customer.fromJson(e as Map<String, dynamic>))
            .toList();
      });
      return Success(items);
    } on Failure catch (f) {
      return Failed(f);
    }
  }

  @override
  Future<Result<Customer>> getById(String id) async {
    try {
      final all = await list();
      final match = all.dataOrNull?.where((c) => c.id == id);
      if (match == null || match.isEmpty) {
        return const Failed(NotFoundFailure());
      }
      return Success(match.first);
    } on Failure catch (f) {
      return Failed(f);
    }
  }

  @override
  Future<Result<Customer>> create(Customer customer) async {
    try {
      final saved = await _client.guard(() async {
        final response = await _client.dio.post(
          '/customers',
          data: customer.toJson(),
        );
        return Customer.fromJson(_client.unwrap(response));
      });
      return Success(saved);
    } on Failure catch (f) {
      return Failed(f);
    }
  }

  @override
  Future<Result<Customer>> update(Customer customer) async {
    try {
      final saved = await _client.guard(() async {
        final response = await _client.dio.put(
          '/customers/${customer.id}',
          data: customer.toJson(),
        );
        return Customer.fromJson(_client.unwrap(response));
      });
      return Success(saved);
    } on Failure catch (f) {
      return Failed(f);
    }
  }
}
