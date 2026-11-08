import '../../core/utils/result.dart';
import '../models/inspector.dart';

abstract interface class InspectorRepository {
  Future<Result<List<Inspector>>> list({String? search});
  Future<Result<Inspector>> getById(String id);
}
