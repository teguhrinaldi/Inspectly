// End-to-end check of the real API repositories against a running Laravel
// server seeded with the demo story. Skipped unless INSPECTLY_E2E_URL is set:
//
//   php artisan migrate:fresh --seed && php artisan serve --port=8765
//   INSPECTLY_E2E_URL=http://127.0.0.1:8765/api flutter test test/e2e
//
// Runs the main inspector journey: login → data → create & start →
// checklist → finding + photo → both signatures → complete → logout →
// login again. It creates data, so never point it at production.
@TestOn('vm')
library;

import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inspectly/core/errors/failure.dart';
import 'package:inspectly/core/network/api_client.dart';
import 'package:inspectly/core/storage/token_storage.dart';
import 'package:inspectly/core/utils/result.dart';
import 'package:inspectly/data/models/enums.dart';
import 'package:inspectly/data/models/finding.dart';
import 'package:inspectly/data/models/signature.dart';
import 'package:inspectly/data/repositories/api/api_auth_repository.dart';
import 'package:inspectly/data/repositories/api/api_evidence_repository.dart';
import 'package:inspectly/data/repositories/api/api_inspection_repository.dart';
import 'package:inspectly/data/repositories/api/api_signature_repository.dart';
import 'package:inspectly/data/repositories/api/api_site_repository.dart';
import 'package:inspectly/data/repositories/api/api_template_repository.dart';

class _MemoryTokens extends TokenStorage {
  String? token;
  String? user;
  @override
  Future<String?> read() async => token;
  @override
  Future<void> write(String value) async => token = value;
  @override
  Future<void> clear() async => token = user = null;
  @override
  Future<String?> readUser() async => user;
  @override
  Future<void> writeUser(String json) async => user = json;
}

T ok<T>(Result<T> r, String step) => r.when(
  success: (d) => d,
  failure: (f) => fail('$step failed: ${f.runtimeType} ${f.message}'),
);

void main() {
  final baseUrl = Platform.environment['INSPECTLY_E2E_URL'];

  test(
    'inspector journey against a live API',
    () async {
      final tokens = _MemoryTokens();
      final client = ApiClient(
        dio: Dio(
          BaseOptions(
            baseUrl: baseUrl!,
            headers: {'Accept': 'application/json'},
          ),
        ),
        tokenStorage: tokens,
      );
      final auth = ApiAuthRepository(client: client, tokenStorage: tokens);
      final inspections = ApiInspectionRepository(client: client);
      final sites = ApiSiteRepository(client: client);
      final templates = ApiTemplateRepository(client: client);
      final evidence = ApiEvidenceRepository(client: client);
      final signatures = ApiSignatureRepository(client: client);

      // Admin accounts are refused by the app.
      final admin = await auth.login(
        email: 'admin@inspectly.test',
        password: 'password',
      );
      expect(admin.isSuccess, isFalse);
      expect(tokens.token, isNull);

      // 1. Login + session.
      final me = ok(
        await auth.login(
          email: 'michael.carter@inspectly.test',
          password: 'password',
        ),
        'login',
      );
      expect(me.role, UserRole.inspector);
      expect(ok(await auth.currentUser(), 'me').email, me.email);

      // 2. Reference data (all pages) + QR lookup through the server.
      final allInspections = ok(await inspections.list(), 'list inspections');
      expect(allInspections.length, greaterThanOrEqualTo(48));
      final siteList = ok(await sites.list(), 'list sites');
      expect(siteList, isNotEmpty);
      final site = ok(
        await sites.findByQrCode(siteList.last.qrCode),
        'find site by QR',
      );
      final template = ok(
        await templates.list(activeOnly: true),
        'templates',
      ).first;

      // 3. Create + start.
      final created = ok(
        await inspections.create(
          templateId: template.id,
          siteId: site.id,
          customerId: site.customerId,
          inspectorId: me.id,
          recurrence: RecurrenceType.oneTime,
        ),
        'create',
      );
      final started = ok(
        await inspections.start(
          created.id,
          locationLat: -6.2,
          locationLng: 106.8,
        ),
        'start',
      );
      expect(started.status, InspectionStatus.inProgress);
      expect(started.items, isNotEmpty);

      // Completing with unanswered items is refused (422).
      final early = await inspections.complete(created.id);
      early.when(
        success: (_) => fail('complete with open items must fail'),
        failure: (f) => expect(f, isA<ValidationFailure>()),
      );

      // 4. Checklist: all pass, first item fails with a finding + photo.
      for (final (i, item) in started.items.indexed) {
        ok(
          await inspections.updateChecklistItem(
            inspectionId: created.id,
            itemId: item.id,
            result: i == 0 ? ChecklistResult.fail : ChecklistResult.pass,
            note: i == 0 ? 'Cable hangs loose — fix today’s issue 🔧' : null,
          ),
          'checklist item $i',
        );
      }
      final finding = ok(
        await inspections.addFinding(
          Finding(
            id: 'local',
            inspectionId: created.id,
            inspectionItemId: started.items.first.id,
            title: 'Loose cable',
            description: 'Hangs from the ceiling.',
            severity: FindingSeverity.high,
          ),
        ),
        'add finding',
      );
      final photo = File('assets/images/evidence/electrical_panel_damage.jpg');
      ok(
        await evidence.attach(
          inspectionId: created.id,
          findingId: finding.id,
          localFilePath: photo.path,
          latitude: -6.2,
          longitude: 106.8,
        ),
        'upload evidence',
      );

      // 5. Both signatures, then complete (twice: idempotent).
      for (final type in SignatureType.values) {
        ok(
          await signatures.save(
            inspectionId: created.id,
            type: type,
            signerName: type.name,
            localFilePath: photo.path,
          ),
          'signature ${type.name}',
        );
      }
      final done = ok(await inspections.complete(created.id), 'complete');
      expect(done.status, InspectionStatus.completed);
      expect(done.findings.single.evidence, hasLength(1));
      expect(done.signatures, hasLength(2));
      final again = ok(
        await inspections.complete(created.id),
        'complete again',
      );
      expect(again.completedAt, done.completedAt);

      // Starting a completed inspection is a conflict (409).
      final restart = await inspections.start(created.id);
      restart.when(
        success: (_) => fail('restart must fail'),
        failure: (f) => expect(f, isA<ConflictFailure>()),
      );
      ok(await sites.history(site.id), 'site history');
      ok(await sites.comparison(site.id, created.id), 'comparison');
      expect(
        ok(await inspections.activities(created.id), 'activities'),
        isNotEmpty,
      );

      // 6. Logout ends the session; logging in again works.
      ok(await auth.logout(), 'logout');
      expect(tokens.token, isNull);
      final afterLogout = await inspections.list();
      expect(afterLogout.isSuccess, isFalse);
      ok(
        await auth.login(
          email: 'michael.carter@inspectly.test',
          password: 'password',
        ),
        'login again',
      );
      expect(
        ok(await inspections.getById(created.id), 'reload').status,
        InspectionStatus.completed,
      );
    },
    skip: baseUrl == null
        ? 'Set INSPECTLY_E2E_URL to run against a live server'
        : false,
    timeout: const Timeout(Duration(minutes: 3)),
  );
}
