import 'package:flutter_test/flutter_test.dart';
import 'package:inspectly/core/utils/risk_breakdown.dart';
import 'package:inspectly/data/datasources/demo/demo_data_store.dart';
import 'package:inspectly/data/datasources/demo/demo_inspections_seed.dart';
import 'package:inspectly/data/datasources/demo/demo_reference_data.dart';
import 'package:inspectly/data/models/enums.dart';
import 'package:inspectly/data/models/inspection.dart';
import 'package:inspectly/data/models/inspection_item.dart';
import 'package:inspectly/data/models/inspection_template.dart';

void main() {
  final store = DemoDataStore.instance;
  Inspection byId(String id) => store.findInspection(id)!;

  group('Templates match the mockup', () {
    test(
      'Safety: Fire Safety 4 / Electrical Safety 3 / General Condition 5',
      () {
        expect(
          DemoReferenceData.templateSafety.sections
              .map((s) => (s.title, s.items.length))
              .toList(),
          [
            ('Fire Safety', 4),
            ('Electrical Safety', 3),
            ('General Condition', 5),
          ],
        );
      },
    );

    test('Property 10 / Equipment 8 / Vehicle 9, each in 3 sections', () {
      int count(InspectionTemplate t) =>
          t.sections.fold<int>(0, (n, s) => n + s.items.length);
      expect(count(DemoReferenceData.templateProperty), 10);
      expect(count(DemoReferenceData.templateEquipment), 8);
      expect(count(DemoReferenceData.templateVehicle), 9);
      for (final t in DemoReferenceData.templates) {
        expect(t.sections, hasLength(3));
      }
    });
  });

  group('Risk summary (Riverside, Sep 27) reproduces the mockup', () {
    test('72% overall compliance, 7 passed / 3 needs attention / 2 failed', () {
      final risk = RiskBreakdown(byId('insp-riverside-sep27'));
      expect(risk.compliance, 72);
      expect(risk.passed, 7);
      expect(risk.needsAttention, 3);
      expect(risk.failed, 2);
    });

    test('findings 1 critical / 3 high / 2 medium / 1 low, next Dec 27', () {
      final i = byId('insp-riverside-sep27');
      int n(FindingSeverity s) =>
          i.findings.where((f) => f.severity == s).length;
      expect(
        [
          n(FindingSeverity.critical),
          n(FindingSeverity.high),
          n(FindingSeverity.medium),
          n(FindingSeverity.low),
        ],
        [1, 3, 2, 1],
      );
      expect((i.nextDueAt!.month, i.nextDueAt!.day), (12, 27));
      expect(
        i.findings.take(4).map((f) => (f.title, f.evidence.length)).toList(),
        [
          ('Damaged Electrical Panel', 2),
          ('Leaking Pipe', 3),
          ('Blocked Emergency Exit', 1),
          ('Roof Damage', 2),
        ],
      );
    });
  });

  test(
    'Inspection detail (Riverside today): 7 / 12, 3 findings, 14 photos',
    () {
      final i = byId('insp-riverside-followup');
      expect(i.status, InspectionStatus.inProgress);
      expect((i.completedItemCount, i.totalItemCount), (7, 12));
      expect(i.findings, hasLength(3));
      final photos =
          i.items.expand((x) => x.evidence).length +
          i.findings.expand((f) => f.evidence).length;
      expect(photos, 14);
    },
  );

  test(
    // QC-026: no "review" status — the Central Warehouse visit that used
    // to wait for review continues in progress.
    'Home work counts for Michael: 3 scheduled / 3 in progress',
    () {
      final mine = store.inspections.where(
        (i) => i.inspectorId == 'user-michael',
      );
      int n(InspectionStatus s) => mine.where((i) => i.status == s).length;
      expect(
        [n(InspectionStatus.scheduled), n(InspectionStatus.inProgress)],
        [3, 3],
      );
      expect(
        InspectionStatus.values.map((s) => s.name),
        isNot(contains('review')),
      );
    },
  );

  group('Admin totals and trend windows', () {
    final today = DateTime(2026, 9, 29);
    final all = buildDemoInspections(clock: DateTime(2026, 9, 29, 12));
    int trend(int a, int b) => ((a - b) / b * 100).round();
    int inWindow(
      TrendWindow w,
      DateTime? Function(Inspection) at, [
      bool Function(Inspection)? only,
    ]) => all.where((i) {
      final d = at(i);
      return (only == null || only(i)) && d != null && windowOf(d, today) == w;
    }).length;

    test('48 inspections: 12 in progress, 32 completed', () {
      expect(
        all.where((i) => i.status != InspectionStatus.draft),
        hasLength(48),
      );
      expect(
        all.where((i) => i.status == InspectionStatus.inProgress),
        hasLength(12),
      );
      expect(
        all.where((i) => i.status == InspectionStatus.completed),
        hasLength(32),
      );
    });

    test('scheduled +12%, completed +8%, findings raised −2%', () {
      expect(
        trend(
          inWindow(TrendWindow.last, (i) => i.scheduledAt),
          inWindow(TrendWindow.prev, (i) => i.scheduledAt),
        ),
        12,
      );
      bool done(Inspection i) => i.status == InspectionStatus.completed;
      expect(
        trend(
          inWindow(TrendWindow.last, (i) => i.completedAt, done),
          inWindow(TrendWindow.prev, (i) => i.completedAt, done),
        ),
        8,
      );
      int findings(TrendWindow w) => all
          .where((i) {
            final d = activityDate(i);
            return d != null && windowOf(d, today) == w;
          })
          .fold(0, (s, i) => s + i.findings.length);
      expect(trend(findings(TrendWindow.last), findings(TrendWindow.prev)), -2);
    });
  });

  group('Comparison and history', () {
    test('Sep 27 vs Aug 12: Damaged Electrical Panel still open', () {
      final result = store.comparisonFor(
        'site-riverside',
        'insp-riverside-sep27',
      )!;
      expect(result.previousInspectionId, 'insp-riverside-aug12');
      final byKey = {
        for (final e in result.entries) e.templateChecklistItemId: e,
      };
      expect(
        byKey['item-safety-elec-panels']?.state,
        ComparisonState.stillOpen,
      );
      expect(
        byKey['item-safety-elec-panels']?.label,
        'Damaged Electrical Panel',
      );
      expect(
        byKey['item-safety-emergency-lighting']?.state,
        ComparisonState.resolved,
      );
    });

    test('Riverside history: Sep 27, Aug 12, Jul 3', () {
      expect(
        store.historyFor('site-riverside').map((h) => h.inspectionId).toList(),
        [
          'insp-riverside-sep27',
          'insp-riverside-aug12',
          'insp-riverside-jul03',
        ],
      );
    });

    test('no earlier completed inspection → no comparison', () {
      expect(
        store.comparisonFor('site-riverside', 'insp-riverside-jul03'),
        isNull,
      );
    });
  });

  test('pass rate excludes N/A and unanswered items', () {
    InspectionItem item(String id, ChecklistResult? r) => InspectionItem(
      id: id,
      inspectionId: 'x',
      templateChecklistItemId: id,
      label: id,
      result: r,
    );
    final inspection = Inspection(
      id: 'x',
      templateId: 't',
      templateName: 'T',
      customerId: 'c',
      customerName: 'C',
      siteId: 's',
      siteName: 'S',
      inspectorId: 'u',
      inspectorName: 'U',
      status: InspectionStatus.inProgress,
      items: [
        item('a', ChecklistResult.pass),
        item('b', ChecklistResult.pass),
        item('c', ChecklistResult.pass),
        item('d', ChecklistResult.fail),
        item('e', ChecklistResult.na),
        item('f', null),
      ],
    );
    expect(inspection.computedPassPercentage, closeTo(75.0, 0.001));
  });
}
