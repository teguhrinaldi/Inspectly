import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../../../core/errors/failure.dart';
import '../../../core/utils/result.dart';
import '../../datasources/demo/demo_data_store.dart';
import '../../models/signature.dart';
import '../signature_repository.dart';

class MockSignatureRepository implements SignatureRepository {
  final DemoDataStore _store = DemoDataStore.instance;
  static const _uuid = Uuid();

  @override
  Future<Result<InspectionSignature>> save({
    required String inspectionId,
    required SignatureType type,
    required String signerName,
    required String localFilePath,
  }) async {
    try {
      final docsDir = await getApplicationDocumentsDirectory();
      final signaturesDir = Directory(
        p.join(docsDir.path, 'inspectly', 'signatures'),
      );
      if (!await signaturesDir.exists()) {
        await signaturesDir.create(recursive: true);
      }
      final storedPath = p.join(signaturesDir.path, '${_uuid.v4()}.png');
      await File(localFilePath).copy(storedPath);

      final signature = InspectionSignature(
        id: 'sig-${_uuid.v4()}',
        inspectionId: inspectionId,
        type: type,
        signerName: signerName,
        filePath: storedPath,
        signedAt: DateTime.now(),
      );
      _store.addSignature(signature);
      return Success(signature);
    } catch (e) {
      return Failed(UnknownFailure('Could not save the signature: $e'));
    }
  }
}
