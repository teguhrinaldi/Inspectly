import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inspectly/core/widgets/app_image.dart';
import 'package:inspectly/data/datasources/demo/demo_data_store.dart';
import 'package:inspectly/features/findings/evidence_screen.dart';
import 'package:inspectly/features/findings/widgets/finding_widgets.dart';

import '../helpers/pump_screen.dart';

/// QC-042: thumbnails decode at (about) their display size, and the All
/// Photos grid only builds the photos that are on screen.
void main() {
  testWidgets('a thumbnail decodes at its display size', (tester) async {
    await pumpScreen(
      tester,
      const Scaffold(
        body: Center(
          child: SizedBox.square(
            dimension: 80,
            child: AppImage('assets/images/evidence/blocked_exit.jpg'),
          ),
        ),
      ),
    );
    final image = tester.widget<Image>(find.byType(Image)).image;
    expect(image, isA<ResizeImage>());
    // 80 logical px x dpr 3 x 2 (room for a "cover" crop).
    expect((image as ResizeImage).width, 480);
  });

  testWidgets('All Photos builds lazily', (tester) async {
    final store = DemoDataStore.instance;
    final rich = store.inspections.reduce(
      (a, b) => a.allEvidence.length >= b.allEvidence.length ? a : b,
    );
    final many = rich.copyWith(
      items: [
        for (final item in rich.items)
          item.copyWith(
            evidence: [
              for (var k = 0; k < 20; k++)
                ...item.evidence.map((e) => e.copyWith(id: '${e.id}-$k')),
            ],
          ),
      ],
    );
    expect(many.allEvidence.length, greaterThan(60));
    await pumpScreen(
      tester,
      Scaffold(
        body: CustomScrollView(
          slivers: [EvidenceView(inspection: many, sliver: true)],
        ),
      ),
      size: const Size(390, 844),
    );
    await tester.tap(find.textContaining('All Photos'));
    await tester.pump();

    expect(
      find.byType(EvidenceThumb).evaluate().length,
      lessThan(many.allEvidence.length),
    );
  });
}
