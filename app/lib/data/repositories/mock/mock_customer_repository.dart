import 'package:collection/collection.dart';

import '../../../core/errors/failure.dart';
import '../../../core/utils/result.dart';
import '../../datasources/demo/demo_data_store.dart';
import '../../models/customer.dart';
import '../customer_repository.dart';

class MockCustomerRepository implements CustomerRepository {
  final DemoDataStore _store = DemoDataStore.instance;
  final List<Customer> _customers = [];

  List<Customer> get _all => _customers.isEmpty ? _store.customers : _customers;

  @override
  Future<Result<List<Customer>>> list({String? search}) async {
    if (_customers.isEmpty) _customers.addAll(_store.customers);
    var items = _all;
    if (search != null && search.trim().isNotEmpty) {
      final q = search.toLowerCase();
      items = items.where((c) => c.name.toLowerCase().contains(q)).toList();
    }
    return Success(items);
  }

  @override
  Future<Result<Customer>> getById(String id) async {
    final customer = _all.firstWhereOrNull((c) => c.id == id);
    if (customer == null) return const Failed(NotFoundFailure());
    return Success(customer);
  }

  @override
  Future<Result<Customer>> create(Customer customer) async {
    if (_customers.isEmpty) _customers.addAll(_store.customers);
    _customers.add(customer);
    return Success(customer);
  }

  @override
  Future<Result<Customer>> update(Customer customer) async {
    if (_customers.isEmpty) _customers.addAll(_store.customers);
    final index = _customers.indexWhere((c) => c.id == customer.id);
    if (index == -1) return const Failed(NotFoundFailure());
    _customers[index] = customer;
    return Success(customer);
  }
}
