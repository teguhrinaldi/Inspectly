import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:inspectly/core/network/api_client.dart';
import 'package:inspectly/data/models/enums.dart';
import 'package:inspectly/data/models/inspection.dart';
import 'package:inspectly/data/models/signature.dart';

/// Regression test against a REAL response captured from the Laravel API
/// (`test/fixtures/inspection_detail.json` — `GET /inspections/3` against
/// the seeded demo dataset). This exists because the Flutter models and the
/// Laravel API resources were built somewhat independently against a shared
/// written spec, and drifted in ways `flutter analyze`/unit tests against
/// only the demo store could never catch: Laravel's auto-increment ids are
/// numbers (not strings), and InspectionResource originally had no flat
/// `template_name`/`customer_name`/etc. fields at all. If this test ever
/// needs updating because the API shape changed, re-capture the fixture with
/// a live server rather than hand-editing it.
void main() {
  test('Inspection.fromJson parses a real API response after normalizeIds', () {
    final raw = File('test/fixtures/inspection_detail.json').readAsStringSync();
    // The fixture is the raw HTTP body, which Laravel wraps in {"data": ...}
    // for a single resource — same unwrap ApiClient.unwrap() does for real.
    final decoded = normalizeIds(jsonDecode(raw)) as Map<String, dynamic>;

    final inspection = Inspection.fromJson(
      decoded['data'] as Map<String, dynamic>,
    );

    expect(inspection.id, '3');
    expect(inspection.templateName, 'Safety Inspection');
    expect(inspection.customerName, 'Northbridge Facilities');
    expect(inspection.siteName, 'Riverside Office Complex');
    expect(inspection.inspectorName, 'Michael Carter');
    expect(inspection.status, InspectionStatus.completed);
    expect(inspection.recurrence, RecurrenceType.monthly);

    expect(inspection.items, isNotEmpty);
    expect(inspection.items.every((i) => i.id.isNotEmpty), isTrue);

    expect(inspection.findings, isNotEmpty);
    final panelFinding = inspection.findings.firstWhere(
      (f) => f.title.contains('electrical panel'),
    );
    expect(panelFinding.severity, FindingSeverity.high);
    expect(panelFinding.id, isA<String>());

    expect(inspection.signatures, hasLength(2));
    expect(
      inspection.signatures.map((s) => s.type),
      containsAll([SignatureType.inspector, SignatureType.customer]),
    );
  });

  test('normalizeIds stringifies numeric id fields at any nesting depth', () {
    final input = {
      'id': 3,
      'nested': {
        'inspection_id': 3,
        'list': [
          {'finding_id': 4, 'label': 'ok'},
        ],
      },
      'not_an_id_but_ends_in_id': 'already-a-string',
      'unrelated_number': 42,
    };

    final result = normalizeIds(input) as Map;
    expect(result['id'], '3');
    expect((result['nested'] as Map)['inspection_id'], '3');
    expect(
      ((result['nested'] as Map)['list'] as List).first['finding_id'],
      '4',
    );
    expect(result['unrelated_number'], 42); // untouched: not an id key
  });
}
