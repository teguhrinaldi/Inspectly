import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../models/enums.dart';
import '../models/evidence.dart';
import '../models/inspection.dart';
import '../models/signature.dart';
import '../../core/utils/media_source.dart';
import '../../core/utils/risk_breakdown.dart';

/// Generates a real, shareable PDF report from a completed inspection —
/// entirely on-device, no external/paid service (spec §9.14, §28). The
/// document mirrors the JSON shape Laravel's `/reports/{id}` endpoint
/// returns, so demo mode and API mode produce an identical report.
class PdfReportService {
  static final _navy = PdfColor.fromHex('#16244A');
  static final _gray500 = PdfColor.fromHex('#6B7885');
  static final _gray200 = PdfColor.fromHex('#E2E7ED');
  static final _success = PdfColor.fromHex('#16A34A');
  static final _critical = PdfColor.fromHex('#E02D2D');
  static final _warning = PdfColor.fromHex('#F07A12');

  Future<Uint8List> generate(Inspection inspection) async {
    final doc = pw.Document(
      title: '${inspection.templateName} — ${inspection.siteName}',
    );

    final findingEvidenceBytes = <String, Uint8List>{};
    for (final finding in inspection.findings) {
      for (final e in finding.evidence) {
        final bytes = await _loadBytes(e);
        if (bytes != null) findingEvidenceBytes[e.id] = bytes;
      }
    }
    final signatureBytes = <String, Uint8List>{};
    for (final sig in inspection.signatures) {
      final bytes = await _loadFileBytes(sig.displaySource);
      if (bytes != null) signatureBytes[sig.id] = bytes;
    }

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (context) => _buildHeader(inspection),
        footer: (context) => pw.Align(
          alignment: pw.Alignment.centerRight,
          child: pw.Text(
            'Page ${context.pageNumber} of ${context.pagesCount}',
            style: pw.TextStyle(fontSize: 9, color: _gray500),
          ),
        ),
        build: (context) => [
          _buildSummarySection(inspection),
          pw.SizedBox(height: 16),
          _buildChecklistSection(inspection),
          pw.SizedBox(height: 16),
          if (inspection.findings.isNotEmpty)
            _buildFindingsSection(inspection, findingEvidenceBytes),
          pw.SizedBox(height: 16),
          _buildSignaturesSection(inspection, signatureBytes),
        ],
      ),
    );

    return doc.save();
  }

  pw.Widget _buildHeader(Inspection inspection) {
    return pw.Column(
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              'INSPECTLY',
              style: pw.TextStyle(
                fontSize: 18,
                fontWeight: pw.FontWeight.bold,
                color: _navy,
              ),
            ),
            pw.Text(
              inspection.templateName,
              style: pw.TextStyle(fontSize: 12, color: _gray500),
            ),
          ],
        ),
        pw.SizedBox(height: 6),
        pw.Divider(color: _gray200, thickness: 1),
      ],
    );
  }

  pw.Widget _buildSummarySection(Inspection inspection) {
    final risk = RiskBreakdown(inspection);
    final pct = risk.compliance;
    final needsAttention = risk.needsAttention;
    final critical = risk.failed;

    return pw.Container(
      padding: const pw.EdgeInsets.all(14),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: _gray200),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            inspection.siteName,
            style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
          ),
          pw.Text(
            inspection.siteAddress ?? '',
            style: pw.TextStyle(fontSize: 10, color: _gray500),
          ),
          pw.SizedBox(height: 10),
          pw.Row(
            children: [
              _summaryField('Customer', inspection.customerName),
              _summaryField('Inspector', inspection.inspectorName),
              _summaryField(
                'Date',
                inspection.completedAt != null
                    ? DateFormat('MMM d, yyyy').format(inspection.completedAt!)
                    : '—',
              ),
            ],
          ),
          pw.SizedBox(height: 10),
          pw.Row(
            children: [
              pw.Text(
                '$pct% Overall Compliance · ${risk.passed} Passed',
                style: pw.TextStyle(
                  fontSize: 13,
                  fontWeight: pw.FontWeight.bold,
                  color: _navy,
                ),
              ),
              pw.SizedBox(width: 16),
              if (needsAttention > 0)
                pw.Text(
                  '$needsAttention Needs Attention',
                  style: pw.TextStyle(fontSize: 11, color: _warning),
                ),
              pw.SizedBox(width: 16),
              if (critical > 0)
                pw.Text(
                  '$critical Failed',
                  style: pw.TextStyle(fontSize: 11, color: _critical),
                ),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _summaryField(String label, String value) {
    return pw.Expanded(
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(label, style: pw.TextStyle(fontSize: 9, color: _gray500)),
          pw.Text(value, style: pw.TextStyle(fontSize: 11)),
        ],
      ),
    );
  }

  pw.Widget _buildChecklistSection(Inspection inspection) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Checklist Results',
          style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 6),
        pw.Table(
          border: pw.TableBorder(
            horizontalInside: pw.BorderSide(color: _gray200),
          ),
          columnWidths: {
            0: const pw.FlexColumnWidth(3),
            1: const pw.FlexColumnWidth(1),
          },
          children: inspection.items.map((item) {
            final color = switch (item.result) {
              ChecklistResult.pass => _success,
              ChecklistResult.fail => _critical,
              ChecklistResult.na => _gray500,
              null => _gray500,
            };
            final label = switch (item.result) {
              ChecklistResult.pass => 'Pass',
              ChecklistResult.fail => 'Fail',
              ChecklistResult.na => 'N/A',
              null => 'Pending',
            };
            return pw.TableRow(
              children: [
                pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(vertical: 4),
                  child: pw.Text(
                    item.label,
                    style: const pw.TextStyle(fontSize: 10),
                  ),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(vertical: 4),
                  child: pw.Text(
                    label,
                    style: pw.TextStyle(
                      fontSize: 10,
                      color: color,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }

  pw.Widget _buildFindingsSection(
    Inspection inspection,
    Map<String, Uint8List> evidenceBytes,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Findings',
          style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 6),
        ...inspection.findings.map((finding) {
          final color = switch (finding.severity) {
            FindingSeverity.critical => _critical,
            FindingSeverity.high => _warning,
            FindingSeverity.medium => _warning,
            FindingSeverity.low => _gray500,
          };
          return pw.Container(
            margin: const pw.EdgeInsets.only(bottom: 10),
            padding: const pw.EdgeInsets.all(10),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: _gray200),
              borderRadius: pw.BorderRadius.circular(6),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  children: [
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: pw.BoxDecoration(
                        color: color,
                        borderRadius: pw.BorderRadius.circular(3),
                      ),
                      child: pw.Text(
                        finding.severity.name.toUpperCase(),
                        style: pw.TextStyle(
                          fontSize: 8,
                          color: PdfColors.white,
                        ),
                      ),
                    ),
                    pw.SizedBox(width: 6),
                    pw.Text(
                      finding.title,
                      style: pw.TextStyle(
                        fontSize: 11,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  finding.description,
                  style: const pw.TextStyle(fontSize: 10),
                ),
                if (finding.recommendation != null) ...[
                  pw.SizedBox(height: 4),
                  pw.Text(
                    'Recommendation: ${finding.recommendation}',
                    style: pw.TextStyle(fontSize: 9, color: _gray500),
                  ),
                ],
                if (finding.evidence.isNotEmpty) ...[
                  pw.SizedBox(height: 6),
                  pw.Row(
                    children: finding.evidence
                        .where((e) => evidenceBytes.containsKey(e.id))
                        .map(
                          (e) => pw.Padding(
                            padding: const pw.EdgeInsets.only(right: 6),
                            child: pw.Image(
                              pw.MemoryImage(evidenceBytes[e.id]!),
                              width: 90,
                              height: 90,
                              fit: pw.BoxFit.cover,
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ],
            ),
          );
        }),
      ],
    );
  }

  pw.Widget _buildSignaturesSection(
    Inspection inspection,
    Map<String, Uint8List> signatureBytes,
  ) {
    if (inspection.signatures.isEmpty) return pw.SizedBox.shrink();
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Signatures',
          style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 6),
        pw.Row(
          children: inspection.signatures.map((sig) {
            final bytes = signatureBytes[sig.id];
            return pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  if (bytes != null)
                    pw.Image(pw.MemoryImage(bytes), height: 60),
                  pw.Divider(color: _gray200),
                  pw.Text(
                    sig.signerName,
                    style: const pw.TextStyle(fontSize: 10),
                  ),
                  pw.Text(
                    sig.type == SignatureType.inspector
                        ? 'Inspector'
                        : 'Customer',
                    style: pw.TextStyle(fontSize: 9, color: _gray500),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Future<Uint8List?> _loadBytes(Evidence evidence) =>
      _loadFileBytes(evidence.displaySource);

  /// Image bytes for the report, or null when the file is missing, the
  /// server doesn't answer (in time) or the data isn't a JPEG/PNG — one bad
  /// photo is left out instead of failing the whole report (QC-016).
  Future<Uint8List?> _loadFileBytes(String path) async {
    try {
      final bytes = await _readBytes(path);
      return _looksLikeImage(bytes) ? bytes : null;
    } catch (e) {
      debugPrint('PdfReportService: skipping image $path: $e');
      return null;
    }
  }

  Future<Uint8List> _readBytes(String path) async {
    if (path.startsWith('assets/')) {
      final data = await rootBundle.load(path);
      return data.buffer.asUint8List();
    }
    if (path.startsWith('http://') || path.startsWith('https://')) {
      final client = HttpClient()
        ..connectionTimeout = const Duration(seconds: 10);
      try {
        final request = await client.getUrl(Uri.parse(path));
        final response = await request.close().timeout(
          const Duration(seconds: 20),
        );
        if (response.statusCode != HttpStatus.ok) {
          throw HttpException(
            'HTTP ${response.statusCode}',
            uri: Uri.parse(path),
          );
        }
        final builder = BytesBuilder(copy: false);
        await for (final chunk in response.timeout(
          const Duration(seconds: 20),
        )) {
          builder.add(chunk);
        }
        return builder.takeBytes();
      } finally {
        client.close(force: true);
      }
    }
    return File(path).readAsBytes();
  }

  static bool _looksLikeImage(Uint8List b) =>
      (b.length > 3 && b[0] == 0xFF && b[1] == 0xD8) || // JPEG
      (b.length > 8 &&
          b[0] == 0x89 &&
          b[1] == 0x50 &&
          b[2] == 0x4E &&
          b[3] == 0x47); // PNG
}
