import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inspectly/data/services/evidence_capture_service.dart';
import 'package:inspectly/features/findings/widgets/photo_capture.dart';

import '../helpers/pump_screen.dart';

/// QC-014: a denied camera permission is explained, not an unhandled error.
class _DeniedCamera extends EvidenceCaptureService {
  @override
  Future<String?> captureFromCamera() async => throw PlatformException(
    code: 'camera_access_denied',
    message: 'The user did not allow camera access.',
  );
}

void main() {
  testWidgets('denied camera shows a message with a Settings action', (
    tester,
  ) async {
    CapturedPhoto? photo;
    await pumpScreen(
      tester,
      Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            onPressed: () async => photo = await capturePhoto(
              context,
              siteName: 'Riverside',
              inspectorName: 'Michael',
              captureService: _DeniedCamera(),
            ),
            child: const Text('Add photo'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Add photo'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Take photo'));
    await tester.pumpAndSettle();

    expect(photo, isNull);
    expect(find.textContaining('Camera access'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
  });
}
