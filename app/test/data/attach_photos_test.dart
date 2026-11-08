import 'package:flutter_test/flutter_test.dart';
import 'package:inspectly/core/errors/failure.dart';
import 'package:inspectly/core/utils/result.dart';
import 'package:inspectly/data/models/evidence.dart';
import 'package:inspectly/data/repositories/evidence_repository.dart';
import 'package:inspectly/features/findings/finding_actions.dart';
import 'package:inspectly/features/findings/widgets/photo_capture.dart';

/// QC-012: a failed photo upload must be counted (and reported), not lost
/// silently.
class _HalfFailing implements EvidenceRepository {
  int calls = 0;

  @override
  Future<Result<Evidence>> attach({
    required String inspectionId,
    String? inspectionItemId,
    String? findingId,
    required String localFilePath,
    double? latitude,
    double? longitude,
  }) async {
    calls++;
    if (calls.isEven) return const Failed(NetworkFailure());
    return Success(
      Evidence(
        id: '$calls',
        inspectionId: inspectionId,
        filePath: localFilePath,
      ),
    );
  }

  @override
  Future<Result<void>> remove(String evidenceId) async => const Success(null);
}

void main() {
  test(
    'attachPhotos uploads every photo and reports how many failed',
    () async {
      final repo = _HalfFailing();
      final failed = await attachPhotos(
        repo,
        inspectionId: '1',
        findingId: 'f1',
        photos: [
          for (var i = 0; i < 4; i++) CapturedPhoto('p$i.jpg', null, null),
        ],
      );

      expect(repo.calls, 4);
      expect(failed, 2);
    },
  );
}
