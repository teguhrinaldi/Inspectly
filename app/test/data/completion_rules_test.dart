import 'package:flutter_test/flutter_test.dart';
import 'package:inspectly/core/errors/failure.dart';
import 'package:inspectly/core/utils/completion_rules.dart';
import 'package:inspectly/data/datasources/demo/demo_data_store.dart';
import 'package:inspectly/data/models/enums.dart';
import 'package:inspectly/data/models/inspection_template.dart';
import 'package:inspectly/data/repositories/mock/mock_inspection_repository.dart';

/// QC-007/036: complete only from in progress; items that require photo
/// evidence need one; a signature needs a real stroke.
void main() {
  final store = DemoDataStore.instance;

  test('demo mode only completes an inspection in progress', () async {
    final scheduled = store.inspections.firstWhere(
      (i) => i.status == InspectionStatus.scheduled,
    );
    final result = await MockInspectionRepository().complete(scheduled.id);
    result.when(
      success: (_) => fail('expected 409'),
      failure: (f) => expect(f, isA<ConflictFailure>()),
    );
  });

  test('items requiring evidence without a photo are reported', () {
    final inspection = store.inspections.firstWhere(
      (i) => i.items.isNotEmpty,
    );
    final item = inspection.items.first.copyWith(evidence: const []);
    final template = InspectionTemplate(
      id: inspection.templateId,
      name: 't',
      category: 'safety',
      sections: [
        TemplateSection(
          id: 's',
          templateId: inspection.templateId,
          title: 's',
          items: [
            TemplateChecklistItem(
              id: item.templateChecklistItemId,
              sectionId: 's',
              label: item.label,
              requiresEvidence: true,
            ),
          ],
        ),
      ],
    );
    final bare = inspection.copyWith(items: [item], findings: const []);

    expect(itemsMissingEvidence(bare, template), [item.label]);
  });

  test('a tap or a tiny scribble is not a signature', () {
    Offset p(double x, double y) => Offset(x, y);
    expect(signatureIsLongEnough([p(10, 10)]), isFalse);
    expect(signatureIsLongEnough([p(10, 10), p(30, 12), p(40, 15)]), isFalse);
    final wave = [for (var x = 0.0; x <= 200; x += 5) p(x, 40 + (x % 40))];
    expect(signatureIsLongEnough(wave), isTrue);
  });
}
