import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inspectly/app/providers/repository_providers.dart';
import 'package:inspectly/core/utils/result.dart';
import 'package:inspectly/data/datasources/demo/demo_data_store.dart';
import 'package:inspectly/data/models/app_user.dart';
import 'package:inspectly/data/models/enums.dart';
import 'package:inspectly/data/models/finding.dart';
import 'package:inspectly/data/models/inspection.dart';
import 'package:inspectly/data/repositories/auth_repository.dart';
import 'package:inspectly/data/repositories/inspection_repository.dart';
import 'package:inspectly/data/repositories/mock/mock_inspection_repository.dart';
import 'package:inspectly/features/auth/login_screen.dart';
import 'package:inspectly/features/checklist/checklist_screen.dart';
import 'package:inspectly/features/checklist/widgets/finding_form_sheet.dart';

import '../helpers/fake_auth.dart';
import '../helpers/pump_screen.dart';

/// QC-032: actions that wait on the network must not run twice when the
/// user repeats them during the wait.
class _SlowAuth implements AuthRepository {
  int logins = 0;
  final gate = Completer<void>();

  @override
  Future<Result<AppUser>> login({
    required String email,
    required String password,
  }) async {
    logins++;
    await gate.future;
    return const Success(
      AppUser(id: '1', name: 'M', email: 'm@x.test', role: UserRole.inspector),
    );
  }

  @override
  Future<bool> isLoggedIn() async => false;
  @override
  Future<Result<AppUser>> currentUser() async => throw UnimplementedError();
  @override
  Future<Result<void>> logout() async => const Success(null);
}

class _SlowNotes implements InspectionRepository {
  final _real = MockInspectionRepository();

  @override
  Future<Result<Inspection>> getById(String id) => _real.getById(id);

  @override
  Future<Result<Inspection>> updateChecklistItem({
    required String inspectionId,
    required String itemId,
    ChecklistResult? result,
    String? note,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    return _real.updateChecklistItem(
      inspectionId: inspectionId,
      itemId: itemId,
      result: result,
      note: note,
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  testWidgets('pressing Done twice on the password field logs in once', (
    tester,
  ) async {
    final auth = _SlowAuth();
    await pumpScreen(
      tester,
      const LoginScreen(),
      overrides: [authRepositoryProvider.overrideWithValue(auth)],
    );
    await tester.pumpAndSettle();
    final fields = find.byType(TextFormField);
    await tester.enterText(fields.first, 'michael.carter@inspectly.test');
    await tester.enterText(fields.last, 'password');

    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();

    expect(auth.logins, 1);
    auth.gate.complete();
    await tester.pumpAndSettle();
  });

  testWidgets('a double tap on Next advances one item while a note saves', (
    tester,
  ) async {
    final store = DemoDataStore.instance;
    final inspection = store.inspections.firstWhere(
      (i) =>
          i.status == InspectionStatus.inProgress &&
          i.items.length > 3 &&
          i.items.first.result == null,
      orElse: () => store.inspections.firstWhere(
        (i) => i.status == InspectionStatus.inProgress,
      ),
    );
    await pumpScreen(
      tester,
      ChecklistScreen(inspectionId: inspection.id),
      overrides: [
        authRepositoryProvider.overrideWithValue(
          SignedInAs(inspection.inspectorId),
        ),
        inspectionRepositoryProvider.overrideWithValue(_SlowNotes()),
      ],
    );
    await tester.pumpAndSettle();
    final before = RegExp(r'^(\d+) / ')
        .firstMatch(
          tester
              .widgetList<Text>(find.textContaining(' / '))
              .map((t) => t.data ?? '')
              .firstWhere((s) => RegExp(r'^\d+ / \d+$').hasMatch(s)),
        )!
        .group(1)!;

    await tester.enterText(find.byType(TextField), 'Changed note');
    await tester.tap(find.text('Next'));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle(const Duration(seconds: 1));

    expect(
      find.text('${int.parse(before) + 1} / ${inspection.items.length}'),
      findsOneWidget,
    );
  });

  testWidgets('Fail cannot open a second finding form while the first saves', (
    tester,
  ) async {
    final repo = _SlowFindings();
    final inspection = DemoDataStore.instance.inspections.firstWhere(
      (i) =>
          i.status == InspectionStatus.inProgress &&
          i.items.any((item) => item.result == null),
    );
    await pumpScreen(
      tester,
      ChecklistScreen(inspectionId: inspection.id),
      overrides: [
        authRepositoryProvider.overrideWithValue(
          SignedInAs(inspection.inspectorId),
        ),
        inspectionRepositoryProvider.overrideWithValue(repo),
      ],
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Fail').first);
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, 'e.g. Damaged Electrical Panel'),
      'Loose cable',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'What did you observe?'),
      'Cable hangs from the ceiling.',
    );
    await tester.scrollUntilVisible(
      find.text('Save Finding'),
      200,
      scrollable: find
          .descendant(
            of: find.byType(FindingFormSheet),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    await tester.tap(find.text('Save Finding'));
    await tester.pump(
      const Duration(milliseconds: 400),
    ); // sheet closed, saving

    await tester.tap(find.text('Fail').first);
    await tester.pumpAndSettle();

    expect(find.byType(FindingFormSheet), findsNothing);
    expect(repo.findingsAdded, 1);
    await tester.pump(const Duration(seconds: 3)); // let the slow save finish
    await tester.pumpAndSettle();
  });
}

class _SlowFindings implements InspectionRepository {
  final _real = MockInspectionRepository();
  int findingsAdded = 0;

  @override
  Future<Result<Inspection>> getById(String id) => _real.getById(id);

  @override
  Future<Result<Inspection>> updateChecklistItem({
    required String inspectionId,
    required String itemId,
    ChecklistResult? result,
    String? note,
  }) => _real.updateChecklistItem(
    inspectionId: inspectionId,
    itemId: itemId,
    result: result,
    note: note,
  );

  @override
  Future<Result<Finding>> addFinding(Finding finding) async {
    findingsAdded++;
    await Future<void>.delayed(const Duration(seconds: 2));
    return _real.addFinding(finding);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
