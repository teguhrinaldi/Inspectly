import 'dart:async';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inspectly/core/network/api_client.dart';
import 'package:inspectly/core/storage/token_storage.dart';
import 'package:inspectly/data/models/evidence.dart';
import 'package:inspectly/data/repositories/api/api_evidence_repository.dart';
import 'package:inspectly/data/services/location_service.dart';

/// QC-043: a precise fix gets at most a few seconds, then the last known
/// position is used; the accuracy travels with the photo to the API.
class _NoTokens extends TokenStorage {
  @override
  Future<String?> read() async => null;
}

class _CaptureForm implements HttpClientAdapter {
  String body = '';
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final bytes = <int>[];
    await for (final chunk in requestStream!) {
      bytes.addAll(chunk);
    }
    body = String.fromCharCodes(bytes);
    return ResponseBody.fromString(
      '{"data":{"id":1,"inspection_id":1,"file_path":"x.jpg","accuracy":12.5}}',
      201,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('a slow precise fix falls back to the last known position', () async {
    final service = LocationService(
      preciseTimeout: const Duration(milliseconds: 50),
      serviceEnabled: () async => true,
      permission: () async => true,
      precise: () => Completer<LocationFix>().future, // never answers
      lastKnown: () async => const LocationFix(-6.2, 106.8, 35),
    );

    final result = await service.getCurrentLocation();

    expect(result, isA<LocationSuccess>());
    final fix = result as LocationSuccess;
    expect([fix.latitude, fix.longitude, fix.accuracy], [-6.2, 106.8, 35]);
    expect(fix.isLastKnown, isTrue);
  });

  test('accuracy is sent with the photo and read back', () async {
    final adapter = _CaptureForm();
    final dio = Dio(BaseOptions(baseUrl: 'http://test/api'))
      ..httpClientAdapter = adapter;
    final repo = ApiEvidenceRepository(
      client: ApiClient(dio: dio, tokenStorage: _NoTokens()),
    );

    final result = await repo.attach(
      inspectionId: '1',
      localFilePath: 'pubspec.yaml',
      latitude: -6.2,
      longitude: 106.8,
      accuracy: 12.5,
    );

    expect(adapter.body, contains('name="accuracy"'));
    expect(result.dataOrNull?.accuracy, 12.5);
    expect(
      Evidence.fromJson({
        'id': '1',
        'inspection_id': '1',
        'file_path': 'x',
        'accuracy': 3,
      }).accuracy,
      3,
    );
  });
}
