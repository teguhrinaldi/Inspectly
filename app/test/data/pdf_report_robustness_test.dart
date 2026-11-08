import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:inspectly/data/datasources/demo/demo_data_store.dart';
import 'package:inspectly/data/models/evidence.dart';
import 'package:inspectly/data/services/pdf_report_service.dart';

/// QC-016: one missing or broken photo must not make the whole report fail.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'report is generated even when evidence files are missing or broken',
    () async {
      final store = DemoDataStore.instance;
      final base = store.inspections.firstWhere((i) => i.findings.isNotEmpty);
      final broken = File('${Directory.systemTemp.path}/qc016_broken.jpg')
        ..writeAsStringSync('<html>404 Not Found</html>');
      final finding = base.findings.first;
      final inspection = base.copyWith(
        findings: [
          finding.copyWith(
            evidence: [
              ...finding.evidence,
              Evidence(
                id: 'missing',
                inspectionId: base.id,
                filePath: '${Directory.systemTemp.path}/does_not_exist.jpg',
              ),
              Evidence(
                id: 'broken',
                inspectionId: base.id,
                filePath: broken.path,
              ),
            ],
          ),
          ...base.findings.skip(1),
        ],
      );

      final bytes = await PdfReportService().generate(inspection);

      expect(bytes.length, greaterThan(1000));
      expect(String.fromCharCodes(bytes.take(5)), '%PDF-');
    },
  );
}
