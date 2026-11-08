import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inspectly/core/network/api_client.dart';
import 'package:inspectly/core/storage/token_storage.dart';
import 'package:inspectly/data/repositories/api/api_site_repository.dart';

/// QC-006: Laravel paginates every list. The app must read all pages, and
/// a QR lookup must ask the server for that exact code instead of scanning
/// whatever happened to be on page one.
class _NoTokens extends TokenStorage {
  @override
  Future<String?> read() async => null;
}

Map<String, dynamic> _site(int n) => {
  'id': n,
  'customer_id': 1,
  'customer_name': 'Northbridge',
  'name': 'Site $n',
  'qr_code': 'INSPECTLY:SITE:S-$n',
  'status': 'active',
};

/// Serves 35 sites, `per_page` at a time, honouring `page` and `qr_code`.
class _SitesAdapter implements HttpClientAdapter {
  final requests = <Map<String, dynamic>>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final q = options.queryParameters;
    requests.add(q);
    var rows = [for (var i = 1; i <= 35; i++) _site(i)];
    if (q['qr_code'] != null) {
      rows = rows.where((r) => r['qr_code'] == q['qr_code']).toList();
    }
    final perPage = int.parse('${q['per_page'] ?? 15}');
    final page = int.parse('${q['page'] ?? 1}');
    final lastPage = rows.isEmpty ? 1 : ((rows.length - 1) ~/ perPage) + 1;
    final slice = rows.skip((page - 1) * perPage).take(perPage).toList();
    return ResponseBody.fromString(
      jsonEncode({
        'data': slice,
        'meta': {'current_page': page, 'last_page': lastPage, 'per_page': perPage},
      }),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  late _SitesAdapter adapter;
  late ApiSiteRepository repo;

  setUp(() {
    adapter = _SitesAdapter();
    final dio = Dio(BaseOptions(baseUrl: 'http://test/api'))
      ..httpClientAdapter = adapter;
    repo = ApiSiteRepository(
      client: ApiClient(dio: dio, tokenStorage: _NoTokens()),
    );
  });

  test('list() returns every page, not only the first', () async {
    final result = await repo.list();
    expect(result.dataOrNull, hasLength(35));
  });

  test('findByQrCode finds a site beyond the first page', () async {
    final result = await repo.findByQrCode('INSPECTLY:SITE:S-34');
    expect(result.dataOrNull?.name, 'Site 34');
    expect(adapter.requests.last['qr_code'], 'INSPECTLY:SITE:S-34');
  });
}
