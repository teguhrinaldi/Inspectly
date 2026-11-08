import 'dart:io';

import 'package:collection/collection.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../../../core/errors/failure.dart';
import '../../../core/utils/result.dart';
import '../../datasources/demo/demo_data_store.dart';
import '../../models/evidence.dart';
import '../evidence_repository.dart';

/// Persists captured evidence to the app's own documents directory so it
/// survives app restarts even in Demo Mode (no backend required). This is
/// real file persistence, not a placeholder — the file that ends up on disk
/// here is exactly what the report/PDF generator reads back later.
class MockEvidenceRepository implements EvidenceRepository {
  final DemoDataStore _store = DemoDataStore.instance;
  static const _uuid = Uuid();

  @override
  Future<Result<Evidence>> attach({
    required String inspectionId,
    String? inspectionItemId,
    String? findingId,
    required String localFilePath,
    double? latitude,
    double? longitude,
  }) async {
    if (!_store.mayWrite(inspectionId)) {
      return const Failed(
        ForbiddenFailure(
          'Only the assigned inspector can change this inspection.',
        ),
      );
    }
    try {
      final docsDir = await getApplicationDocumentsDirectory();
      final evidenceDir = Directory(
        p.join(docsDir.path, 'inspectly', 'evidence'),
      );
      if (!await evidenceDir.exists()) {
        await evidenceDir.create(recursive: true);
      }
      final ext = p.extension(localFilePath);
      final storedPath = p.join(evidenceDir.path, '${_uuid.v4()}$ext');
      await File(localFilePath).copy(storedPath);

      final evidence = Evidence(
        id: 'ev-${_uuid.v4()}',
        inspectionId: inspectionId,
        inspectionItemId: inspectionItemId,
        findingId: findingId,
        filePath: storedPath,
        latitude: latitude,
        longitude: longitude,
        capturedAt: DateTime.now(),
      );
      _store.attachEvidence(evidence);
      return Success(evidence);
    } catch (e) {
      return Failed(UnknownFailure('Could not save the photo: $e'));
    }
  }

  @override
  Future<Result<void>> remove(String evidenceId) async {
    final evidence = _store.inspections
        .expand(
          (i) => [
            ...i.items.expand((it) => it.evidence),
            ...i.findings.expand((f) => f.evidence),
          ],
        )
        .where((e) => e.id == evidenceId)
        .firstOrNull;

    final removed = _store.removeEvidence(evidenceId);
    if (!removed) return const Failed(NotFoundFailure('Evidence not found.'));

    if (evidence != null) {
      final file = File(evidence.filePath);
      if (await file.exists()) {
        await file.delete();
      }
    }
    return const Success(null);
  }
}
