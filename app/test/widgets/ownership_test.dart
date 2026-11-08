import 'package:flutter_test/flutter_test.dart';
import 'package:inspectly/app/providers/repository_providers.dart';
import 'package:inspectly/core/errors/failure.dart';
import 'package:inspectly/core/utils/result.dart';
import 'package:inspectly/data/datasources/demo/demo_data_store.dart';
import 'package:inspectly/data/datasources/demo/demo_reference_data.dart';
import 'package:inspectly/data/models/app_user.dart';
import 'package:inspectly/data/models/enums.dart';
import 'package:inspectly/data/repositories/auth_repository.dart';
import 'package:inspectly/data/repositories/mock/mock_inspection_repository.dart';
import 'package:inspectly/features/inspections/inspection_detail_screen.dart';

import '../helpers/pump_screen.dart';

/// QC-001: everyone can open any inspection, but only its inspector can
/// change it — the app shows other inspectors' work as view-only, and Demo
/// Mode refuses writes the same way the API does (403).
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

void main() {
  final store = DemoDataStore.instance;
  final michael = DemoReferenceData.users.firstWhere(
    (u) => u.email == 'michael.carter@inspectly.test',
  );
  final othersOpen = store.inspections.firstWhere(
    (i) =>
        i.inspectorId != michael.id &&
        (i.status == InspectionStatus.scheduled ||
            i.status == InspectionStatus.inProgress),
  );

  test('demo mode refuses writes to another inspector\'s inspection', () async {
    store.currentUserId = michael.id;
    addTearDown(() => store.currentUserId = null);

    final result = await MockInspectionRepository().start(othersOpen.id);

    result.when(
      success: (_) => fail('expected 403'),
      failure: (f) => expect(f, isA<ForbiddenFailure>()),
    );
  });

  testWidgets('another inspector\'s inspection is view-only', (tester) async {
    await pumpScreen(
      tester,
      InspectionDetailScreen(inspectionId: othersOpen.id),
      overrides: [authRepositoryProvider.overrideWithValue(_Michael())],
    );
    await tester.pumpAndSettle();

    expect(find.text('Start Inspection'), findsNothing);
    expect(find.text('Continue Inspection'), findsNothing);
    expect(find.textContaining('View only'), findsOneWidget);
  });
}
