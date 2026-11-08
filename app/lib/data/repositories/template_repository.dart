import '../../core/utils/result.dart';
import '../models/inspection_template.dart';

abstract interface class TemplateRepository {
  Future<Result<List<InspectionTemplate>>> list({bool activeOnly = false});
  Future<Result<InspectionTemplate>> getById(String id);
  Future<Result<InspectionTemplate>> create(InspectionTemplate template);
  Future<Result<InspectionTemplate>> update(InspectionTemplate template);
  Future<Result<void>> delete(String id);
}
