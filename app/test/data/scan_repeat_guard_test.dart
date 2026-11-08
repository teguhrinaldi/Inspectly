import 'package:flutter_test/flutter_test.dart';
import 'package:inspectly/features/qr_scanner/qr_scanner_screen.dart';

/// QC-045: holding the camera on an unknown QR code must not look it up
/// several times per second.
void main() {
  test('a code that just failed is ignored for a few seconds', () {
    final guard = ScanRepeatGuard();
    final t0 = DateTime(2026, 11, 8, 12);

    expect(guard.shouldLookUp('BAD', t0), isTrue);
    guard.failed('BAD', t0);
    expect(
      guard.shouldLookUp('BAD', t0.add(const Duration(milliseconds: 250))),
      isFalse,
    );
    expect(
      guard.shouldLookUp('OTHER', t0.add(const Duration(milliseconds: 250))),
      isTrue,
    );
    expect(
      guard.shouldLookUp('BAD', t0.add(const Duration(seconds: 4))),
      isTrue,
    );
  });
}
