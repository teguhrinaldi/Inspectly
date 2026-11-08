import '../../core/utils/result.dart';
import '../models/customer.dart';

abstract interface class CustomerRepository {
  Future<Result<List<Customer>>> list({String? search});
  Future<Result<Customer>> getById(String id);
  Future<Result<Customer>> create(Customer customer);
  Future<Result<Customer>> update(Customer customer);
}
