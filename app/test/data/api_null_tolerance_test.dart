import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inspectly/core/errors/failure.dart';
import 'package:inspectly/core/network/api_client.dart';
import 'package:inspectly/core/storage/token_storage.dart';
import 'package:inspectly/data/models/activity_entry.dart';
import 'package:inspectly/data/models/evidence.dart';
import 'package:inspectly/data/models/finding.dart';
import 'package:inspectly/data/models/inspection_item.dart';
import 'package:inspectly/data/repositories/api/api_inspection_repository.dart';

/// QC-005: the Laravel API can legitimately return null for fields the
/// app used to require (finding description edited empty in the admin,
/// checklist item removed from its template, ...). One such row must not
/// make a whole list unparseable, and a parse problem must surface as a
/// [Failure], never as a raw exception.
class _NoTokens extends TokenStorage {
  @override
  Future<String?> read() async => null;
}

class _JsonAdapter implements HttpClientAdapter {
  _JsonAdapter(this.body);
  final Object body;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async => ResponseBody.fromString(
    jsonEncode(body),
    200,
    headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    },
  );

  @override
  void close({bool force = false}) {}
}

ApiInspectionRepository _repoReturning(Object body) {
  final dio = Dio(BaseOptions(baseUrl: 'http://test/api'))
    ..httpClientAdapter = _JsonAdapter(body);
  return ApiInspectionRepository(
    client: ApiClient(dio: dio, tokenStorage: _NoTokens()),
  );
}

Map<String, dynamic> _inspectionJson() => {
  'id': 1,
  'template_id': 1,
  'template_name': 'Safety',
  'customer_id': 1,
  'customer_name': 'Northbridge',
  'site_id': 1,
  'site_name': 'Riverside',
  'inspector_id': 2,
  'inspector_name': 'Michael',
  'status': 'in_progress',
  'items': [
    {
      'id': 10,
      'inspection_id': 1,
      'template_checklist_item_id': null,
      'label': 'Removed from template',
      'result': 'fail',
      'evidence': [
        {
          'id': 5,
          'inspection_id': 1,
          'file_path': 'evidence/1/a.jpg',
          'captured_at': null,
        },
      ],
    },
  ],
  'findings': [
    {
      'id': 7,
      'inspection_id': 1,
      'title': 'Edited in admin',
      'description': null,
      'severity': 'high',
      'status': 'open',
    },
  ],
};

void main() {
  test('models accept the nullable fields the API can return', () {
    final finding = Finding.fromJson(
      normalizeIds({
            'id': 7,
            'inspection_id': 1,
            'title': 'x',
            'description': null,
            'severity': 'low',
          })
          as Map<String, dynamic>,
    );
    expect(finding.description, '');

    final item = InspectionItem.fromJson(
      normalizeIds({
            'id': 10,
            'inspection_id': 1,
            'template_checklist_item_id': null,
            'label': 'x',
          })
          as Map<String, dynamic>,
    );
    expect(item.templateChecklistItemId, '');

    final evidence = Evidence.fromJson(
      normalizeIds({
            'id': 5,
            'inspection_id': 1,
            'file_path': 'a.jpg',
            'captured_at': null,
          })
          as Map<String, dynamic>,
    );
    expect(evidence.capturedAt, isNull);

    final activity = ActivityEntry.fromJson(
      normalizeIds({
            'id': 1,
            'inspection_id': 1,
            'type': 'started',
            'description': null,
            'occurred_at': '2026-09-27T09:00:00.000000Z',
          })
          as Map<String, dynamic>,
    );
    expect(activity.description, '');
  });

  test('a list containing null fields still loads', () async {
    final result = await _repoReturning({
      'data': [_inspectionJson()],
    }).list();

    expect(result.isSuccess, isTrue);
    expect(result.dataOrNull!.single.findings.single.description, '');
  });

  test('an unexpected response shape becomes a Failure, not a crash', () async {
    final result = await _repoReturning({'data': 'not a list'}).list();

    expect(result.isSuccess, isFalse);
    result.when(
      success: (_) => fail('expected a failure'),
      failure: (f) => expect(f, isA<UnknownFailure>()),
    );
  });
}
