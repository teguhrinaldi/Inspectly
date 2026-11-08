import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inspectly/app/providers/repository_providers.dart';
import 'package:inspectly/core/errors/failure.dart';
import 'package:inspectly/core/utils/result.dart';
import 'package:inspectly/data/datasources/demo/demo_reference_data.dart';
import 'package:inspectly/data/models/app_user.dart';
import 'package:inspectly/data/models/enums.dart';
import 'package:inspectly/data/repositories/auth_repository.dart';
import 'package:inspectly/data/models/inspection.dart';
import 'package:inspectly/data/repositories/inspection_repository.dart';
import 'package:inspectly/data/repositories/mock/mock_inspection_repository.dart';
import 'package:inspectly/features/create/create_inspection_screen.dart';

import '../helpers/pump_screen.dart';

/// QC-035: when starting fails, the user is told why and is not dropped
/// into a checklist that can't be filled in.
class _StartFails implements InspectionRepository {
  final _real = MockInspectionRepository();

  @override
  Future<Result<Inspection>> start(
    String id, {
    double? locationLat,
    double? locationLng,
  }) async => const Failed(ConflictFailure('Started on another device.'));

  @override
  Future<Result<Inspection>> create({
    required String templateId,
    required String siteId,
    required String customerId,
    required String inspectorId,
    required RecurrenceType recurrence,
    DateTime? scheduledAt,
  }) => _real.create(
    templateId: templateId,
    siteId: siteId,
    customerId: customerId,
    inspectorId: inspectorId,
    recurrence: recurrence,
    scheduledAt: scheduledAt,
  );

  @override
  Future<Result<List<Inspection>>> list([
    InspectionListFilter filter = const InspectionListFilter(),
  ]) => _real.list(filter);

  @override
  Future<Result<Inspection>> getById(String id) => _real.getById(id);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  testWidgets(
    'a failed start shows the reason and does not open the checklist',
    (tester) async {
      // Location services "off" (the geolocator plugin isn't available in
      // widget tests and its calls would never complete otherwise).
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        const MethodChannel('flutter.baseflow.com/geolocator'),
        (call) async =>
            call.method == 'isLocationServiceEnabled' ? false : null,
      );
      final router = await pumpScreen(
        tester,
        const CreateInspectionScreen(),
        overrides: [
          inspectionRepositoryProvider.overrideWithValue(_StartFails()),
          authRepositoryProvider.overrideWithValue(_Michael()),
        ],
      );
      await tester.pumpAndSettle();
      final rows = find.byWidgetPredicate(
        (w) => w.runtimeType.toString() == '_SelectRow',
      );
      await tester.ensureVisible(rows.first);
      await tester.tap(rows.first); // first site
      await tester.pump();
      final templateRow = rows.at(
        tester.widgetList(rows).length - 1,
      ); // last row = a template
      await tester.ensureVisible(templateRow);
      await tester.tap(templateRow);
      await tester.pump();
      await tester.ensureVisible(find.text('Start Inspection'));
      await tester.tap(find.text('Start Inspection'));
      for (var i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 200));
      }

      expect(find.textContaining('Started on another device.'), findsOneWidget);
      expect(
        router.routerDelegate.currentConfiguration.uri.toString(),
        isNot(contains('/checklist/')),
      );
    },
  );
}

class _Michael implements AuthRepository {
  AppUser get _user => DemoReferenceData.users.firstWhere(
    (u) => u.email == 'michael.carter@inspectly.test',
  );

  @override
  Future<Result<AppUser>> currentUser() async => Success(_user);
  @override
  Future<bool> isLoggedIn() async => true;
  @override
  Future<Result<AppUser>> login({
    required String email,
    required String password,
  }) async => Success(_user);
  @override
  Future<Result<void>> logout() async => const Success(null);
}
