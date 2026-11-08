import 'package:flutter_test/flutter_test.dart';
import 'package:inspectly/data/models/signature.dart';
import 'package:inspectly/data/services/pdf_report_service.dart';

/// QC-044: after re-signing, the report shows only the latest signature of
/// each type, not every superseded one.
void main() {
  InspectionSignature sig(String id, SignatureType type, int day) =>
      InspectionSignature(
        id: id,
        inspectionId: '1',
        type: type,
        signerName: id,
        filePath: '$id.png',
        signedAt: DateTime(2026, 9, day),
      );

  test('keeps the newest signature per type', () {
    final latest = latestSignatures([
      sig('customer-old', SignatureType.customer, 1),
      sig('inspector', SignatureType.inspector, 2),
      sig('customer-new', SignatureType.customer, 3),
    ]);

    expect(latest.map((s) => s.id), ['inspector', 'customer-new']);
  });
}
