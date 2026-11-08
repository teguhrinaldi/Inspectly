import 'package:flutter_test/flutter_test.dart';
import 'package:inspectly/data/datasources/demo/demo_data_store.dart';
import 'package:inspectly/data/models/enums.dart';
import 'package:inspectly/features/dashboard/dashboard_screen.dart';

/// QC-040: started/completed inspections lose their reminder; only
/// scheduled ones get one (the evening before, 18:00).
void main() {
  test('reminders are cancelled once an inspection is no longer scheduled', () {
    final base = DemoDataStore.instance.inspections.first;
    final at = DateTime(2026, 12, 5, 9);
    final plan = reminderPlan([
      base.copyWith(
        id: 'sched',
        status: InspectionStatus.scheduled,
        scheduledAt: at,
      ),
      base.copyWith(
        id: 'started',
        status: InspectionStatus.inProgress,
        scheduledAt: at,
      ),
      base.copyWith(
        id: 'done',
        status: InspectionStatus.completed,
        scheduledAt: at,
      ),
    ]);

    expect(plan.schedule, {'sched': DateTime(2026, 12, 4, 18)});
    expect(plan.cancel, containsAll(['started', 'done']));
  });
}
