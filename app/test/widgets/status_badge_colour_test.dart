import 'package:flutter_test/flutter_test.dart';
import 'package:inspectly/app/providers/repository_providers.dart';
import 'package:inspectly/core/widgets/status_style.dart';
import 'package:inspectly/data/datasources/demo/demo_data_store.dart';
import 'package:inspectly/data/models/enums.dart';
import 'package:inspectly/features/inspections/inspection_detail_screen.dart';

import '../helpers/fake_auth.dart';
import '../helpers/pump_screen.dart';

/// QC-059: "In Progress" uses the same badge colour everywhere (orange, as
/// in the reference's lists, home and admin screens).
void main() {
  testWidgets('detail uses the shared In Progress badge style', (tester) async {
    final running = DemoDataStore.instance.inspections.firstWhere(
      (i) => i.status == InspectionStatus.inProgress,
    );
    await pumpScreen(
      tester,
      InspectionDetailScreen(inspectionId: running.id),
      overrides: [
        authRepositoryProvider.overrideWithValue(
          SignedInAs(running.inspectorId),
        ),
      ],
    );
    await tester.pumpAndSettle();

    final badge = tester.widget<StatusBadge>(
      find.byWidgetPredicate(
        (w) => w is StatusBadge && w.style.label == 'In Progress',
      ),
    );
    expect(
      badge.style.tone,
      StatusStyle.forInspectionStatus(InspectionStatus.inProgress).tone,
    );
  });
}
